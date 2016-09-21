/*
 *  MP3Encoder.h
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

@class EncoderTask;

#import "MP3EncoderDelegateProtocol.h"

/**
 A MP3Encoder object can convert various audio file formats to MPEG-1 and/or MPEG-2 Audio Layer III,
 more commonly referred to as MP3.
 
 It takes an EncoderTask as input.
 */

NS_ASSUME_NONNULL_BEGIN

@interface MP3Encoder : NSObject
/**
 
 @param aDelegate The delegate
 
 @return
 */
- (nullable instancetype)initWithDelegate:(NSObject<MP3EncoderDelegate> *)aDelegate;
/**
 
 @param task The tasks
 
 @param error possible error
 
 @return
 */
- (BOOL)executeTask:(EncoderTask *)task error:(NSError * _Nullable *)error;

@end
NS_ASSUME_NONNULL_END
