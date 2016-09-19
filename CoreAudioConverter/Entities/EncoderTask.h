//
//  EncoderTask.h
//  CoreAudioConverter
//
//  Created by Simon Gaus on 13.08.16.
//  Copyright © 2016 Simon Gaus. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/**
 
 */
@interface EncoderTask : NSObject
/**
 
 */
@property (nonatomic, readonly) NSURL *inputURL;
/**
 
 */
@property (nonatomic, readonly) NSURL *outputURL;
/**
 
 */
@property (nonatomic, readonly) NSURL *tempURL;
/**
 
 */
@property (nonatomic, nullable, readonly) NSImage *artwork;
/**
 
 */
@property (nonatomic, readonly) BOOL artworkAvailable;

/**
 
 @param inputURL
 @param outputURL
 @param tempURL
 @param artwork
 @param artworkAvailable
 @return Instance or nil
 */
+ (nullable instancetype)taskWithInputURL:(NSURL *)inputURL
                                outputURL:(NSURL *)outputURL
                             temporaryURL:(NSURL *)tempURL
                                  artwork:(NSImage *)artwork
                         artworkAvailable:(BOOL)artworkAvailable;

@end
NS_ASSUME_NONNULL_END
