/*
 *  CADecoder.m
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
 */

#import "CADecoder.h"

#import <AudioToolbox/AudioFormat.h>
#import <AudioToolbox/ExtendedAudioFile.h>

#import "CircularBuffer.h"

#import "CoreAudioConverterErrorConstants.h"


// ALog always displays output regardless of the DEBUG setting
#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

@interface CADecoder (/* Private */)


@property (nonatomic, readwrite) SInt64 currentFrame;
@property (nonatomic, strong) CircularBuffer *pcmBuffer;
@property (nonatomic, strong) NSURL *fileUrl;
@property (nonatomic, readwrite) ExtAudioFileRef extAudioFile;
@property (nonatomic, readwrite) AudioStreamBasicDescription pcmFormat;

@end

@implementation CADecoder
#pragma mark Object creation

+ (nullable instancetype)decoderForFile:(NSURL *)fileUrl error:(NSError * __autoreleasing *)error {
    
    CADecoder *result = nil;
    
    // Create the source based on the file's extension
    NSArray			*coreAudioExtensions	= [CADecoder supportedAudioExtensions];
    NSString		*extension				= [[fileUrl pathExtension] lowercaseString];
    
    // format supported
    if ([coreAudioExtensions containsObject:extension]) {
        
        result = [[CADecoder alloc] initWithFile:fileUrl error:(NSError **)error];
        if (!result) {
            
            if (!error) {
                NSDictionary *infoDict = @{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Couldn't create decoder for file: \"%@\".", fileUrl]};
                NSError *newError = [NSError errorWithDomain:CoreAudioConverterErrorDomain
                                                        code:CACErrorUnknown
                                                    userInfo:infoDict];
                if (error != NULL) *error = newError;
            }
            
            return nil;
        }
    }
    // format not supported
    else {
        
        NSDictionary *infoDict = @{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"File format not supported for file: \"%@\".", fileUrl.lastPathComponent] };
        NSError *newError = [NSError errorWithDomain:CoreAudioConverterErrorDomain
                                                code:CACErrorFileFormatNotSupported
                                            userInfo:infoDict];
        if (error != NULL) *error = newError;
    }
    
    return result;
}
- (nullable instancetype)initWithFile:(NSURL *)fileUrl error:(NSError * __autoreleasing *)error {

    if (!fileUrl) return nil;
    
    self = [super init];
    
    if (self) {
        
        _pcmBuffer = [[CircularBuffer alloc] init];
        if (!_pcmBuffer) {
            NSDictionary *infoDict = @{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Couldn't allocate memory for the ring buffer."]};
            NSError *newError = [NSError errorWithDomain:CoreAudioConverterErrorDomain
                                                    code:CACErrorUnknown
                                                userInfo:infoDict];
            if (error != NULL) *error = newError;
            return nil;
        }
        _fileUrl = fileUrl;
        
        __unused OSStatus result = ExtAudioFileOpenURL((__bridge CFURLRef _Nonnull)(fileUrl), &_extAudioFile);
        if (result != noErr) {
            CFStringRef descr = UTCreateStringForOSType(result);
            //ALog(@"ExtAudioFileOpen failed: %@", descr);
            NSDictionary *infoDict = @{ NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Couldn't open the file \"%@\", the file may be corrupted. Underlying failure reason: %@ failure code: %d", fileUrl.lastPathComponent, descr, (int)result]};
            if (descr != NULL) CFRelease(descr);
            NSError *newError = [NSError errorWithDomain:CoreAudioConverterErrorDomain
                                                    code:CACErrorUnknown
                                                userInfo:infoDict];
            if (error != NULL) *error = newError;
            return nil;
        }
        
        // Query file type
        UInt32 dataSize = sizeof(AudioStreamBasicDescription);
        result = ExtAudioFileGetProperty(_extAudioFile, kExtAudioFileProperty_FileDataFormat, &dataSize, &_pcmFormat);
        if (result != noErr) {
            CFStringRef descr = UTCreateStringForOSType(result);
            ALog(@"AudioFileGetProperty failed: %@", descr);
            if (descr != NULL) CFRelease(descr);
            NSDictionary *infoDict = @{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Couldn't detect type for file: \"%@\", the file may be corrupted.", fileUrl.lastPathComponent]};
            NSError *newError = [NSError errorWithDomain:CoreAudioConverterErrorDomain
                                                    code:CACErrorUnknown
                                                userInfo:infoDict];
            if (error != NULL) *error = newError;
            return nil;
        }
    
        _pcmFormat.mFormatID = kAudioFormatLinearPCM;
        _pcmFormat.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsBigEndian | kAudioFormatFlagIsPacked;
        
        // For alac the source bit depth is encoded in the format flag
        if(kAudioFormatAppleLossless == _pcmFormat.mFormatID) {
            
            switch (_pcmFormat.mFormatFlags) {
                case kAppleLosslessFormatFlag_16BitSourceData:
                    _pcmFormat.mBitsPerChannel = 16;
                    break;
                case kAppleLosslessFormatFlag_24BitSourceData:
                    _pcmFormat.mBitsPerChannel = 24;
                    break;
                case kAppleLosslessFormatFlag_32BitSourceData:
                    _pcmFormat.mBitsPerChannel = 32;
                    break;
                default:
                    _pcmFormat.mBitsPerChannel = 16;
                    break;
            }
        }
        else {
            
            // Preserve mSampleRate and mChannelsPerFrame
            _pcmFormat.mBitsPerChannel	= (0 == _pcmFormat.mBitsPerChannel ? 16 : _pcmFormat.mBitsPerChannel);
            
            _pcmFormat.mBytesPerPacket = (_pcmFormat.mBitsPerChannel / 8) * _pcmFormat.mChannelsPerFrame;
            _pcmFormat.mFramesPerPacket = 1;
            _pcmFormat.mBytesPerFrame = _pcmFormat.mBytesPerPacket * _pcmFormat.mFramesPerPacket;
        }
        
        // Tell the extAudioFile the format we'd like for data
        result = ExtAudioFileSetProperty(_extAudioFile, kExtAudioFileProperty_ClientDataFormat, sizeof(_pcmFormat), &_pcmFormat);
        if (result != noErr) {
            
            CFStringRef descr = UTCreateStringForOSType(result);
            ALog(@"ExtAudioFileSetProperty failed: %@", descr);
            if (descr != NULL) CFRelease(descr);
            return nil;
        }
    }
    
    return self;
}

- (void)dealloc {
    
    if (_extAudioFile) {
        OSStatus result = ExtAudioFileDispose(_extAudioFile);
        if (result != noErr) {
            CFStringRef descr = UTCreateStringForOSType(result);
            ALog(@"ExtAudioFileDispose failed: %@", descr);
            if (descr != NULL) CFRelease(descr);
        }
    }
}

#pragma mark -
#pragma mark Main Methodes

- (UInt32)readAudio:(AudioBufferList *)bufferList frameCount:(UInt32)frameCount {
    
    if (bufferList == NULL) {
        ALog(@"An error occured during decoding.");
        return 0;
    }
    if (bufferList->mNumberBuffers <= 0) {
        ALog(@"An error occured during decoding.");
        return 0;
    }
    if (frameCount <= 0) { return 0; }
    
    UInt32		framesRead		= 0;
    UInt32		byteCount		= frameCount * self.pcmFormat.mBytesPerPacket;
    UInt32		bytesRead		= 0;
    
    if (byteCount > bufferList->mBuffers[0].mDataByteSize) {
        ALog(@"An error occured during decoding.");
        return 0;
    }
    
    // If there aren't enough bytes in the buffer, fill it as much as possible
    if([[self pcmBuffer] bytesAvailable] < byteCount) {
        
        BOOL erfolg = [self fillPCMBuffer];
        if (!erfolg) {
            ALog(@"An error occured during decoding.");
            return 0;
        }
    }
    
    // If there still aren't enough bytes available, return what we have
    if([[self pcmBuffer] bytesAvailable] < byteCount)
        byteCount = (UInt32)[[self pcmBuffer] bytesAvailable];
    
    bytesRead								= (UInt32)[[self pcmBuffer] getData:bufferList->mBuffers[0].mData byteCount:byteCount];
    bufferList->mBuffers[0].mNumberChannels	= [self pcmFormat].mChannelsPerFrame;
    bufferList->mBuffers[0].mDataByteSize	= bytesRead;
    framesRead								= bytesRead / [self pcmFormat].mBytesPerFrame;
    
    // Update internal state
    _currentFrame += framesRead;
    
    return framesRead;
}

- (SInt64)totalFrames {
    
    __unused OSStatus	result;
    UInt32		dataSize;
    SInt64		frameCount;
    
    dataSize		= sizeof(frameCount);
    result			= ExtAudioFileGetProperty(_extAudioFile, kExtAudioFileProperty_FileLengthFrames, &dataSize, &frameCount);
    
    if (result != noErr) {
        CFStringRef descr = UTCreateStringForOSType(result);
        ALog(@"AudioFileGetProperty failed: %@", descr);
        if (descr != NULL) CFRelease(descr);
        return 0;
    }
    
    return frameCount;
}

- (BOOL)fillPCMBuffer {
    
    CircularBuffer		*buffer	= self.pcmBuffer;
    __unused OSStatus	result;
    AudioBufferList		bufferList;
    UInt32				frameCount;
    
    bufferList.mNumberBuffers				= 1;
    bufferList.mBuffers[0].mNumberChannels	= self.pcmFormat.mChannelsPerFrame;
    // type is spezified return type in circular buffer
    uint8_t *data = [buffer exposeBufferForWriting];
    if (data == nil) {
        ALog(@"Failed to expose buffer for writing.");
        return NO;
    }
    bufferList.mBuffers[0].mData			= data;
    
    bufferList.mBuffers[0].mDataByteSize	= (UInt32)[buffer freeSpaceAvailable];
    frameCount								= bufferList.mBuffers[0].mDataByteSize / self.pcmFormat.mBytesPerFrame;
    result									= ExtAudioFileRead(_extAudioFile, &frameCount, &bufferList);
    
    if (result != noErr) {
        CFStringRef descr = UTCreateStringForOSType(result);
        ALog(@"ExtAudioFileRead failed: %@", descr);
        if (descr != NULL) CFRelease(descr);
        return NO;
    }
    
    if ((bufferList.mBuffers[0].mDataByteSize) != (frameCount * self.pcmFormat.mBytesPerFrame)) {
        ALog(@"mismatch");
        return NO;
    }
    
    [buffer wroteBytes:bufferList.mBuffers[0].mDataByteSize];
    return YES;
}

#pragma mark -
#pragma mark Helper Methodes

+ (NSArray<NSString *> *)supportedAudioExtensions {
    
    NSArray *coreAudioExtensions;
    UInt32		size	= sizeof(coreAudioExtensions);
    __unused OSStatus	err		= AudioFileGetGlobalInfo(kAudioFileGlobalInfo_AllExtensions, 0, NULL, &size, &coreAudioExtensions);
    
    if (err != noErr) {
        
        CFStringRef descr = UTCreateStringForOSType(err);
        ALog(@"Failed to get supported Core Audio Extensions. Failure reason: %@", descr);
        if (descr != NULL) CFRelease(descr);
    }
    return coreAudioExtensions;
}

#pragma mark -
@end
