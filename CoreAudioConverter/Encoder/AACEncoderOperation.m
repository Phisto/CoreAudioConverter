//
//  AACEncoderOperation.m
//  CoreAudioConverter
//
//  Created by Simon Gaus on 17.03.16.
//  Copyright © 2016 Simon Gaus. All rights reserved.
//

#import "AACEncoderOperation.h"
#import "CADecoder.h"

@interface AACEncoderOperation (/* Private */)

@property (nonatomic, strong) NSObject<AACEncoderOperationDelegate> *delegate;
@property (nonatomic, strong) NSMutableArray *workload;
@property (nonatomic, strong) NSMutableArray *errorArray;
@property (nonatomic, strong) NSFileManager *fileManager;
@property (nonatomic, readwrite) NSInteger bitrate;
@property (nonatomic, readwrite) NSInteger quality;

@property (nonatomic, strong) NSURL *inputUrl;
@property (nonatomic, strong) NSURL *outputUrl;

@end

@implementation AACEncoderOperation

- (instancetype)initWithDelegate:(NSObject<AACEncoderOperationDelegate> *)delegate workload:(NSArray *)workloadArray {
    
    self = [self initWithDelegate:delegate];
    if (self) {
        _errorArray = [NSMutableArray new];
        _workload = [NSMutableArray arrayWithArray:workloadArray];
    }
    return self;
}

- (instancetype)initWithDelegate:(NSObject<AACEncoderOperationDelegate> *)delegate {
    
    self = [super init];
    
    if (self) {
        
        _delegate = delegate;
        _bitrate = _delegate.bitrate;
        _quality = _delegate.quality;
    }
    
    return self;
}

- (void)main {
    
    // encode as long as there dicts...
    NSDictionary *dict = nil;
    while ([self getNextAssignemnt:&dict] && !self.cancelled) {
        
        BOOL erfolg = [self encode:dict];
        if (erfolg) {
            
            [self.delegate encodingFinished:dict];
            
        } else {
            
            NSString *text = NSLocalizedString(@"Die Datei '%@' konnte nicht konvertiert werden.", @"---");
            NSString *locText = [NSString stringWithFormat:text, [dict valueForKey:kSongInputUrlKey]];
            NSDictionary *infoDict = @{ NSLocalizedDescriptionKey: locText };
            [_errorArray addObject:[NSError errorWithDomain:NSCocoaErrorDomain code:99 userInfo:infoDict]];
        }
    }
    
    if (!self.cancelled) {
        [self.delegate encodingFinishedwithErrors:[_errorArray copy]];
    }
}

- (BOOL)encode:(NSDictionary *)dict {
    
    // get next assignment
    NSURL *fileUrl = [dict valueForKey:kSongInputUrlKey];
    NSURL *outUrl = [dict valueForKey:kSongTempUrlKey];
    
    // if file exists... return succesfull
    if ([self.fileManager fileExistsAtPath:outUrl.path]) {
        
        return YES;
    }
    
    // create album+artist folder if there is no folder
    NSString *foldersPath = outUrl.URLByDeletingLastPathComponent.path;
    NSError *folderError = nil;
    BOOL created = [self creatFolder:foldersPath error:&folderError];
    if (!created && folderError) {
        
        [self.errorArray addObject:folderError];
        return NO;
    }
    
    // check file format
    NSArray			*coreAudioExtensions	= [[self class] supportedAudioExtensions];
    NSString		*extension				= fileUrl.pathExtension.lowercaseString;
    if (![coreAudioExtensions containsObject:extension]) {
        
        NSDictionary *infoDict = @{ NSLocalizedDescriptionKey: NSLocalizedString(@"File format not supported.", @"---") };
        NSError *newError = [NSError errorWithDomain:AudioConverterErrorDomain
                                                code:ACErrorFileFormatNotSupported
                                            userInfo:infoDict];
        [self.errorArray addObject:newError];
        return NO;
    }
    
    if (self.cancelled) {
        return YES;
    }
    
    // if succesfull
    _inputUrl = fileUrl;
    _outputUrl = outUrl;
    
    OSStatus						err;
    AudioBufferList					bufferList;
    ssize_t							bufferLen							= 0;
    SInt64							totalFrames, framesToRead;
    UInt32							size, frameCount;
    UInt32							bitrate, quality, mode;
    ExtAudioFileRef					extAudioFile						= NULL;
    
    AudioStreamBasicDescription		outputFormat;
    
    AudioConverterRef				converter							= NULL;
    CFArrayRef						converterPropertySettings			= NULL;
				
    @try {
        bufferList.mBuffers[0].mData = NULL;
        
        // Setup the decoder
        NSError *decoderError = nil;
        CADecoder *decoder = [CADecoder decoderForFile:self.inputUrl error:&decoderError];
        if (!decoder) {
            [self.errorArray addObject:decoderError];
            return NO;
        }
        
        // Desired output
        bzero(&outputFormat, sizeof(AudioStreamBasicDescription));
        
        outputFormat.mFormatID          = kAudioFormatMPEG4AAC;
        outputFormat.mFormatFlags		= decoder.pcmFormat.mFormatFlags;;
        outputFormat.mBitsPerChannel	= decoder.pcmFormat.mBitsPerChannel;
        outputFormat.mSampleRate		= decoder.pcmFormat.mSampleRate;
        outputFormat.mChannelsPerFrame	= decoder.pcmFormat.mChannelsPerFrame;
        
        // Flesh out output structure for PCM formats
        if(kAudioFormatLinearPCM == decoder.pcmFormat.mFormatID) {
            outputFormat.mFramesPerPacket	= 1;
            outputFormat.mBytesPerPacket	= decoder.pcmFormat.mChannelsPerFrame * (decoder.pcmFormat.mBitsPerChannel / 8);
            outputFormat.mBytesPerFrame		= decoder.pcmFormat.mBytesPerPacket * decoder.pcmFormat.mFramesPerPacket;
        }
        // Adjust the flags for Apple Lossless
        else if(kAudioFormatAppleLossless == decoder.pcmFormat.mFormatID) {
            switch(decoder.pcmFormat.mBitsPerChannel) {
                case 16:	outputFormat.mFormatFlags = kAppleLosslessFormatFlag_16BitSourceData;	break;
                case 20:	outputFormat.mFormatFlags = kAppleLosslessFormatFlag_20BitSourceData;	break;
                case 24:	outputFormat.mFormatFlags = kAppleLosslessFormatFlag_24BitSourceData;	break;
                case 32:	outputFormat.mFormatFlags = kAppleLosslessFormatFlag_32BitSourceData;	break;
                default:	outputFormat.mFormatFlags = kAppleLosslessFormatFlag_16BitSourceData;	break;
            }
        }
        
        err = ExtAudioFileCreateWithURL((__bridge CFURLRef)self.outputUrl,
                                  kAudioFileM4AType,
                                  &outputFormat,
                                  NULL,
                                  kAudioFileFlags_EraseFile,
                                  &extAudioFile);
        
        // Tweak converter settings
        size	= sizeof(converter);
        err		= ExtAudioFileGetProperty(extAudioFile, kExtAudioFileProperty_AudioConverter, &size, &converter);
        NSAssert2(noErr == err, NSLocalizedStringFromTable(@"The call to %@ failed.", @"Exceptions", @""), @"ExtAudioFileGetProperty", UTCreateStringForOSType(err));
        
        // Only adjust settings if a converter exists
        if(NULL != converter) {
            
            // Bitrate
            bitrate		= self.delegate.bitrate;
            err			= AudioConverterSetProperty(converter, kAudioConverterEncodeBitRate, sizeof(bitrate), &bitrate);
            
            // Quality
            quality		= self.delegate.quality;
            err			= AudioConverterSetProperty(converter, kAudioConverterCodecQuality, sizeof(quality), &quality);
            
            // Bitrate
            mode = kAudioCodecBitRateFormat_CBR;
            err			= AudioConverterSetProperty(converter, kAudioCodecPropertyBitRateControlMode, sizeof(mode), &mode);
            
            // Update
            size	= sizeof(converterPropertySettings);
            err		= AudioConverterGetProperty(converter, kAudioConverterPropertySettings, &size, &converterPropertySettings);
            
            err = ExtAudioFileSetProperty(extAudioFile, kExtAudioFileProperty_ConverterConfig, size, &converterPropertySettings);
        }
        
        // Allocate buffer
        bufferLen						= 10 * 1024;
        bufferList.mNumberBuffers		= 1;
        bufferList.mBuffers[0].mData	= calloc(bufferLen, sizeof(uint8_t));
        NSAssert(NULL != bufferList.mBuffers[0].mData, NSLocalizedStringFromTable(@"Unable to allocate memory.", @"Exceptions", @""));
        
        totalFrames						= decoder.totalFrames;
        framesToRead					= totalFrames;
        
        // Iteratively get the data and save it to the file
        for(;;) {
            
            // Set up the buffer parameters
            bufferList.mBuffers[0].mNumberChannels	= decoder.pcmFormat.mChannelsPerFrame;
            bufferList.mBuffers[0].mDataByteSize	= (UInt32)bufferLen;
            frameCount								= bufferList.mBuffers[0].mDataByteSize / [decoder pcmFormat].mBytesPerFrame;
            
            // Read a chunk of PCM input
            frameCount = [decoder readAudio:&bufferList frameCount:frameCount];
            
            // We're finished if no frames were returned
            if(0 == frameCount)
                break;
            
            // Write the data, encoding/converting in the process
            err = ExtAudioFileWrite(extAudioFile, frameCount, &bufferList);
            NSAssert2(noErr == err, NSLocalizedStringFromTable(@"The call to %@ failed.", @"Exceptions", @""), @"ExtAudioFileWrite", UTCreateStringForOSType(err));
            
            // Update status
            framesToRead -= frameCount;
        }
    }
    
    @catch(NSException *exception) {
        
        [self.errorArray addObject:[self newNSErrorFromException:exception]];
        return NO;
    }
    
    @finally {
        
        // Close the output file
        if(NULL != extAudioFile) {
            err = ExtAudioFileDispose(extAudioFile);
            if(noErr != err) {
                
                NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:err userInfo:nil];
                [self.errorArray addObject:error];
            }
        }
        
        free(bufferList.mBuffers[0].mData);
    }
}

- (BOOL)getNextAssignemnt:(NSDictionary **)dict {
    
    NSDictionary *tempDict = nil;
    if (self.workload) {
        
        tempDict = self.workload.lastObject;
        if (tempDict) {
            
            [self.workload removeLastObject];
            *dict = [tempDict copy];
            return YES;
        }
    }
    
    return NO;
}

@end
