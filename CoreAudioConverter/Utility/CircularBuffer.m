/*
 *  CircularBuffer.m
 *  CoreAudioConverter
 *
 *  Copyright © 2015-2016 Simon Gaus <simon.cay.gaus@gmail.com>
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

#import "CircularBuffer.h"

// ALog always displays output regardless of the DEBUG setting
#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

// default buffer size
#define BUFFER_INIT_SIZE 10 * 1024

@interface CircularBuffer (/* Private */)

/// the size of the buffer (buffer end in memory)
@property (nonatomic, readwrite) NSUInteger bufsize;
/// the buffer holding the data (buffer start in memory)
@property (nonatomic, readwrite) uint8_t *buffer;
/// start of valid data
@property (nonatomic, readwrite) uint8_t *readPtr;
/// end of valid data + 1
@property (nonatomic, readwrite) uint8_t *writePtr;

@end

@implementation CircularBuffer
#pragma mark - Object creation

- (nullable instancetype)init {
    
    // call designated initilaizer
    return [self initWithSize:BUFFER_INIT_SIZE];
}

- (nullable instancetype)initWithSize:(NSUInteger)size {
    
    if (size <= 0) return nil;
	
    self = [super init];
    
	if (self) {
        
		_bufsize	= size;
        
		_buffer		= (uint8_t *)calloc(_bufsize, sizeof(uint8_t));
        if (_buffer == NULL) { return nil; }
		
		_readPtr	= _buffer;
		_writePtr	= _buffer;
	}
    
	return self;
}


#pragma mark - Methode Implementation


- (NSUInteger)size { return _bufsize; }


- (NSUInteger)bytesAvailable {
    
    return (_writePtr >= _readPtr
            ?
            // read             read
            // |                 |
            // v                 v
            //+----------+      +----------+
            //|xxxxxxx   |  OR  |          |
            //+----------+      +----------+
            //        ^          ^
            //        |          |
            //       write      write
            //
            (NSUInteger)(_writePtr - _readPtr)
            :
            // write
            //  |
            //  v
            //+----------+
            //|x      xxx|
            //+----------+
            //        ^
            //        |
            //       read
            //
            [self size] - (NSUInteger)(_readPtr - _writePtr));
}


- (NSUInteger)freeSpaceAvailable {
    
    return _bufsize - [self bytesAvailable];
}


- (NSUInteger)getData:(void *)buffer byteCount:(NSUInteger)byteCount {
    
    // forgot to pass a buffer to hold the data ?
    if (buffer == NULL) return 0;

	// you want zero bytes you get zero bytes
	if(0 == byteCount) {
		return 0;
	}
	
	// more bytes are requested than available
	if(byteCount > [self bytesAvailable]) {
		byteCount = [self bytesAvailable];
	}
    // no wrapp needed
	if([self contiguousBytesAvailable] >= byteCount) {
		memcpy(buffer, _readPtr, byteCount);
		_readPtr += byteCount;
	}
    // buffer needs to wrap
	else {
		NSUInteger	blockSize		= [self contiguousBytesAvailable];
		NSUInteger	wrapSize		= byteCount - blockSize;
		
		memcpy(buffer, _readPtr, blockSize);
		_readPtr = _buffer;
		
		memcpy(buffer + blockSize, _readPtr, wrapSize);
		_readPtr += wrapSize;
	}

	return byteCount;
}


- (void)readBytes:(NSUInteger)byteCount {
	uint8_t			*limit		= _buffer + _bufsize;
	
	_readPtr += byteCount; 

	if(_readPtr > limit) {
		_readPtr = _buffer;
	}
}


- (void *)exposeBufferForWriting {
    
    BOOL erfolg = [self normalizeBuffer];
    if (!erfolg) {
        return NULL;
    }
    return _writePtr;
}


- (void)wroteBytes:(NSUInteger)byteCount {
	uint8_t			*limit		= _buffer + _bufsize;
	
	_writePtr += byteCount;
	
	if(_writePtr > limit) {
		_writePtr = _buffer;
	}
}


#pragma mark - Private Methode Implementation


- (void)dealloc {
    
    free(_buffer);
}


- (BOOL)normalizeBuffer {
    
    // reset, nothing to do
    if(_writePtr == _readPtr) {
        _writePtr = _readPtr = _buffer;
    }
    //
    else if(_writePtr > _readPtr) {
        
        NSUInteger	count		= _writePtr - _readPtr;
        NSUInteger	delta		= _readPtr - _buffer;
        
        memmove(_buffer, _readPtr, count);
        
        _readPtr	= _buffer;
        _writePtr	-= delta;
    }
    else {
        
        NSUInteger		chunkASize	= [self contiguousBytesAvailable];
        NSUInteger		chunkBSize	= [self bytesAvailable] - [self contiguousBytesAvailable];
        
        uint8_t			*chunkA		= NULL;
        uint8_t			*chunkB		= NULL;
        
        chunkA = (uint8_t *)calloc(chunkASize, sizeof(uint8_t));
        //NSAssert1(NULL != chunkA, @"Unable to allocate memory: %s", strerror(errno));
        if (chunkA == NULL) {
            ALog(@"Unable to allocate memory: %s", strerror(errno));
            return NO;
        }
        memcpy(chunkA, _readPtr, chunkASize);
        
        if(0 < chunkBSize) {
            chunkB = (uint8_t *)calloc(chunkBSize, sizeof(uint8_t));
            //NSAssert1(NULL != chunkA, @"Unable to allocate memory: %s", strerror(errno));
            if (chunkB == NULL) {
                ALog(@"Unable to allocate memory: %s", strerror(errno));
                free(chunkA);
                return NO;
            }
            memcpy(chunkB, _buffer, chunkBSize);
        }
        
        memcpy(_buffer, chunkA, chunkASize);
        memcpy(_buffer + chunkASize, chunkB, chunkBSize);
        
        _readPtr	= _buffer;
        _writePtr	= _buffer + chunkASize + chunkBSize;
        
        // free chunkA & chunkB
        free(chunkA);
        free(chunkB);
    }
    
    return YES;
}


- (NSUInteger)contiguousBytesAvailable {
    
    uint8_t	*limit = _buffer + _bufsize;
    
    
    return (_writePtr >= _readPtr
            ?
            // read             read
            // |                 |
            // v                 v
            //+----------+      +----------+
            //|xxxxxxx   |  OR  |          |
            //+----------+      +----------+
            //        ^          ^
            //        |          |
            //       write      write
            //
            _writePtr - _readPtr
            :
            // write
            //  |
            //  v
            //+----------+
            //|x      xxx|
            //+----------+
            //        ^
            //        |
            //       read
            //
            limit - _readPtr);
}


- (NSUInteger)contiguousFreeSpaceAvailable {
    
    uint8_t			*limit		= _buffer + _bufsize;
    
    return (_writePtr >= _readPtr ? limit - _writePtr : _readPtr - _writePtr);
}


#pragma mark -
@end
