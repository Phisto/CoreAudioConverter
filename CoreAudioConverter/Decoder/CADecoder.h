/*
 *  CADecoder.h
 *  CoreAudioConverter
 *
 *  Copyright © 2015-2019 Simon Gaus <simon.cay.gaus@gmail.com>
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

@import Cocoa;
@import CoreAudio;

@class CircularBuffer;

/**
 
 An CADecoder object can provide audio data from audio files.
 
 Supported file formats:

 - Audio Interchange File Format
 - Apple Lossless Audio Codec
 - Advanced Audio Coding
 
 */

NS_ASSUME_NONNULL_BEGIN

@interface CADecoder : NSObject
#pragma mark - Properties
///-----------------------------------
/// @name Properties
///-----------------------------------

/**
 The format of PCM data provided by the source file.
 */
@property (nonatomic, readonly) AudioStreamBasicDescription pcmFormat;
/**
 Returns the length in sample frames of the decoders associated audio file.
 */
@property (nonatomic, readonly) SInt64 totalFrames;



#pragma mark - Inititalization
///-------------------------------------------
/// @name Inititalization
///-------------------------------------------

/**
 
 Creates and returns a decoder object for the specified audio file.
 
 Example usage:
 
    NSError *error;
    CADecoder *decoder = [CADecoder decoderForFile:fileUrl error:&error];
    if (!decoder) {
        // Handle error
    
    }
    // do stuff with the decoder...
    AudioStreamBasicDescription audioDescr = decoder.pcmFormat;
 
 
 @param fileUrl The fileURL to the file to decode.
 
 @param error The error that occurred while trying to initialize the decoder.
 
 @return An initialized CADecoder object or nil.
 
 */
+ (nullable instancetype)decoderForFile:(NSURL *)fileUrl error:(NSError **)error;



#pragma mark - Instance Methodes
///----------------------------------------------
/// @name Instance Methodes
///----------------------------------------------

/**
 
 Reads a chunk of PCM input and let the bufferList point to it.
 
 @param bufferList A pointer to hold audio data chunk
 
 @param frameCount Position in the PCM input
 
 @return Will return Zero(0) on failure.
 
 */
- (UInt32)readAudio:(AudioBufferList *)bufferList frameCount:(UInt32)frameCount;



#pragma mark - Class Methodes
///-----------------------------------------
/// @name Class Methodes
///-----------------------------------------

/**
 
 Return an array of valid audio file extensions recognized by Core Audio.
 
 @return The supported audio extensions as strings, or nil if an error occures.

 */
+ (nullable NSArray<NSString *> *)supportedAudioExtensions;



@end
NS_ASSUME_NONNULL_END
