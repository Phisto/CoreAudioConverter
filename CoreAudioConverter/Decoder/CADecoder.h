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

/*!
 * @class CADecoder
 * @brief The Core Audio Decoder can decode audio files with the suffix .aif | .aiff | .m4a | .aac .
 */
@interface CADecoder : NSObject
#pragma mark Properties
/*!
 * @brief The format of PCM data provided by the source file.
 */
@property (nonatomic, readonly) AudioStreamBasicDescription pcmFormat;
/*!
 * @brief Returns the name of the decoders files format, for example, “16-bit, interleaved” for linear PCM.
 */
@property (nonatomic, readonly) NSString *pcmFormatDescription;
/*!
 * @brief Returns the length in sample frames of the decoders associated audio file.
 */
@property (nonatomic, readonly) SInt64 totalFrames;

#pragma mark Methodes
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
 @param NSURL of the file to decode.
 @return instancetype or nil
 */
+ (instancetype)decoderForFile:(NSURL *)fileUrl error:(NSError **)error;
/**
  Reads a chunk of PCM input and let the bufferList point to it.
  @param AudioBufferList a pointer to hold audio data chunk
  @param UInt32 position in the PCM input
  @return UInt32
 */
- (UInt32)readAudio:(AudioBufferList *)bufferList frameCount:(UInt32)frameCount;
/**
  Returns a array with supported audio extensions.
  @return NSArray
 */
NSArray * getCoreAudioExtensions();

@end
