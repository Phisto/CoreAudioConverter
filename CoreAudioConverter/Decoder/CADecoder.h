/*
 *  CADecoder.h
 *  CoreAudioConverter
 *
 *  Copyright © 2015-2016 Simon Gaus <simon.cay.gaus@gmail.com>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#import "CoreAudioConverterErrorConstants.h"

@import Cocoa;
@import CoreAudio;

@class CircularBuffer;

/**
 
 The Core Audio Decoder can decode audio files with the suffix .aif | .aiff | .m4a | .aac .
 
 */

NS_ASSUME_NONNULL_BEGIN

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
 NSError *error;
 CADecoder *decoder = [CADecoder decoderForFile:fileUrl error:&error];
 if (!decoder) {
    // Handle error
    
 }
 // do stuff with the decoder...
 @endcode
 
 @param fileUrl of the file to decode.
 
 @param error The error reference.
 
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
