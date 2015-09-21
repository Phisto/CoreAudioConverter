//
//  MP3Encoder.m
//  M4AtoMP3
//
//  Created by Simon Gaus on 20.09.15.
//  Copyright © 2015 Simon Gaus. All rights reserved.
//

#import "MP3Encoder.h"

#import "lame.h"
#import "CADecoder.h"
#import <AudioToolbox/AudioFormat.h>

@interface MP3Encoder (/* Private */)

@property (nonatomic, readwrite) lame_global_flags *lame;
@property (nonatomic, strong) NSURL *sourceFileUrl;
@property (nonatomic, readwrite) UInt32 sourceBitsPerChannel;
@property (nonatomic, readwrite) FILE *out;

@end

@implementation MP3Encoder
#pragma mark Object creation

+ (instancetype)encoderForFile:(NSURL *)fileUrl error:(NSError **)error {
    
    MP3Encoder *result = nil;
    
    // Create the source based on the file's extension
    NSArray			*coreAudioExtensions	= [MP3Encoder supportedAudioExtensions];
    NSString		*extension				= [[fileUrl pathExtension] lowercaseString];
    
    // format supported
    if ([coreAudioExtensions containsObject:extension]) {
        
        result = [[MP3Encoder alloc] initWithFile:fileUrl];
        if (!result) {
            
            NSDictionary *infoDict = @{ NSLocalizedDescriptionKey: NSLocalizedString(@"Couldn't create decoder.", @"---") };
            NSError *newError = [NSError errorWithDomain:AudioConverterErrorDomain
                                                    code:ACErrorUnknown
                                                userInfo:infoDict];
            if (error != NULL) *error = newError;
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
    
    self = [super init];
    
    if (self && fileUrl) {
        
        _sourceFileUrl = fileUrl;
        
        _lame = lame_init();
        NSAssert(NULL != _lame, NSLocalizedStringFromTable(@"Unable to allocate memory.", @"Exceptions", @""));
        lame_set_VBR(_lame, vbr_off); // use constant bitrate
        lame_set_mode(_lame, JOINT_STEREO); // LAME_STEREO_MODE_JOINT_STEREO
        
        // Write the Xing VBR tag if vbr is used
        //lame_set_bWriteVbrTag(_lame, 1);
    }
    
    return self;
}

#pragma mark -
#pragma mark Methodes

- (void)encodeToUrl:(NSURL *)outputUrl {
    
    NSAssert(self.delegate, NSLocalizedStringFromTable(@"No delegate for encoding.", @"Exceptions", @""));
    
    FILE							*file							= NULL;
    int								result;
    AudioBufferList					bufferList;
    ssize_t							bufferLen						= 0;
    UInt32							bufferByteSize					= 0;
    SInt64							totalFrames, framesToRead;
    UInt32							frameCount;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([self.delegate respondsToSelector:@selector(encodingStarted:outputSize:)]) {
        
            [self.delegate encodingStarted:self outputSize:100];
        }
    });
    
    @try {
        bufferList.mBuffers[0].mData = NULL;
        
        // Parse the encoder settings
        lame_set_quality(_lame, [self.delegate engineQuality]); // LAME_ENCODING_ENGINE_QUALITY_STANDARD
        lame_set_brate(_lame, [self.delegate bitrate]); // set bitrate
        
        // Setup the decoder
        NSError *error = nil;
        CADecoder *decoder = [CADecoder decoderForFile:self.sourceFileUrl error:&error];
        if (!decoder) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if ([self.delegate respondsToSelector:@selector(encodingFailed:withError:)]) {
                
                    [self.delegate encodingFailed:self withError:error];
                }
            });
            
            return;
        }
        
        NSAssert(1 == decoder.pcmFormat.mChannelsPerFrame || 2 == decoder.pcmFormat.mChannelsPerFrame, NSLocalizedStringFromTable(@"LAME only supports one or two channel input.", @"Exceptions", @""));
        
        _sourceBitsPerChannel	= decoder.pcmFormat.mBitsPerChannel;
        totalFrames				= decoder.totalFrames;
        framesToRead			= totalFrames;
        
        // Set up the AudioBufferList
        bufferList.mNumberBuffers					= 1;
        bufferList.mBuffers[0].mData				= NULL;
        bufferList.mBuffers[0].mNumberChannels		= decoder.pcmFormat.mChannelsPerFrame;
        
        // Allocate the buffer that will hold the interleaved audio data
        bufferLen									= 1024;
        switch(decoder.pcmFormat.mBitsPerChannel) {
                
            case 8:
            case 24:
                bufferList.mBuffers[0].mData			= calloc(bufferLen, sizeof(int8_t));
                bufferList.mBuffers[0].mDataByteSize	= (UInt32)bufferLen * sizeof(int8_t);
                break;
                
            case 16:
                bufferList.mBuffers[0].mData			= calloc(bufferLen, sizeof(int16_t));
                bufferList.mBuffers[0].mDataByteSize	= (UInt32)bufferLen * sizeof(int16_t);
                break;
                
            case 32:
                bufferList.mBuffers[0].mData			= calloc(bufferLen, sizeof(int32_t));
                bufferList.mBuffers[0].mDataByteSize	= (UInt32)bufferLen * sizeof(int32_t);
                break;
                
            default:
                @throw [NSException exceptionWithName:@"IllegalInputException" reason:@"Sample size not supported" userInfo:nil];
                break;
        }
        
        bufferByteSize = bufferList.mBuffers[0].mDataByteSize;
        NSAssert(NULL != bufferList.mBuffers[0].mData, NSLocalizedStringFromTable(@"Unable to allocate memory.", @"Exceptions", @""));
        
        // Initialize the LAME encoder
        lame_set_num_channels(_lame, decoder.pcmFormat.mChannelsPerFrame);
        lame_set_in_samplerate(_lame, decoder.pcmFormat.mSampleRate);
        
        result = lame_init_params(_lame);
        NSAssert(-1 != result, NSLocalizedStringFromTable(@"Unable to initialize the LAME encoder.", @"Exceptions", @""));
        
        // Open the output file
        _out = fopen([outputUrl fileSystemRepresentation], "w");
        NSAssert(NULL != _out, NSLocalizedStringFromTable(@"Unable to create the output file.", @"Exceptions", @""));
        
        // Iteratively get the PCM data and encode it
        for(;;) {
            
            // Set up the buffer parameters
            bufferList.mBuffers[0].mNumberChannels	= decoder.pcmFormat.mChannelsPerFrame;
            bufferList.mBuffers[0].mDataByteSize	= bufferByteSize;
            frameCount								= bufferList.mBuffers[0].mDataByteSize / decoder.pcmFormat.mBytesPerFrame;
            
            // Read a chunk of PCM input
            frameCount = [decoder readAudio:&bufferList frameCount:frameCount];
            
            // We're finished if no frames were returned
            if(0 == frameCount) {
                break;
            }
            
            // Encode the PCM data
            [self encodeChunk:&bufferList frameCount:frameCount];
            
            // Update status
            framesToRead -= frameCount;
        }
        
        // Flush the last MP3 frames (maybe)
        [self finishEncode];
        
        // Close the output file
        result = fclose(_out);
        NSAssert(0 == result, NSLocalizedStringFromTable(@"Unable to close the output file.", @"Exceptions", @""));
        _out = NULL;
        
        // Write the Xing VBR tag
        file = fopen([outputUrl fileSystemRepresentation], "r+");
        NSAssert(NULL != file, NSLocalizedStringFromTable(@"Unable to open the output file.", @"Exceptions", @""));
        
        lame_mp3_tags_fid(_lame, file);
    }
    
    @catch(NSException *exception) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
             if ([self.delegate respondsToSelector:@selector(encodingFailed:withError:)]) {
            
                 [self.delegate encodingFailed:self withError:NewNSErrorFromException(exception)];
             }
        });
    }
    
    @finally {
        NSException *exception;
        
        // Close the output file if not already closed
        if(NULL != _out && EOF == fclose(_out)) {
            exception = [NSException exceptionWithName:@"IOException"
                                                reason:NSLocalizedStringFromTable(@"Unable to close the output file.", @"Exceptions", @"")
                                              userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:errno], [NSString stringWithCString:strerror(errno) encoding:NSASCIIStringEncoding], nil] forKeys:[NSArray arrayWithObjects:@"errorCode", @"errorString", nil]]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                 if ([self.delegate respondsToSelector:@selector(encodingFailed:withError:)]) {
                
                     [self.delegate encodingFailed:self withError:NewNSErrorFromException(exception)];
                 }
            });
        }
        
        // And close the other output file
        if(NULL != file && EOF == fclose(file)) {
            exception = [NSException exceptionWithName:@"IOException"
                                                reason:NSLocalizedStringFromTable(@"Unable to close the output file.", @"Exceptions", @"")
                                              userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:errno], [NSString stringWithCString:strerror(errno) encoding:NSASCIIStringEncoding], nil] forKeys:[NSArray arrayWithObjects:@"errorCode", @"errorString", nil]]];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                 if ([self.delegate respondsToSelector:@selector(encodingFailed:withError:)]) {
                
                     [self.delegate encodingFailed:self withError:NewNSErrorFromException(exception)];
                 }
            });
        }
        
        free(bufferList.mBuffers[0].mData);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
             if ([self.delegate respondsToSelector:@selector(encodingFinished:)]) {
            
                 [self.delegate encodingFinished:self];
             }
        });
    }
}

- (void)encodeChunk:(const AudioBufferList *)chunk frameCount:(UInt32)frameCount {
    
    unsigned char	*buffer					= NULL;
    unsigned		bufferLen				= 0;
    
    void			**channelBuffers		= NULL;
    short			**channelBuffers16		= NULL;
    long			**channelBuffers32		= NULL;
    
    int8_t			*buffer8				= NULL;
    int16_t			*buffer16				= NULL;
    int32_t			*buffer32				= NULL;
    
    int32_t			constructedSample;
    
    int				result;
    size_t			numWritten;
    
    unsigned		wideSample;
    unsigned		sample, channel;
    
    @try {
        // Allocate the MP3 buffer using LAME guide for size
        bufferLen	= 1.25 * (chunk->mBuffers[0].mNumberChannels * frameCount) + 7200;
        buffer		= (unsigned char *) calloc(bufferLen, sizeof(unsigned char));
        NSAssert(NULL != buffer, NSLocalizedStringFromTable(@"Unable to allocate memory.", @"Exceptions", @""));
        
        // Allocate channel buffers for sample de-interleaving
        channelBuffers = calloc(chunk->mBuffers[0].mNumberChannels, sizeof(void *));
        NSAssert(NULL != channelBuffers, NSLocalizedStringFromTable(@"Unable to allocate memory.", @"Exceptions", @""));
        
        // Initialize each channel buffer to zero
        for(channel = 0; channel < chunk->mBuffers[0].mNumberChannels; ++channel) {
            channelBuffers[channel] = NULL;
        }
        
        // Split PCM data into channels and convert to appropriate sample size for LAME
        switch(_sourceBitsPerChannel) {
                
            case 8:
                channelBuffers16 = (short **)channelBuffers;
                
                for(channel = 0; channel < chunk->mBuffers[0].mNumberChannels; ++channel) {
                    channelBuffers16[channel] = calloc(frameCount, sizeof(short));
                    NSAssert(NULL != channelBuffers16[channel], NSLocalizedStringFromTable(@"Unable to allocate memory.", @"Exceptions", @""));
                }
                
                buffer8 = chunk->mBuffers[0].mData;
                for(wideSample = sample = 0; wideSample < frameCount; ++wideSample) {
                    for(channel = 0; channel < chunk->mBuffers[0].mNumberChannels; ++channel, ++sample) {
                        // Rescale values to short
                        channelBuffers16[channel][wideSample] = (short)(((buffer8[sample] << 8) & 0xFF00) | (buffer8[sample] & 0xFF));
                    }
                }
                
                result = lame_encode_buffer(_lame, channelBuffers16[0], channelBuffers16[1], frameCount, buffer, bufferLen);
                
                break;
                
            case 16:
                channelBuffers16 = (short **)channelBuffers;
                
                for(channel = 0; channel < chunk->mBuffers[0].mNumberChannels; ++channel) {
                    channelBuffers16[channel] = calloc(frameCount, sizeof(short));
                    NSAssert(NULL != channelBuffers16[channel], NSLocalizedStringFromTable(@"Unable to allocate memory.", @"Exceptions", @""));
                }
                
                buffer16 = chunk->mBuffers[0].mData;
                for(wideSample = sample = 0; wideSample < frameCount; ++wideSample) {
                    for(channel = 0; channel < chunk->mBuffers[0].mNumberChannels; ++channel, ++sample) {
                        channelBuffers16[channel][wideSample] = (short)OSSwapBigToHostInt16(buffer16[sample]);
                    }
                }
                
                result = lame_encode_buffer(_lame, channelBuffers16[0], channelBuffers16[1], frameCount, buffer, bufferLen);
                
                break;
                
            case 24:
                channelBuffers32 = (long **)channelBuffers;
                
                for(channel = 0; channel < chunk->mBuffers[0].mNumberChannels; ++channel) {
                    channelBuffers32[channel] = calloc(frameCount, sizeof(long));
                    NSAssert(NULL != channelBuffers32[channel], NSLocalizedStringFromTable(@"Unable to allocate memory.", @"Exceptions", @""));
                }
                
                // Packed 24-bit data is 3 bytes, while unpacked is 24 bits in an int32_t
                buffer8 = chunk->mBuffers[0].mData;
                for(wideSample = sample = 0; wideSample < frameCount; ++wideSample) {
                    for(channel = 0; channel < chunk->mBuffers[0].mNumberChannels; ++channel) {
                        // Read three bytes and reconstruct them as a 32-bit BE integer
                        constructedSample = (int8_t)*buffer8++; constructedSample <<= 8;
                        constructedSample |= (uint8_t)*buffer8++; constructedSample <<= 8;
                        constructedSample |= (uint8_t)*buffer8++;
                        
                        // Convert to 32-bit sample scaling
                        channelBuffers32[channel][wideSample] = (long)((constructedSample << 8) | (constructedSample & 0x000000ff));
                    }
                }
                
                result = lame_encode_buffer_long2(_lame, channelBuffers32[0], channelBuffers32[1], frameCount, buffer, bufferLen);
                
                break;
                
            case 32:
                channelBuffers32 = (long **)channelBuffers;
                
                for(channel = 0; channel < chunk->mBuffers[0].mNumberChannels; ++channel) {
                    channelBuffers32[channel] = calloc(frameCount, sizeof(long));
                    NSAssert(NULL != channelBuffers32[channel], NSLocalizedStringFromTable(@"Unable to allocate memory.", @"Exceptions", @""));
                }
                
                buffer32 = chunk->mBuffers[0].mData;
                for(wideSample = sample = 0; wideSample < frameCount; ++wideSample) {
                    for(channel = 0; channel < chunk->mBuffers[0].mNumberChannels; ++channel, ++sample) {
                        channelBuffers32[channel][wideSample] = (long)OSSwapBigToHostInt32(buffer32[sample]);
                    }
                }
                
                result = lame_encode_buffer_long2(_lame, channelBuffers32[0], channelBuffers32[1], frameCount, buffer, bufferLen);
                
                break;
                
            default:
                @throw [NSException exceptionWithName:@"IllegalInputException" reason:@"Sample size not supported" userInfo:nil];
                break;
        }
        
        NSAssert(0 <= result, NSLocalizedStringFromTable(@"LAME encoding error.", @"Exceptions", @""));
        
        numWritten = fwrite(buffer, sizeof(unsigned char), result, _out);
        NSAssert(numWritten == result, NSLocalizedStringFromTable(@"Unable to write to the output file.", @"Exceptions", @""));
    }
    
    @finally {
        for(channel = 0; channel < chunk->mBuffers[0].mNumberChannels; ++channel) {
            free(channelBuffers[channel]);
        }
        free(channelBuffers);
        
        free(buffer);
    }
}

- (void)finishEncode {
    
    unsigned char	*buf;
    int				bufSize;
    
    int				result;
    size_t			numWritten;
    
    @try {
        buf = NULL;
        
        // Allocate the MP3 buffer using LAME guide for size
        bufSize		= 7200;
        buf			= (unsigned char *) calloc(bufSize, sizeof(unsigned char));
        NSAssert(NULL != buf, NSLocalizedStringFromTable(@"Unable to allocate memory.", @"Exceptions", @""));
        
        // Flush the mp3 buffer
        result = lame_encode_flush(_lame, buf, bufSize);
        NSAssert(-1 != result, NSLocalizedStringFromTable(@"LAME was unable to flush the buffers.", @"Exceptions", @""));
        
        // And write any frames it returns
        numWritten = fwrite(buf, sizeof(unsigned char), result, _out);
        NSAssert(numWritten == result, NSLocalizedStringFromTable(@"Unable to write to the output file.", @"Exceptions", @""));
    }
    
    @finally {
        free(buf);
    }
}

#pragma mark -
#pragma mark Helper Methodes

+ (NSArray *)supportedAudioExtensions {
    
    return getCoreAudioExtensions();
}

NSError *
NewNSErrorFromException(NSException * exc)
{
    NSMutableDictionary * info = [NSMutableDictionary dictionary];
    [info setValue:exc.name forKey:@"MONExceptionName"];
    [info setValue:exc.reason forKey:@"MONExceptionReason"];
    [info setValue:exc.callStackReturnAddresses forKey:@"MONExceptionCallStackReturnAddresses"];
    [info setValue:exc.callStackSymbols forKey:@"MONExceptionCallStackSymbols"];
    [info setValue:exc.userInfo forKey:@"MONExceptionUserInfo"];
    
    return [[NSError alloc] initWithDomain:AudioConverterErrorDomain
                                      code:ACErrorUnknown
                                  userInfo:info];
}

#pragma mark -
@end
