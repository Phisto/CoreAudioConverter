/*
 *  CoreAudioConverterErrorConstants.h
 *  CoreAudioConverter
 *
 *  Copyright © 2015-2016 Simon Gaus <simon.cay.gaus@gmail.com>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU Lesser General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU Lesser General Public License for more details.
 */

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

/**
 
 These constant defines the Core Audio Converter error domain.
 
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
