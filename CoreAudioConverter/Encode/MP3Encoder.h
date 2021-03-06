/*
 *  MP3Encoder.h
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

@import Cocoa;

@class EncoderTask;

#import "MP3EncoderDelegateProtocol.h"

/**
 
 An MP3Encoder object can convert various audio file formats to MPEG Audio Layer III,
 more commonly referred to as MP3.
 
 */

NS_ASSUME_NONNULL_BEGIN

@interface MP3Encoder : NSObject

#pragma mark - Initializing an encoder object
///-------------------------------------------------------------------
/// @name Initializing an encoder object
///-------------------------------------------------------------------

/**
 @brief Returns an MP3Encoder object initialized with the given delegate. This is the designated initializer.
 @param aDelegate The encoders delegate.
 @return A MP3Encoder object initialized with aDelegate. If aDelegate is nil or lame coulden't be initialized, returns nil.
 */
- (nullable instancetype)initWithDelegate:(NSObject<MP3EncoderDelegate> *)aDelegate NS_DESIGNATED_INITIALIZER;


#pragma mark - Executing an encoder task
///-----------------------------------------------------------
/// @name Executing an encoder task
///-----------------------------------------------------------

/**
 @brief Executes the given encoder task.
 @param task The encoder task to execute.
 @param error May contain an error, desccribing the failure reason.
 @return YES if the executing was successfull, otherwise NO.
 */
- (BOOL)executeTask:(EncoderTask *)task error:(NSError * _Nullable *)error;


@end

NS_ASSUME_NONNULL_END
