//
//  AudioConverterErrorConstants.h
//  M4AtoMP3
//
//  Created by Simon Gaus on 19.09.15.
//  Copyright © 2015 Simon Gaus. All rights reserved.
//

@import Foundation;

#pragma mark Error Domain
extern NSString *ACErrorDomain;

#pragma mark Error Codes
typedef NS_ENUM(NSUInteger, ACError) {
    ACErrorFileFormatNotSupported = 1904,
    ACErrorInputAccessError = 1905,
    ACErrorDiskSpaceError = 1906,
    ACErrorLameError = 1907,
    ACErrorMemoryError = 1908,
    ACErrorOutputAccessError = 1909,
    ACErrorUnknown = 1910
};
