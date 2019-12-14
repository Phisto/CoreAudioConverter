/*
 *  CircularBuffer.h
 *  CoreAudioConverter
 *
 *  Copyright © 2015-2019 Simon Gaus <simon.cay.gaus@gmail.com>
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
///-------------------------------------------
/// @name Inititalization
///-------------------------------------------

/**
 
 Initializes an CircularBuffer object with a given size.
 
 @param size The size of the buffer.
 
 @return An initialized CircularBuffer object, or nil.
 
 */
- (nullable instancetype)initWithSize:(NSUInteger)size NS_DESIGNATED_INITIALIZER;



#pragma mark - Methodes
///--------------------------------
/// @name Methodes
///--------------------------------

/**
 
 Returns the number of bytes with valid data in the CircularBuffer. 
 
 Max. value is the size of the CircularBuffer.
 
 @return The number of bytes available.
 
 */
- (NSUInteger)bytesAvailable;
/**
 
 Returns the number of bytes that can be written to the buffer before its full.
 
 @return The free space in bytes.
 
 */
- (NSUInteger)freeSpaceAvailable;



#pragma mark - Read
///--------------------------
/// @name Read
///--------------------------

/**
 
 This method will copy as many bytes from the CircularBuffer into the buffer as available, with a maximum size specified by byteCount, and return the number of bytes copied to the buffer.
 
 @param buffer The buffer to hold the data that was read from the CircularBuffer.
 
 @param byteCount The size (in bytes) of the data to fetch from the CircularBuffer.
 
 @return The number of bytes copied to the buffer.
 
 */
- (NSUInteger)getData:(void *)buffer byteCount:(NSUInteger)byteCount;



#pragma mark - Write
///---------------------------
/// @name Write
///---------------------------

/**
 
 Returns a buffer
 
 @return Returns a buffer to write to, or nil.
 
 */
- (nullable void *)exposeBufferForWriting;

/**
 
 ...
 
 @param byteCount
 
 @return void
 
 */
- (void)wroteBytes:(NSUInteger)byteCount;



@end
NS_ASSUME_NONNULL_END
