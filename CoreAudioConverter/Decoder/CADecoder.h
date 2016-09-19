//
//  CADecoder.h
//  M4AtoMP3
//
//  Created by Simon Gaus on 19.09.15.
//  Copyright © 2015 Simon Gaus. All rights reserved.
//

#import "AudioConverterErrorConstants.h"

#import <Cocoa/Cocoa.h>
#import <CoreAudio/CoreAudioTypes.h>

@class CircularBuffer;

NS_ASSUME_NONNULL_BEGIN
/**
 The Core Audio Decoder can decode audio files with the suffix .aif | .aiff | .m4a | .aac .
 */
@interface CADecoder : NSObject
#pragma mark - Properties
/**
 The format of PCM data provided by the source file.
 */
@property (nonatomic, readonly) AudioStreamBasicDescription pcmFormat;
/**
 Returns the length in sample frames of the decoders associated audio file.
 */
@property (nonatomic, readonly) SInt64 totalFrames;

#pragma - mark Methodes
/**
 Creates and returns a decoder object for a specific audio file.
 
 Example usage:
 @code
 NSError *error = nil;
 CADecoder *decoder = [CADecoder decoderForFile:fileUrl error:&error];
 if (!decoder) {
    // Handle error
 }
 // do stuff with the decoder...
 @endcode
 @param fileUrl of the file to decode.
 @param error
 @return instancetype or nil
 */
+ (nullable instancetype)decoderForFile:(NSURL *)fileUrl error:(NSError **)error;
/**
 Reads a chunk of PCM input and let the bufferList point to it. Will return Zero(0) on failure.
 @param AudioBufferList a pointer to hold audio data chunk
 @param UInt32 position in the PCM input
 @return UInt32
 */
- (UInt32)readAudio:(AudioBufferList *)bufferList frameCount:(UInt32)frameCount;
/**
 Return an array of valid audio file extensions recognized by Core Audio.
 @return The supported audio extensions as strings, or nil if an error occures.
*/
+ (nullable NSArray<NSString *> *)supportedAudioExtensions;

@end
NS_ASSUME_NONNULL_END
