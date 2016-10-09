/*
 *  CircularBuffer.h
 *  CoreAudioConverter
 *
 *  Copyright © 2015-2016 Simon Gaus <simon.cay.gaus@gmail.com>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the Lesser General Public License (LGPL) as published by
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

@import Foundation;

/**
 
 A simple implementation of a circular (AKA ring) buffer.
 
 */

NS_ASSUME_NONNULL_BEGIN

@interface CircularBuffer : NSObject
#pragma mark - Inititalization
///----------------------
/// @name Inititalization
///----------------------

/**
 
 Initializes an CircularBuffer object with a given size.
 
 @param size The size of the buffer.
 
 @return An initialized CircularBuffer object, or nil.
 
 */
- (nullable instancetype)initWithSize:(NSUInteger)size NS_DESIGNATED_INITIALIZER;

#pragma mark - Methodes
///---------------
/// @name Methodes
///---------------

/**
 
 Returns the number of bytes available.
 
 @return The number of bytes available.
 
 */
- (NSUInteger)bytesAvailable;
/**
 
 Returns the free space in bytes.
 
 @return The Free space in bytes.
 
 */
- (NSUInteger)freeSpaceAvailable;
/**
 
 @param buffer
 @param byteCount
 @return
 */
- (NSUInteger)getData:(void *)buffer byteCount:(NSUInteger)byteCount;
/**
 @return
 */
- (nullable void *)exposeBufferForWriting;
/**
 @param byteCount
 */
- (void)wroteBytes:(NSUInteger)byteCount;

@end
NS_ASSUME_NONNULL_END
