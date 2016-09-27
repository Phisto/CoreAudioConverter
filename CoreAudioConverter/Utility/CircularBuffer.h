/*
 *  CircularBuffer.h
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

@import Foundation;

/**
 
 A simple implementation of a circular (AKA ring) buffer
 
 */

NS_ASSUME_NONNULL_BEGIN

@interface CircularBuffer : NSObject
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
