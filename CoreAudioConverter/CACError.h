//
//  CACError.h
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
FOUNDATION_EXPORT NSString * const CoreAudioConverterErrorDomain;



#pragma mark - Error codes
///-------------------------------------
/// @name Error codes
///-------------------------------------

/**
 
 These constants define the application specific error codes.
 
 */
typedef NS_ENUM(NSUInteger, CACErrorCode) {
    
    /// The file is not accessible by this process.
    CACFilePermissionDenied                             = 1888,
    /// There is not enough disc space to continue
    CACNotEnoughDiscSpace                               = 1889,
    /// LAME only supports one or two channel input.
    CACTooMayChannels                                   = 1890,
    /// LAME could not be initialized.
    CACLameSettingsInitFailed                           = 1891,
    /// The output file couldent be accessed.
    CACOutputAccessFailed                               = 1892,
    /// The output file couldent be closed.
    CACOutputClosingFailed                              = 1893,
    /// Couldent allocate memory.
    CACMemoryAllocationFailed                           = 1894,
    /// LAME only supports certain sample sizes.
    CACUnsupportedSampleSize                            = 1895,
    /// An error occurred inside of LAME, reason unknown.
    CACUnknownLAMEError                                 = 1896,
    /// LAME was unable to flush the buffer.
    CACLameBufferFlushFailed                            = 1897,
    /// The input file couldent be opened.
    CACFailedToOpenInputFile                            = 1898,
    /// The file type of the input file couldent be detected.
    CACUnknownFileType                                  = 1899,
    /// Could not create decoder for the given file.
    CACFailedToCreateDecoder                            = 1900,
    /// The file format is not supported.
    CACFileFormatNotSupported                           = 1901
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
NSError * cac_error( CACErrorCode code, NSString * _Nullable __unused userInfo );

/**
 
 This funktion will create and return a configured error object.
 
 @param code The OSStatus/SCError error code.
 
 @return The newly created error object.
 
 */
__attribute__((annotate("returns_localized_nsstring")))
NSError * cac_OSStatusError( OSStatus code );



NS_ASSUME_NONNULL_END
