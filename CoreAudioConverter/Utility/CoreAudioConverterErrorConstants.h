//
//  CoreAudioConverterErrorConstants.h
//  M4AtoMP3
//
//  Created by Simon Gaus on 19.09.15.
//  Copyright © 2015 Simon Gaus. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

/**
 These constants defines the Core Audio Converter error domain.
 */
extern NSString *CoreAudioConverterErrorDomain;

/**
 NSError codes in the Core Audio Converter error domain.
 */
typedef NS_ENUM(NSUInteger, CoreAudioConverterError) {
    
    /// The input file format is not supported.
    CACErrorFileFormatNotSupported = 1904,
    /// The input file couldent be accessed.
    CACErrorInputAccessError = 1905,
    /// There wasn't enough free space on the drive to save the encoded file.
    CACErrorDiskSpaceError = 1906,
    /// An error occurred inside of LAME.
    CACErrorLameError = 1907,
    /// There was an error durning allocating memory.
    CACErrorMemoryError = 1908,
    /// The output file couldent be accessed.
    CACErrorOutputAccessError = 1909,
    /// An error occurred, reason unknown.
    CACErrorUnknown = 1910
};

NS_ASSUME_NONNULL_END
