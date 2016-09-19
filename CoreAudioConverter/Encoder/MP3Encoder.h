/*
 *  $Id$
 *
 *  Copyright (C) 2005 - 2007 Stephen F. Booth <me@sbooth.org>
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

@class EncoderTask, XPCEncoderTask;

NS_ASSUME_NONNULL_BEGIN
#pragma mark - Protocol Declaration
/**
 
 */
@protocol MP3EncoderDelegate <NSObject>
enum {
    ///max. quality, slow
    LAME_QUALITY_VERY_HIGH = 1,
    ///near-best quality, not too slow
    LAME_QUALITY_HIGH = 2,
    ///good quality, fast
    LAME_QUALITY_GOOD = 5,
    ///ok quality, really fast
    LAME_QUALITY_LOW = 7
};
/**
 * @typedef LAME_CONSTANT_BITRATE
 * @brief The quality setting for the MP3 encoder (lame) .
 */
typedef int LAME_QUALITY;
enum {
    ///320 kbit/s
    CONSTANT_BITRATE_VERY_HIGH = 320,
    ///256 kbit/s
    CONSTANT_BITRATE_HIGH = 256,
    ///192 kbit/s
    CONSTANT_BITRATE_GOOD = 192,
    ///128 kbit/s
    CONSTANT_BITRATE_LOW = 128,
    ///128 kbit/s
    CONSTANT_BITRATE_AUDIOBOOK = 64
};
/**
 @typedef CONSTANT_BITRATE
 @brief The constant bitrate we should use to encode the output file.
 */
typedef int CONSTANT_BITRATE;
@required
/**
 
 */
- (LAME_QUALITY)quality;
/**
 
 */
- (CONSTANT_BITRATE)bitrate;
/**
 
 */
- (BOOL)cancel;

@end
#pragma mark - Class Declaration
/**
 
 */
@interface MP3Encoder : NSObject
/**
 @param aDelegate
 @return
 */
- (nullable instancetype)initWithDelegate:(NSObject<MP3EncoderDelegate> *)aDelegate;
/**
 @param dict
 @param error
 @return
 */
- (BOOL)executeTask:(EncoderTask *)task error:(NSError * _Nullable *)error;

- (BOOL)executeXPCTask:(XPCEncoderTask *)task error:(NSError * __autoreleasing *)error;

//- (BOOL)tagTask:(EncoderTask *)task error:(NSError * _Nullable *)error;

@end
NS_ASSUME_NONNULL_END
