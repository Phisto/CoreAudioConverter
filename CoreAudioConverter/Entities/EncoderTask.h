//
//  EncoderTask.h
//  CoreAudioConverter
//
//  Created by Simon Gaus on 13.08.16.
//  Copyright © 2016 Simon Gaus. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 
 A Encoder Task
 
 */

NS_ASSUME_NONNULL_BEGIN

@interface EncoderTask : NSObject
/**
 The URL to the input file.
 */
@property (nonatomic, readonly) NSURL *inputURL;
/**
 The URL to the output file.
 */
@property (nonatomic, readonly) NSURL *outputURL;
/**
 The URL to the temporary file.
 */
@property (nonatomic, readonly) NSURL *tempURL;

/**
 
 @param inputURL
 
 @param outputURL
 
 @param tempURL
 
 @return Instance or nil
 */
+ (nullable instancetype)taskWithInputURL:(NSURL *)inputURL
                                outputURL:(NSURL *)outputURL
                             temporaryURL:(NSURL *)tempURL;

@end
NS_ASSUME_NONNULL_END
