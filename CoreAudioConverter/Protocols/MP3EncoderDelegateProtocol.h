/*
 *  MP3EncoderDelegateProtocol.h
 *  CoreAudioConverter
 *
 *  Copyright © 2016 Simon Gaus <simon.cay.gaus@gmail.com>
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

@import Cocoa;

NS_ASSUME_NONNULL_BEGIN

/**
 The quality setting for the MP3Encoder.
 
 This variable is used by lame to select a algorithm.
 
 True quality is determined by the bitrate but this variable will effect quality by selecting expensive or cheap algorithms.
 */
typedef NS_ENUM(NSUInteger, LAME_QUALITY) {
    
    /// max. quality, slow
    LAME_QUALITY_VERY_HIGH = 1,
    /// near-best quality, not too slow
    LAME_QUALITY_HIGH = 2,
    /// good quality, fast
    LAME_QUALITY_GOOD = 5,
    /// ok quality, really fast
    LAME_QUALITY_LOW = 7
};
/**
 
 The constant bitrate we should use to encode the output file.
 
 */
typedef NS_ENUM(NSUInteger, CONSTANT_BITRATE) {
    /// 320 kbit/s
    CONSTANT_BITRATE_VERY_HIGH = 320,
    /// 256 kbit/s
    CONSTANT_BITRATE_HIGH = 256,
    /// 192 kbit/s
    CONSTANT_BITRATE_GOOD = 192,
    /// 128 kbit/s
    CONSTANT_BITRATE_LOW = 128,
    /// 64 kbit/s
    CONSTANT_BITRATE_AUDIOBOOK = 64
};

/**
 The delegate of a MP3Encoder object must adopt the MP3EncoderDelegate protocol.
 
 Required methods of the protocol allow the delegate to decide on the quality and bitrate to use for encoding and to indicate if the encoding should cancel.
 */
@protocol MP3EncoderDelegate <NSObject>

///------------------------
/// @name Required Methodes
///------------------------

@required
/**
 
 This variable is used by lame to select an algorithm.
 
 True quality is determined by the bitrate but this variable will effect the quality by selecting expensive or cheap algorithms.
 
 @return The LAME_QUALITY for the MP3Encoder.
 
 */
- (LAME_QUALITY)quality;
/**
 
 This variable is used by lame to select the constant bitrate.
 
 @return The CONSTANT_BITRATE the MP3Encoder should use for encoding.
 
 */
- (CONSTANT_BITRATE)bitrate;
/**
 
 This variable is used to check if the encoder should cancle the encoding.
 
 @return Yes if the encoding should be stopped, otherwise NO.
 
 */
- (BOOL)cancel;

@end
NS_ASSUME_NONNULL_END
