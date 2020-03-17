/*
 *  MP3EncoderDelegateProtocol.h
 *  CoreAudioConverter
 *
 *  Copyright © 2016 Simon Gaus <simon.cay.gaus@gmail.com>
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

NS_ASSUME_NONNULL_BEGIN

/**
 @brief The quality setting for the MP3Encoder.
 @discussion This variable is used by lame to select a algorithm. True quality is determined by the bitrate but this variable will effect quality by selecting expensive or cheap algorithms.
 */
typedef NS_ENUM(NSUInteger, LAME_QUALITY) {
    
    /// max. quality, slow
    LAME_QUALITY_MAX = 0,
    /// very high quality, slow
    LAME_QUALITY_VERY_HIGH = 1,
    /// near-best quality, not too slow
    LAME_QUALITY_HIGH = 2,
    /// good quality, fast
    LAME_QUALITY_GOOD = 5,
    /// ok quality, really fast
    LAME_QUALITY_LOW = 7,
    /// min quality, really fast
    LAME_QUALITY_MIN = 9
};

/**
 @brief The constant bitrate we should use to encode the output file.
 */
typedef NS_ENUM(NSUInteger, CONSTANT_BITRATE) {
    
    CONSTANT_BITRATE_320        = 320,
    CONSTANT_BITRATE_256        = 256,
    CONSTANT_BITRATE_224        = 224,
    CONSTANT_BITRATE_192        = 192,
    CONSTANT_BITRATE_160        = 160,
    CONSTANT_BITRATE_128        = 128
    CONSTANT_BITRATE_112        = 112,
    CONSTANT_BITRATE_96         = 96,
    CONSTANT_BITRATE_80         = 80,
    CONSTANT_BITRATE_64         = 64,
    CONSTANT_BITRATE_56         = 56,
    CONSTANT_BITRATE_48         = 48,
    CONSTANT_BITRATE_40         = 40,
    CONSTANT_BITRATE_32         = 32,
    CONSTANT_BITRATE_VERY_HIGH  = CONSTANT_BITRATE_320,
    CONSTANT_BITRATE_HIGH       = CONSTANT_BITRATE_256,
    CONSTANT_BITRATE_GOOD       = CONSTANT_BITRATE_192,
    CONSTANT_BITRATE_OK         = CONSTANT_BITRATE_160,
    CONSTANT_BITRATE_LOW        = CONSTANT_BITRATE_128,
    CONSTANT_BITRATE_AUDIOBOOK  = CONSTANT_BITRATE_64,
    CONSTANT_BITRATE_MIN        = CONSTANT_BITRATE_32
};

/**
 
 The delegate of a MP3Encoder object must adopt the MP3EncoderDelegate protocol.
 
 Required methods of the protocol allow the delegate to decide on the quality and bitrate to use for encoding and to indicate if the encoding should cancel.
 
 */
@protocol MP3EncoderDelegate <NSObject>
@required
#pragma mark - Required Methodes
///----------------------------------------------
/// @name Required Methodes
///----------------------------------------------

/**
 @brief This variable is used by lame to select an algorithm.
 @discussion True quality is determined by the bitrate but this variable will effect the quality by selecting expensive or cheap algorithms.
 @return The LAME_QUALITY for the MP3Encoder.
 */
- (LAME_QUALITY)quality;

/**
 @brief This variable is used by lame to select the constant bitrate.
 @return The CONSTANT_BITRATE the MP3Encoder should use for encoding.
 */
- (CONSTANT_BITRATE)bitrate;

/**
 @brief This variable is used to check if the encoder should cancle the encoding.
 @return Yes if the encoding should be stopped, otherwise NO.
 */
- (BOOL)cancel;


@end

NS_ASSUME_NONNULL_END
