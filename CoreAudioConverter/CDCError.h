//
//  CDCError.h
//  CoreAudioConverter
//
//  Created by Simon Gaus on 04.03.19.
//  Copyright © 2019 Simon Gaus. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Error domain
///--------------------------------------
/// @name Error domain
///--------------------------------------



/// The error domain for the Core Audio Converter framework.
FOUNDATION_EXPORT NSString * const CDCCoreAudioErrorDomain;



#pragma mark - Error codes
///-------------------------------------
/// @name Error codes
///-------------------------------------

/**
 
 These constants define the application specific error codes.
 
 */
typedef NS_ENUM(NSUInteger, CDCErrorCode) {
    
    /// The file is not accessible by this process.
    CDCFilePermissionDenied                             = 1888,
    /// There is not enough disc space to continue
    CDCNotEnoughDiscSpace                               = 1889

};



#pragma mark - Creating errors
///-------------------------------------------
/// @name Creating errors
///-------------------------------------------

/**
 
 @brief This funktion will create and return a configured error object. If there is no CoreAudioConverter specific error for the given code, the funktion will try to find a matching system error.
 
 @param code The error code.
 
 @param userInfo Miscellaneous string to provide more detailed error messages. Currently unused.
 
 @return The newly created error object.
 
 */

__attribute__((annotate("returns_localized_nsstring")))
NSError * cdc_error( CDCErrorCode code, NSString * _Nullable __unused userInfo );

/**
 
 This funktion will create and return a configured error object.
 
 @param code The OSStatus/SCError error code.
 
 @return The newly created error object.
 
 */
__attribute__((annotate("returns_localized_nsstring")))
NSError * cdc_OSStatusError( OSStatus code );



NS_ASSUME_NONNULL_END
