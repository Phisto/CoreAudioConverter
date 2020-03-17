/*
 *  MP3Encoder.m
 *  CoreAudioConverter
 *
 *  Copyright © 2016-2019 Simon Gaus <simon.cay.gaus@gmail.com>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU Lesser General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public License
 *  along with this library.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

#import "MP3Encoder.h"

@import AudioFileTagger; // for MP3Tagger

/* LAME encoding */
@import Lame;

/* Encoders Task */
#import "EncoderTask.h"

/* Core Audio Decoder */
#import "CADecoder.h"

/* Check access rights for files&folders */
#import "NSFileManager+FileAccess.h"

/* Logging */
#import "CACDebug.h"

/* Custom Error */
#import "CACError.h"

#pragma mark - CONSTANTS


/// The file extension of a MP3 file.
static NSString * const kFileExtension = @"mp3";
/// The number of bits for checking the min. disc space.
static NSUInteger const kMinFreeDiskSpace = 100000000;


#pragma mark - CATEGORIES


@interface MP3Encoder (/* Private */)

@property (nonatomic, readwrite) FILE *out;
@property (nonatomic, readwrite) UInt32 sourceBitsPerChannel;
@property (nonatomic, readwrite) lame_global_flags *gfp;
@property (nonatomic, assign) NSObject<MP3EncoderDelegate> *delegate;
@property (nonatomic, strong) NSURL *secureURLIn;
@property (nonatomic, strong) NSURL *secureURLOut;
@property (nonatomic, readwrite) BOOL fileProperlyEncoded;
@property (nonatomic, readonly) NSFileManager *fileManager;

@end


#pragma mark - IMPLEMENTATION


@implementation MP3Encoder
#pragma mark - Initializing an encoder object

- (nullable instancetype)initWithDelegate:(NSObject<MP3EncoderDelegate> *)aDelegate {
	
    self = [super init];
    if(self) {
        
        if (!aDelegate) {
            return nil;
        }
        _delegate = aDelegate;
        
		_gfp = lame_init();
        if (_gfp == NULL) {
            return nil;
        }
	}
	
	return self;
}

- (instancetype)init {
    NSAssert(false, @"Unavailable, use `-initWithDelegate:` instead.");
    return [self initWithDelegate:(NSObject<MP3EncoderDelegate> *)[NSObject new]];
}

- (void)dealloc {
    // free lame
    lame_close(_gfp);
}

#pragma mark - API Methodes

- (BOOL)executeTask:(EncoderTask *)task error:(NSError * __autoreleasing *)error {
    
    if ([self.delegate cancel]) return YES;
    
    FILE							*file							= NULL;
	int								result;
	AudioBufferList					bufferList;
	ssize_t							bufferLen						= 0;
	UInt32							bufferByteSize					= 0;
	SInt64							totalFrames, framesToRead;
	UInt32							frameCount;
    self.fileProperlyEncoded                                        = NO;
    
	@try {
        
		bufferList.mBuffers[0].mData = NULL;

        // prepare lame settings
        [self parseSettings];
        
		// Setup input url
        self.secureURLIn = task.inputURL;
        self.secureURLOut = task.tempURL;
        
        // start accessing it
        if (![self.secureURLIn startAccessingSecurityScopedResource] &&
            ![self.fileManager path:self.secureURLIn.path isAccessibleFor:ReadAccess]){
            
            NSString *filePath = self.secureURLIn.path;
            NSError *accessError = cac_error(CACFilePermissionDenied, filePath);
            if (error != NULL) *error = accessError;
            return NO;
        }
        
        // check if there is enough disc space to write the output file
        if (![self enoughFreeSpaceToConvert:self.secureURLOut.URLByDeletingLastPathComponent]) {

            NSString *filePath = self.secureURLIn.lastPathComponent;
            NSError *discSpaceError = cac_error(CACFilePermissionDenied, filePath);
            if (error != NULL) *error = discSpaceError;
            return NO;
        }
        
		// Create the appropriate kind of decoder
        NSError *decoderError = nil;
        CADecoder *decoder = [CADecoder decoderForFile:_secureURLIn error:&decoderError];
        if (!decoder) {
            CACLog(CACDebugLevelError, @"Unable to load decoder.");
            if (decoderError && error != NULL) *error = decoderError;
            return NO;
        }

        if ([decoder pcmFormat].mChannelsPerFrame > 2) {
            CACLog(CACDebugLevelError, @"LAME only supports one or two channel input.");
            NSString *userInfo = [NSString stringWithFormat:@"File:%@|Channels:%u", _secureURLIn.path, (unsigned int)[decoder pcmFormat].mChannelsPerFrame];
            if (error != NULL) *error = cac_error(CACTooMayChannels, userInfo);
            return NO;
        }
        
		_sourceBitsPerChannel	= [decoder pcmFormat].mBitsPerChannel;
		totalFrames				= [decoder totalFrames];
		framesToRead			= totalFrames;
		
		// Set up the AudioBufferList
		bufferList.mNumberBuffers					= 1;
		bufferList.mBuffers[0].mData				= NULL;
		bufferList.mBuffers[0].mNumberChannels		= [decoder pcmFormat].mChannelsPerFrame;
		
		// Allocate the buffer that will hold the interleaved audio data
		bufferLen									= 1024;
		switch([decoder pcmFormat].mBitsPerChannel) {
			
			case 8:				
			case 24:
				bufferList.mBuffers[0].mData			= calloc(bufferLen, sizeof(int8_t));
				bufferList.mBuffers[0].mDataByteSize	= (UInt8)bufferLen * sizeof(int8_t);
				break;
				
			case 16:
				bufferList.mBuffers[0].mData			= calloc(bufferLen, sizeof(int16_t));
				bufferList.mBuffers[0].mDataByteSize	= (UInt16)bufferLen * sizeof(int16_t);
				break;
				
			case 32:
				bufferList.mBuffers[0].mData			= calloc(bufferLen, sizeof(int32_t));
				bufferList.mBuffers[0].mDataByteSize	= (UInt32)bufferLen * sizeof(int32_t);
				break;
				
            default: {
                NSString *userInfo = [NSString stringWithFormat:@"File:%@|SampleSize:%u", _secureURLIn.lastPathComponent, (unsigned int)[decoder pcmFormat].mBitsPerChannel];
                NSError *newError = cac_error(CACUnsupportedSampleSize, userInfo);
                if (error != NULL) *error = newError;
                return NO;
            }
		}
		
		bufferByteSize = bufferList.mBuffers[0].mDataByteSize;
        if (bufferList.mBuffers[0].mData == NULL) {
            NSError *newError = cac_error(CACMemoryAllocationFailed, nil);
            if (error != NULL) *error = newError;
            return NO;
        }
		
		// Initialize the LAME encoder
		lame_set_num_channels(_gfp, [decoder pcmFormat].mChannelsPerFrame);
		lame_set_in_samplerate(_gfp, [decoder pcmFormat].mSampleRate);
		
		result = lame_init_params(_gfp);
        if (result != noErr) {
            NSString *userInfo = [NSString stringWithFormat:@"%i", result];
            NSError *newError = cac_error(CACLameSettingsInitFailed, userInfo);
            if (error != NULL) *error = newError;
            return NO;
        }
        
        // touch output file (dont cancle here, because of posix file permissions)
        [self touchOutputFile:_secureURLOut];
   
		// Open the output file
		_out = fopen(_secureURLOut.fileSystemRepresentation, "w");
        if (_out == NULL) {
            NSString *userInfo = [NSString stringWithFormat:@"%s", _secureURLOut.fileSystemRepresentation];
            NSError *newError = cac_error(CACOutputAccessFailed, userInfo);
            if (error != NULL) *error = newError;
            return NO;
        }
		
		// Iterate over the data and encode it
		for(;;) {
            
            // check if we should cancel
            if ([self.delegate cancel]) return YES;
			
			// Set up the buffer parameters
			bufferList.mBuffers[0].mNumberChannels	= [decoder pcmFormat].mChannelsPerFrame;
			bufferList.mBuffers[0].mDataByteSize	= bufferByteSize;
			frameCount								= bufferList.mBuffers[0].mDataByteSize / [decoder pcmFormat].mBytesPerFrame;
			
			// Read a chunk of PCM input
			frameCount = [decoder readAudio:&bufferList frameCount:frameCount];
			
			// We're finished (or decoder failed) if no frames were returned
			if(frameCount == 0) {
				break;
			}
			
			// Encode the PCM data
            NSError *chunkError = nil;
            BOOL result = [self encodeChunk:&bufferList frameCount:frameCount error:&chunkError];
            if (!result) {
                if (chunkError) *error = chunkError;
                return NO;
            }
		}
        
		// Flush the last MP3 frames (maybe)
        NSError *flushError;
        if (![self finishEncodeWithError:&flushError]) {
            if (flushError && error != NULL) *error = flushError;
            return NO;
        }
		
		// Close the output file
		result = fclose(_out);
        if (result != noErr) {
            NSError *newError = cac_error(CACOutputClosingFailed, [_secureURLOut.path copy]);
            if (error != NULL) *error = newError;
            return NO;
        }
        _out = NULL;
		
		// Write the Xing VBR tag
		file = fopen(_secureURLOut.fileSystemRepresentation, "r+");
        if (file == NULL) {
            
            NSError *newError = cac_error(CACOutputAccessFailed, _secureURLOut.path);
            if (error != NULL) *error = newError;
            return NO;
        }
        // hmmm...
		lame_mp3_tags_fid(_gfp, file);
        
        self.fileProperlyEncoded = YES;
        
        return YES;
	}
    
	@catch(NSException *exception) {
        
        CACLog(CACDebugLevelError, @"Exception during encoding:%@", exception);
	}
	
	@finally {

		NSException *exception;
				
		// Close the output file if not already closed
		if(NULL != _out && EOF == fclose(_out)) {
			exception = [NSException exceptionWithName:@"IOException"
												reason:NSLocalizedStringFromTable(@"Unable to close the output file.", @"Exceptions", @"") 
											  userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:errno], [NSString stringWithCString:strerror(errno) encoding:NSASCIIStringEncoding], nil] forKeys:[NSArray arrayWithObjects:@"errorCode", @"errorString", nil]]];
			CACLog(CACDebugLevelError, @"%@", exception);
		}

		// And close the other output file
		if(NULL != file && EOF == fclose(file)) {
			exception = [NSException exceptionWithName:@"IOException" 
												reason:NSLocalizedStringFromTable(@"Unable to close the output file.", @"Exceptions", @"")
											  userInfo:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:errno], [NSString stringWithCString:strerror(errno) encoding:NSASCIIStringEncoding], nil] forKeys:[NSArray arrayWithObjects:@"errorCode", @"errorString", nil]]];
			CACLog(CACDebugLevelError, @"%@", exception);
		}		

        // free buffer
		free(bufferList.mBuffers[0].mData);
        ///!!!: Implement tagger failing handling ...
        // the file was properly encoded
        if (self.fileProperlyEncoded) {
            
            Metadata *meta = [[Metadata alloc] initWithMetadataFromFile:_secureURLIn];
            if (meta) {
                
                MP3Tagger *tagger = [MP3Tagger taggerWithMetadata:meta];
                
                if (![tagger tagFile:_secureURLOut]) {
                    NSLog(@"Failed to tag file: %@", _secureURLOut.lastPathComponent);
                }
            } else {
                NSLog(@"Failed to extract metadata from file: %@", _secureURLIn.lastPathComponent);
            }
        }
        
        [_secureURLIn stopAccessingSecurityScopedResource];
    }
}

#pragma mark - Helper Methodes

- (BOOL)enoughFreeSpaceToConvert:(NSURL *)destFolder {
    return ([self availableDiscSpace:destFolder] > kMinFreeDiskSpace);
}

- (unsigned long long)availableDiscSpace:(NSURL *)folderPath {
    
    NSString *path = folderPath.path;
    if (!path) {
        CACLog(CACDebugLevelError, @"Failed to get temporary directory.");
        return 0;
    }
    
    NSError *error = nil;
    NSDictionary *attr = [[NSFileManager defaultManager] attributesOfFileSystemForPath:path error:&error];
    if (!attr) {
        if (error) {
            CACLog(CACDebugLevelError, @"%@", error.localizedDescription);
        }
        return 0;
    }
    
    NSNumber *space = [attr valueForKey:NSFileSystemFreeSize];
    if (!space) {
        
        CACLog(CACDebugLevelError, @"Failed to get available disk space.");
        return 0;
    }
    
    return space.unsignedLongLongValue;
}

#pragma mark -

- (void)parseSettings {
    // Set encoding properties
    lame_set_mode(_gfp, JOINT_STEREO);
    // quality
    lame_set_quality(_gfp, (int)[self.delegate quality]);
    // Target is bitrate
    lame_set_brate(_gfp, (int)[self.delegate bitrate]);
}

- (BOOL)encodeChunk:(const AudioBufferList *)chunk
         frameCount:(UInt32)frameCount
              error:(NSError * __autoreleasing *)error {
    
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
        if (buffer == NULL) {
            CACLog(CACDebugLevelError, @"Unable to allocate memory.");
            NSError *newError = cac_error(CACMemoryAllocationFailed, nil);
            if (error != NULL) *error = newError;
            return NO;
        }
        
        // Allocate channel buffers for sample de-interleaving
        channelBuffers = calloc(chunk->mBuffers[0].mNumberChannels, sizeof(void *));
        if (channelBuffers == NULL) {
            CACLog(CACDebugLevelError, @"Unable to allocate memory.");
            NSError *newError = cac_error(CACMemoryAllocationFailed, nil);
            if (error != NULL) *error = newError;
            return NO;
        }
        
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
                    if (channelBuffers16[channel] == NULL) {
                        
                        CACLog(CACDebugLevelError, @"Unable to allocate memory.");
                        NSError *newError = cac_error(CACMemoryAllocationFailed, nil);
                        if (error != NULL) *error = newError;
                        return NO;
                    }
                }
                
                buffer8 = chunk->mBuffers[0].mData;
                for(wideSample = sample = 0; wideSample < frameCount; ++wideSample) {
                    for(channel = 0; channel < chunk->mBuffers[0].mNumberChannels; ++channel, ++sample) {
                        // Rescale values to short
                        channelBuffers16[channel][wideSample] = (short)(((buffer8[sample] << 8) & 0xFF00) | (buffer8[sample] & 0xFF));
                    }
                }
                
                result = lame_encode_buffer(_gfp, channelBuffers16[0], channelBuffers16[1], frameCount, buffer, bufferLen);
                
                break;
                
            case 16:
                channelBuffers16 = (short **)channelBuffers;
                
                for(channel = 0; channel < chunk->mBuffers[0].mNumberChannels; ++channel) {
                    channelBuffers16[channel] = calloc(frameCount, sizeof(short));
                    if (channelBuffers16[channel] == NULL) {
                        
                        CACLog(CACDebugLevelError, @"Unable to allocate memory.");
                        NSError *newError = cac_error(CACMemoryAllocationFailed, nil);
                        if (error != NULL) *error = newError;
                        return NO;
                    }
                }
                
                buffer16 = chunk->mBuffers[0].mData;
                for(wideSample = sample = 0; wideSample < frameCount; ++wideSample) {
                    for(channel = 0; channel < chunk->mBuffers[0].mNumberChannels; ++channel, ++sample) {
                        channelBuffers16[channel][wideSample] = (short)OSSwapBigToHostInt16(buffer16[sample]);
                    }
                }
                
                result = lame_encode_buffer(_gfp, channelBuffers16[0], channelBuffers16[1], frameCount, buffer, bufferLen);
                
                break;
                
            case 24:
                channelBuffers32 = (long **)channelBuffers;
                
                for(channel = 0; channel < chunk->mBuffers[0].mNumberChannels; ++channel) {
                    channelBuffers32[channel] = calloc(frameCount, sizeof(long));
                    if (channelBuffers32[channel] == NULL) {
                        
                        CACLog(CACDebugLevelError, @"Unable to allocate memory.");
                        NSError *newError = cac_error(CACMemoryAllocationFailed, nil);
                        if (error != NULL) *error = newError;
                        return NO;
                    }
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
                
                result = lame_encode_buffer_long2(_gfp, channelBuffers32[0], channelBuffers32[1], frameCount, buffer, bufferLen);
                
                break;
                
            case 32:
                channelBuffers32 = (long **)channelBuffers;
                
                for(channel = 0; channel < chunk->mBuffers[0].mNumberChannels; ++channel) {
                    channelBuffers32[channel] = calloc(frameCount, sizeof(long));
                    if (channelBuffers32[channel] == NULL) {
                        CACLog(CACDebugLevelError, @"Unable to allocate memory.");
                        NSError *newError = cac_error(CACMemoryAllocationFailed, nil);
                        if (error != NULL) *error = newError;
                        return NO;
                    }
                }
                
                buffer32 = chunk->mBuffers[0].mData;
                for(wideSample = sample = 0; wideSample < frameCount; ++wideSample) {
                    for(channel = 0; channel < chunk->mBuffers[0].mNumberChannels; ++channel, ++sample) {
                        channelBuffers32[channel][wideSample] = (long)OSSwapBigToHostInt32(buffer32[sample]);
                    }
                }
                
                result = lame_encode_buffer_long2(_gfp, channelBuffers32[0], channelBuffers32[1], frameCount, buffer, bufferLen);
                
                break;
                
            default:
                CACLog(CACDebugLevelError, @"Sample size not supported");
                NSString *userInfo = [NSString stringWithFormat:@"File:%@|SampleSize:%u", _secureURLIn.path, (unsigned int)_sourceBitsPerChannel];
                NSError *newError = cac_error(CACUnsupportedSampleSize, userInfo);
                if (error != NULL) *error = newError;
                return NO;
                break;
        }
        
        if (result == -1) {
            CACLog(CACDebugLevelError, @"LAME encoding error.");
            NSError *newError = cac_error(CACUnknownLAMEError, _secureURLIn.path);
            if (error != NULL) *error = newError;
            return NO;
        }
        
        numWritten = fwrite(buffer, sizeof(unsigned char), result, _out);
        if (result != numWritten) {
            CACLog(CACDebugLevelError, @"Unable to write to the output file.");
            NSError *newError = cac_error(CACOutputAccessFailed, _secureURLOut.path);
            if (error != NULL) *error = newError;
            return NO;
        }
        
        return YES;
    }
    
    @finally {
        for(channel = 0; channel < chunk->mBuffers[0].mNumberChannels; ++channel) {
            free(channelBuffers[channel]);
        }
        free(channelBuffers);
        free(buffer);
    }
}

- (BOOL)finishEncodeWithError:(NSError * __autoreleasing *)error {
    
    unsigned char	*buf;
    int				bufSize;
    
    int				result;
    size_t			numWritten;
    
    @try {
        buf = NULL;
        
        // Allocate the MP3 buffer using LAME guide for size
        bufSize		= 7200;
        buf			= (unsigned char *) calloc(bufSize, sizeof(unsigned char));
        if (buf == NULL) {
            CACLog(CACDebugLevelError, @"Unable to allocate memory.");
            NSError *newError = cac_error(CACMemoryAllocationFailed, nil);
            if (error != NULL) *error = newError;
            return NO;
        }
        
        // Flush the mp3 buffer
        result = lame_encode_flush(_gfp, buf, bufSize);
        if (result == -1) {
            CACLog(CACDebugLevelError, @"LAME was unable to flush the buffers.");
            NSError *newError = cac_error(CACLameBufferFlushFailed, _secureURLIn.path);
            if (error != NULL) *error = newError;
            return NO;
        }
        
        // And write any frames it returns
        numWritten = fwrite(buf, sizeof(unsigned char), result, _out);
        if (result != numWritten) {
            CACLog(CACDebugLevelError, @"Unable to write to the output file.");
            NSError *newError = cac_error(CACOutputAccessFailed, _secureURLOut.path);
            if (error != NULL) *error = newError;
            return NO;
        }
        return YES;
    }
    
    @finally {
        free(buf);
    }
}

- (BOOL)touchOutputFile:(NSURL *)outputURL {
    
    NSNumber		*permissions	= [NSNumber numberWithUnsignedLong:S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH];
    NSDictionary	*attributes		= [NSDictionary dictionaryWithObject:permissions forKey:NSFilePosixPermissions];
    BOOL result = [[NSFileManager defaultManager] createFileAtPath:outputURL.path
                                                          contents:nil
                                                        attributes:attributes];
    return result;
}

#pragma mark - Lazy/Getter

- (NSFileManager *)fileManager {
    return [NSFileManager defaultManager];
}

#pragma mark -
@end
