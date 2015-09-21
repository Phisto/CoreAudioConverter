//
//  CADecoder.m
//  M4AtoMP3
//
//  Created by Simon Gaus on 19.09.15.
//  Copyright © 2015 Simon Gaus. All rights reserved.
//

#import "CADecoder.h"

#import <AudioToolbox/AudioFormat.h>
#import <AudioToolbox/ExtendedAudioFile.h>

#import "CircularBuffer.h"

static NSArray *sAudioExtensions;

@interface CADecoder (/* Private */)

/*!
 * @brief The first frame that will be returned from -readAudio:frameCount:
 */
@property (nonatomic, readwrite) SInt64 currentFrame;
/*!
 * @brief The buffer which holds the PCM audio data.
 */
@property (nonatomic, strong) CircularBuffer *pcmBuffer;
/*!
 * @brief The url of the source file.
 */
@property (nonatomic, strong) NSURL *fileUrl;
/*!
 * @brief Extendet audio file struct for the source file.
 */
@property (nonatomic, readwrite) ExtAudioFileRef extAudioFile;
/*!
 * @brief The format of PCM data provided by the source file.
 */
@property (nonatomic, readwrite) AudioStreamBasicDescription pcmFormat;

@end

@implementation CADecoder
#pragma mark Object creation

+ (instancetype)decoderForFile:(NSURL *)fileUrl error:(NSError *__autoreleasing *)error {
    
    CADecoder *result = nil;
    
    // Create the source based on the file's extension
    NSArray			*coreAudioExtensions	= getCoreAudioExtensions();
    NSString		*extension				= [[fileUrl pathExtension] lowercaseString];
    
    // format supported
    if ([coreAudioExtensions containsObject:extension]) {
        
        result = [[CADecoder alloc] initWithFile:fileUrl];
        if (!result) {
            
            NSDictionary *infoDict = @{ NSLocalizedDescriptionKey: NSLocalizedString(@"Couldn't create decoder.", @"---") };
            NSError *newError = [NSError errorWithDomain:AudioConverterErrorDomain
                                                    code:ACErrorUnknown
                                                userInfo:infoDict];
            *error = newError;
            return nil;
        }
    }
    // format not supported
    else {
        
        NSDictionary *infoDict = @{ NSLocalizedDescriptionKey: NSLocalizedString(@"File format not supported.", @"---") };
        NSError *newError = [NSError errorWithDomain:AudioConverterErrorDomain
                                                code:ACErrorFileFormatNotSupported
                                            userInfo:infoDict];
        if (error != NULL) *error = newError;
    }
        
    return result;
}
- (instancetype)initWithFile:(NSURL *)fileUrl {
    NSParameterAssert(fileUrl);
    
    self = [super init];
    
    if(self) {
        
        _pcmBuffer = [[CircularBuffer alloc] init];
        _fileUrl = fileUrl;
    
        OSStatus result = ExtAudioFileOpenURL((__bridge CFURLRef _Nonnull)(fileUrl), &_extAudioFile);
        NSAssert1(noErr == result, @"ExtAudioFileOpen failed: %@", UTCreateStringForOSType(result));
        
        // Query file type
        UInt32 dataSize = sizeof(AudioStreamBasicDescription);
        result = ExtAudioFileGetProperty(_extAudioFile, kExtAudioFileProperty_FileDataFormat, &dataSize, &_pcmFormat);
        NSAssert1(noErr == result, @"AudioFileGetProperty failed: %@", UTCreateStringForOSType(result));
        
        _pcmFormat.mFormatID = kAudioFormatLinearPCM;
        _pcmFormat.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsBigEndian | kAudioFormatFlagIsPacked;
        
        // For alac the source bit depth is encoded in the format flag
        if(kAudioFormatAppleLossless == _pcmFormat.mFormatID) {
            
            switch (_pcmFormat.mFormatFlags) {
                case kAppleLosslessFormatFlag_16BitSourceData:
                    _pcmFormat.mBitsPerChannel = 16;
                    break;
                case kAppleLosslessFormatFlag_24BitSourceData:
                    _pcmFormat.mBitsPerChannel = 24;
                    break;
                case kAppleLosslessFormatFlag_32BitSourceData:
                    _pcmFormat.mBitsPerChannel = 32;
                    break;
                default:
                    _pcmFormat.mBitsPerChannel = 16;
                    break;
            }
        }
        else {
            
            // Preserve mSampleRate and mChannelsPerFrame
            _pcmFormat.mBitsPerChannel	= (0 == _pcmFormat.mBitsPerChannel ? 16 : _pcmFormat.mBitsPerChannel);
        
            _pcmFormat.mBytesPerPacket = (_pcmFormat.mBitsPerChannel / 8) * _pcmFormat.mChannelsPerFrame;
            _pcmFormat.mFramesPerPacket = 1;
            _pcmFormat.mBytesPerFrame = _pcmFormat.mBytesPerPacket * _pcmFormat.mFramesPerPacket;
        }
        
        // Tell the extAudioFile the format we'd like for data
        result = ExtAudioFileSetProperty(_extAudioFile, kExtAudioFileProperty_ClientDataFormat, sizeof(_pcmFormat), &_pcmFormat);
        NSAssert1(noErr == result, @"ExtAudioFileSetProperty failed: %@", UTCreateStringForOSType(result));
    }
    
    return self;
}

#pragma mark -
#pragma mark Main Methodes

- (UInt32)readAudio:(AudioBufferList *)bufferList frameCount:(UInt32)frameCount {
    
    NSParameterAssert(NULL != bufferList);
    NSParameterAssert(0 < bufferList->mNumberBuffers);
    NSParameterAssert(0 < frameCount);
    
    UInt32		framesRead		= 0;
    UInt32		byteCount		= frameCount * self.pcmFormat.mBytesPerPacket;
    UInt32		bytesRead		= 0;
    
    NSParameterAssert(bufferList->mBuffers[0].mDataByteSize >= byteCount);
    
    // If there aren't enough bytes in the buffer, fill it as much as possible
    if([[self pcmBuffer] bytesAvailable] < byteCount) {
        
        [self fillPCMBuffer];
    }
    
    // If there still aren't enough bytes available, return what we have
    if([[self pcmBuffer] bytesAvailable] < byteCount)
        byteCount = (UInt32)[[self pcmBuffer] bytesAvailable];
    
    bytesRead								= (UInt32)[[self pcmBuffer] getData:bufferList->mBuffers[0].mData byteCount:byteCount];
    bufferList->mBuffers[0].mNumberChannels	= [self pcmFormat].mChannelsPerFrame;
    bufferList->mBuffers[0].mDataByteSize	= bytesRead;
    framesRead								= bytesRead / [self pcmFormat].mBytesPerFrame;
    
    // Update internal state
    _currentFrame += framesRead;
    
    return framesRead;
}

- (SInt64)totalFrames {
    
    OSStatus	result;
    UInt32		dataSize;
    SInt64		frameCount;
    
    dataSize		= sizeof(frameCount);
    result			= ExtAudioFileGetProperty(_extAudioFile, kExtAudioFileProperty_FileLengthFrames, &dataSize, &frameCount);
    NSAssert1(noErr == result, @"ExtAudioFileGetProperty(kExtAudioFileProperty_FileLengthFrames) failed: %@", UTCreateStringForOSType(result));
    
    return frameCount;
}

- (BOOL)supportsSeeking {
    
    return YES;
}

- (SInt64)seekToFrame:(SInt64)frame {
    
    OSStatus result = ExtAudioFileSeek(_extAudioFile, frame);
    if(noErr == result) {
        [self.pcmBuffer reset];
        _currentFrame = frame;
    }
    
    return self.currentFrame;
}

- (void)fillPCMBuffer {
    
    CircularBuffer		*buffer				= self.pcmBuffer;
    OSStatus			result;
    AudioBufferList		bufferList;
    UInt32				frameCount;
    
    bufferList.mNumberBuffers				= 1;
    bufferList.mBuffers[0].mNumberChannels	= self.pcmFormat.mChannelsPerFrame;
    bufferList.mBuffers[0].mData			= [buffer exposeBufferForWriting];
    bufferList.mBuffers[0].mDataByteSize	= (UInt32)[buffer freeSpaceAvailable];
    
    frameCount								= bufferList.mBuffers[0].mDataByteSize / self.pcmFormat.mBytesPerFrame;
    result									= ExtAudioFileRead(_extAudioFile, &frameCount, &bufferList);
    NSAssert1(noErr == result, @"ExtAudioFileRead failed: %@", UTCreateStringForOSType(result));
    
    NSAssert(frameCount * self.pcmFormat.mBytesPerFrame == bufferList.mBuffers[0].mDataByteSize, @"mismatch");
    
    [buffer wroteBytes:bufferList.mBuffers[0].mDataByteSize];
}

#pragma mark -
#pragma mark Helper Methodes

- (NSString *)pcmFormatDescription {
    
    OSStatus						result;
    UInt32							specifierSize;
    AudioStreamBasicDescription		asbd;
    NSString						*fileFormat;
    
    asbd			= _pcmFormat;
    specifierSize	= sizeof(fileFormat);
    result			= AudioFormatGetProperty(kAudioFormatProperty_FormatName, sizeof(AudioStreamBasicDescription), &asbd, &specifierSize, &fileFormat);
    NSAssert1(noErr == result, @"AudioFormatGetProperty failed: %@", UTCreateStringForOSType(result));
    
    return fileFormat;
}
/**
  Return an array of valid audio file extensions recognized by Core Audio.
  @return NSArray
 */
NSArray * getCoreAudioExtensions() {
    
    @synchronized(sAudioExtensions) {
        if(nil == sAudioExtensions) {
            UInt32		size	= sizeof(sAudioExtensions);
            OSStatus	err		= AudioFileGetGlobalInfo(kAudioFileGlobalInfo_AllExtensions, 0, NULL, &size, &sAudioExtensions);
            
            NSCAssert2(noErr == err, NSLocalizedStringFromTable(@"The call to %@ failed.", @"Exceptions", @""), @"AudioFileGetGlobalInfo", UTCreateStringForOSType(err));
        }
    }
    
    return sAudioExtensions;
}

#pragma mark -
@end


























