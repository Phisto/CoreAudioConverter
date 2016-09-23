//
//  EncoderTask.h
//  CoreAudioConverter
//
//  Created by Simon Gaus on 13.08.16.
//  Copyright © 2016 Simon Gaus. All rights reserved.
//

@import Foundation;

/**
 
 An Encoder Task represents one file to convert.
 
 */

NS_ASSUME_NONNULL_BEGIN

@interface EncoderTask : NSObject
/**
 The file URL for the file to convert.
 
 @warning In sandboxed applications this needs to be a security-scoped URL, as -startAccessingSecurityScopedResource will be send to it.
 
 @see https://developer.apple.com/reference/foundation/nsurl/1417051-startaccessingsecurityscopedreso?language=objc for more information.
 */
@property (nonatomic, readonly) NSURL *inputURL;
/**
 The file URL to the output file.
 
 @warning The encoder will use the tempURL as destination for the encoded file.
 
 @see Related: tempURL
 */
@property (nonatomic, readonly) NSURL *outputURL;
/**
 The URL to a temporary location for the output file.
 
 @warning If this is set to nil in +taskWithInputURL:outputURL:temporaryURL: this property will return outputURL.
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
                             temporaryURL:(nullable NSURL *)tempURL;

@end
NS_ASSUME_NONNULL_END
