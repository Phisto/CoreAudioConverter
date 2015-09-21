//
//  MP3Encoder.h
//  M4AtoMP3
//
//  Created by Simon Gaus on 20.09.15.
//  Copyright © 2015 Simon Gaus. All rights reserved.
//

@import Foundation;

/**
 @protocol MP3EncoderDelegate
 @brief The delegate for the encoder object needs to provide some settings for the encoding and will get informed about the status of the encoding.
 */
@protocol MP3EncoderDelegate <NSObject>

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
/**
 * @typedef LAME_CONSTANT_BITRATE
 * @brief The constant bitrate which lame should use to encode the mp3 file.
 */
typedef int LAME_CONSTANT_BITRATE;

enum {
    /// The (near) best quality but slow.
    LAME_ENCODING_ENGINE_QUALITY_BEST_SLOW = 2,
    /// Good quality and fast.
    LAME_ENCODING_ENGINE_QUALITY_GOOD_FAST = 5,
    /// Ok quality and really fast.
    LAME_ENCODING_ENGINE_QUALITY_OK_REALLY_FAST = 7
};
/**
 *@typedef LAME_ENCODING_ENGINE_QUALITY
 *@brief The engine quality which lame should use to encode the mp3 file.
 */
typedef int LAME_ENCODING_ENGINE_QUALITY;

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
 @param error An error obect encapsulating the failure reason or nil.
 @return void
 */
- (void)encodingFailed:(id)encoder withError:(NSError *)error;

@end

/*!
 * @class MP3Encoder
 * @brief The MP3Encoder class provides an object to convert various audio file types to mp3.
 */
@interface MP3Encoder : NSObject

@property (nonatomic, assign) NSObject<MP3EncoderDelegate> *delegate;

+ (instancetype)encoderForFile:(NSURL *)fileUrl error:(NSError **)error;
- (void)encodeToUrl:(NSURL *)outputUrl;

@end
