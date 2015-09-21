//
//  MP3Encoder.h
//  M4AtoMP3
//
//  Created by Simon Gaus on 20.09.15.
//  Copyright © 2015 Simon Gaus. All rights reserved.
//

@import Foundation;

@protocol MP3EncoderDelegate <NSObject>

/*!
 * @typedef LAME_CONSTANT_BITRATE
 * @brief The constant bitrate which lame should use to encode the mp3 file.
 * @constant LAME_BITRATE_VERY_HIGH: 320 kbit/s
 * @constant LAME_BITRATE_HIGH: 256 kbit/s
 * @constant LAME_BITRATE_GOOD: 192 kbit/s
 * @constant LAME_BITRATE_GOOD: 128 kbit/s
 */
enum {
    
    ///320 kbit/s
    LAME_CONSTANT_BITRATE_VERY_HIGH = 320,
    ///256 kbit/s
    LAME_CONSTANT_BITRATE_HIGH = 256,
    ///192 kbit/s
    LAME_CONSTANT_BITRATE_GOOD = 192,
    ///128 kbit/s
    LAME_CONSTANT_BITRATE_LOW = 128
    
};
typedef int LAME_CONSTANT_BITRATE;

/**
 @typedef LAME_ENCODING_ENGINE_QUALITY
 @brief The engine quality which lame should use to encode the mp3 file.
 @constant LAME_ENCODING_ENGINE_QUALITY_BEST_SLOW The (near) best quality but slow.
 @constant LAME_ENCODING_ENGINE_QUALITY_GOOD_FAST Good quality and fast.
 @constant LAME_ENCODING_ENGINE_QUALITY_OK_REALLY_FAST Ok quality and really fast.
 */
typedef enum : NSUInteger {
    
    /// The (near) best quality but slow.
    LAME_ENCODING_ENGINE_QUALITY_BEST_SLOW = 2,
    /// Good quality and fast.
    LAME_ENCODING_ENGINE_QUALITY_GOOD_FAST = 5,
    /// Ok quality and really fast.
    LAME_ENCODING_ENGINE_QUALITY_OK_REALLY_FAST = 7
    
} LAME_ENCODING_ENGINE_QUALITY;

/**
 Returns the bitrate used for the constant bitrate encoding
 @see http://wiki.hydrogenaud.io/index.php?title=LAME for additional information about lame options
 @return LAME_CONSTANT_BITRATE
 */
- (LAME_CONSTANT_BITRATE)bitrate;
/**
 Returns the engine quality used for the encoding
 @see http://wiki.hydrogenaud.io/index.php?title=LAME for additional information about lame options
 @return LAME_CONSTANT_BITRATE
 */
- (LAME_ENCODING_ENGINE_QUALITY)engineQuality;

@optional

/**
 Informs the delegate that the encoding started.
 @param encoder The encoder object which started the encoding.
 @param outputSize The calculated size of the output file.
 @return void
 */
- (void)encodingStarted:(id)encoder outputSize:(NSUInteger)size;
/**
 Informs the delegate that the encoding finished.
 @param encoder The encoder object which finished the encoding.
 @return void
 */
- (void)encodingFinished:(id)encoder;
/**
 Informs the delegate that the encoding failed.
 @param encoder The encoder object which failed to encode.
 @param error An error obect encapsulating the failure reason, may be nil.
 @return void
 */
- (void)encodingFailed:(id)encoder withError:(NSError *)error;

@end

@interface MP3Encoder : NSObject

@property (nonatomic, assign) NSObject<MP3EncoderDelegate> *delegate;

+ (instancetype)encoderForFile:(NSURL *)fileUrl error:(NSError **)error;
- (void)encodeToUrl:(NSURL *)outputUrl;

@end
