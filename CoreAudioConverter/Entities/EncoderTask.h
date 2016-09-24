//
//  EncoderTask.h
//  CoreAudioConverter
//
//  Created by Simon Gaus on 13.08.16.
//  Copyright © 2016 Simon Gaus. All rights reserved.
//

@import Foundation;

/**
 
 An EncoderTask object represents an audio file to convert.
 
 It would have been enough to specify an input and output URL to give the encoder enough informations for the converting.
 But i decided to use a temporary url, as there are various cases where you want to encode the file to a temporary location and than later move the file to their final location. It is possible to skip that step by intitializing an EncoderTask object with nil as argument for the tempURL, than the file will be encoded directly to the location the outputURL points to.
 
 */

NS_ASSUME_NONNULL_BEGIN

@interface EncoderTask : NSObject

///---------------------
/// @name Properties
///---------------------

/**
 
 The fileURL to the file that should be converted.
 
 @warning In a sandboxed application this needs to be a security-scoped URL, as -startAccessingSecurityScopedResource will be send to it.
 
 @see https://developer.apple.com/reference/foundation/nsurl/1417051-startaccessingsecurityscopedreso?language=objc for more information.
 
 */
@property (nonatomic, readonly) NSURL *inputURL;
/**
 
 The fileURL to the output file.
 
 @see Related: tempURL
 
 */
@property (nonatomic, readonly) NSURL *outputURL;
/**
 
 The URL to a temporary location for the output file.
 
 @warning If this is set to nil in +taskWithInputURL:outputURL:temporaryURL: this property will return outputURL.
 
 */
@property (nonatomic, readonly) NSURL *tempURL;

///---------------------
/// @name Initialization
///---------------------

/**
 
 Creates and returns an EncoderTask object initialized with the provided input, output and temporary file URL.
 
 @warning The encoders will use the tempURL as destination for the encoded file. If this is initialized with nil, tempURL will return outputURL.
 
 @param inputURL The fileURL to the file that should be converted.
 
 @param outputURL The fileURL to the output file.
 
 @param tempURL The URL to a temporary location for the output file.
 
 @return An initialized EncoderTask object or nil.
 
 */
+ (nullable instancetype)taskWithInputURL:(NSURL *)inputURL
                                outputURL:(NSURL *)outputURL
                             temporaryURL:(nullable NSURL *)tempURL;

@end
NS_ASSUME_NONNULL_END
