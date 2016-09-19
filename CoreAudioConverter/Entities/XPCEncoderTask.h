//
//  XPCEncoderTask.h
//  CoreAudioConverter
//
//  Created by Simon Gaus on 01.09.16.
//  Copyright © 2016 Simon Gaus. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EncoderTask;

NS_ASSUME_NONNULL_BEGIN
/**
 
 */
@interface XPCEncoderTask : NSObject <NSSecureCoding>
/**
 @param inData
 @param outData
 @param tempData
 @param artwork
 @param artworkAvailable
 @return
 */
+ (instancetype)xpcSaveTaskWithInputURLData:(NSData *)inData
                              outputURLData:(NSData *)outData
                                tempURLData:(NSData *)tempData
                                    artwork:(NSImage *)artwork
                           artworkAvailable:(BOOL)artworkAvailable;
/**
 @return EncoderTask object or nil
 */
- (nullable EncoderTask *)encoderTask;

@end
NS_ASSUME_NONNULL_END
