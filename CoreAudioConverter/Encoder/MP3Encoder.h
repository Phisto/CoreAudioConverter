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
 
 An MP3Encoder object can convert various audio file formats to MPEG Audio Layer III,
 more commonly referred to as MP3.
 
 */

NS_ASSUME_NONNULL_BEGIN

@interface MP3Encoder : NSObject

///----------------------
/// @name Inititalization
///----------------------

/**
 
 Returns an MP3Encoder object initialized with a given delegate.
 
 This is the designated initializer for MP3Encoder.
 
 @see MP3EncoderDelegate
 
 @param aDelegate The delegate.
 
 @return An MP3Encoder object initialized with aDelegate. If aDelegate is nil or lame coulden't be initialized, returns nil.
 */
- (nullable instancetype)initWithDelegate:(NSObject<MP3EncoderDelegate> *)aDelegate NS_DESIGNATED_INITIALIZER;

///------------------------
/// @name Encoding Methodes
///------------------------

/**
 
 Converts an given audio file to the MP3 format.
 
 @see EncoderTask
 
 @param task The EncoderTask to process.
 
 @param error The error that occurred while trying to convert the provided EncoderTask.
 
 @return YES if the encoding was successfull, otherwise NO.
 */
- (BOOL)executeTask:(EncoderTask *)task error:(NSError * _Nullable *)error;

@end
NS_ASSUME_NONNULL_END
