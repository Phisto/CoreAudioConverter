//
//  AACEncoderOperation.h
//  CoreAudioConverter
//
//  Created by Simon Gaus on 17.03.16.
//  Copyright © 2016 Simon Gaus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EncoderOperation.h"

@import AudioToolbox;

@protocol AACEncoderOperationDelegate <EncoderOperationDelegate>

enum {
    ///Spend as much CPU time as necessary to obtain the highest-quality sound output possible.
    AAC_QUALITY_VERY_HIGH = kAudioCodecQuality_Max,
    ///Spend sufficient CPU time to achieve high quality sound output.
    AAC_QUALITY_HIGH = kAudioCodecQuality_High,
    ///Give CPU time and sound output quality equal consideration.
    AAC_QUALITY_GOOD = kAudioCodecQuality_Medium,
    ///Give speed of processing priority over sound quality.
    AAC_QUALITY_LOW = kAudioCodecQuality_Low
};
/**
 * @typedef LAME_CONSTANT_BITRATE
 * @brief The quality setting for the AAC encoder.
 */
typedef UInt32 AAC_QUALITY;

@required
- (CONSTANT_BITRATE)bitrate;
- (AAC_QUALITY)quality;

@end

@interface AACEncoderOperation : EncoderOperation

- (instancetype)initWithDelegate:(NSObject<AACEncoderOperationDelegate> *)delegate workload:(NSArray *)workloadArray;

@end
