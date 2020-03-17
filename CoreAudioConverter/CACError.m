//
//  CACError.m
//  CoreAudioConverter
//
//  Created by Simon Gaus on 04.03.19.
//  Copyright © 2019 Simon Gaus. All rights reserved.
//

#import "CACError.h"

#pragma mark - Constants

static NSString * const kCoreAudioConverterIdentifier = @"de.simonsserver.CoreAudioConverter";

#pragma mark - HUSync Error Domain

NSString * const CoreAudioConverterErrorDomain = @"de.simonsserver.CoreAudioConverter.error";

#pragma mark - Funktion Prototypes

NSString * cac_errorDescription( CACErrorCode code, NSString * _Nullable userinfo);
NSString * cac_systemErrorDescription(NSInteger code );

#pragma mark - Convenient Error Creation

NSError * cac_error( CACErrorCode code, NSString * _Nullable __unused userInfo ) {
    
    NSString *errorDomain = CoreAudioConverterErrorDomain;
    NSString *description = cac_errorDescription(code, userInfo);
    
    // try to find a matching system error
    if (!description) {
        
        errorDomain = NSCocoaErrorDomain;
        description = cac_systemErrorDescription(code);
    }
    
    NSError *error = [NSError errorWithDomain:errorDomain
                                         code:code
                                     userInfo:@{ NSLocalizedDescriptionKey : description }];
    return error;
}

inline NSString * cac_errorDescription( CACErrorCode code , NSString * _Nullable userinfo) {
    
    NSString *descr = nil;
    
    switch (code) {
            
        case CACFilePermissionDenied: {
            NSString *locFormatString = NSLocalizedStringFromTableInBundle(@"The process is not allowed to access the requested file at path '%@'.",
                                                                           @"Localizable",
                                                                           [NSBundle bundleWithIdentifier:kCoreAudioConverterIdentifier],
                                                                           @"Error description - Returned if the process is not allowed to access the requested file.");
            descr = [NSString stringWithFormat:locFormatString, userinfo];
            break;
        }
            
        case CACNotEnoughDiscSpace: {
            NSString *locFormatString = NSLocalizedStringFromTableInBundle(@"There is not enough disc space to encode the file at path '%@'.",
                                                                           @"Localizable",
                                                                           [NSBundle bundleWithIdentifier:kCoreAudioConverterIdentifier],
                                                                           @"Error description - Returned if there is not enough disc space to encode the file");
            descr = [NSString stringWithFormat:locFormatString, userinfo];
            break;
        }
            
        case CACTooMayChannels: {
            NSString *locFormatString = NSLocalizedStringFromTableInBundle(@"LAME only supports one or two channel input. %@.",
                                                                           @"Localizable",
                                                                           [NSBundle bundleWithIdentifier:kCoreAudioConverterIdentifier],
                                                                           @"Error description - Returned if a file has more than 2 channels.");
            descr = [NSString stringWithFormat:locFormatString, userinfo];
            break;
        }
            
            
        case CACLameSettingsInitFailed: {
            NSString *locFormatString = NSLocalizedStringFromTableInBundle(@"Unable to initialize the LAME settings. Failed with code: %@",
                                                                           @"Localizable",
                                                                           [NSBundle bundleWithIdentifier:kCoreAudioConverterIdentifier],
                                                                           @"Error description - Returned if the lame settings couldent be set.");
            descr = [NSString stringWithFormat:locFormatString, userinfo];
            break;
        }
            
        case CACOutputAccessFailed: {
            NSString *locFormatString = NSLocalizedStringFromTableInBundle(@"Unable to open the output file: '%@'.",
                                                                           @"Localizable",
                                                                           [NSBundle bundleWithIdentifier:kCoreAudioConverterIdentifier],
                                                                           @"Error description - Returned if the output file could not be opened.");
            descr = [NSString stringWithFormat:locFormatString, userinfo];
            break;
        }
            
        case CACOutputClosingFailed: {
            NSString *locFormatString = NSLocalizedStringFromTableInBundle(@"Unable to close the output file: '%@'.",
                                                                           @"Localizable",
                                                                           [NSBundle bundleWithIdentifier:kCoreAudioConverterIdentifier],
                                                                           @"Error description - Returned if the output file could not be closed.");
            descr = [NSString stringWithFormat:locFormatString, userinfo];
            break;
        }
            
        case CACMemoryAllocationFailed: {
            descr = NSLocalizedStringFromTableInBundle(@"Unable to allocate memory.",
                                                       @"Localizable",
                                                       [NSBundle bundleWithIdentifier:kCoreAudioConverterIdentifier],
                                                       @"Error description - Returned if the output file could not be closed.");
            break;
        }
            
        case CACUnsupportedSampleSize: {
            NSString *locFormatString = NSLocalizedStringFromTableInBundle(@"LAME only supports sample sizes of 8, 16, 24 and 32. %@.",
                                                                           @"Localizable",
                                                                           [NSBundle bundleWithIdentifier:kCoreAudioConverterIdentifier],
                                                                           @"Error description - Returned if a file has an unsupported sample size.");
            descr = [NSString stringWithFormat:locFormatString, userinfo];
            break;
        }
            
        case CACUnknownLAMEError: {
            NSString *locFormatString = NSLocalizedStringFromTableInBundle(@"An error occurred inside of LAME, while encoding the file: '%@'.",
                                                                           @"Localizable",
                                                                           [NSBundle bundleWithIdentifier:kCoreAudioConverterIdentifier],
                                                                           @"Error description - Returned if an unknown error occurred inside of LAME.");
            descr = [NSString stringWithFormat:locFormatString, userinfo];
            break;
        }
            
        case CACLameBufferFlushFailed: {
            NSString *locFormatString = NSLocalizedStringFromTableInBundle(@"LAME was unable to flush the buffers for file: '%@'.",
                                                                           @"Localizable",
                                                                           [NSBundle bundleWithIdentifier:kCoreAudioConverterIdentifier],
                                                                           @"Error description - Returned if LAME was unable to flush the buffer for a file.");
            descr = [NSString stringWithFormat:locFormatString, userinfo];
            break;
        }
            
        case CACFailedToOpenInputFile: {
            NSString *locFormatString = NSLocalizedStringFromTableInBundle(@"Couldn't open the file '%@', the file may be corrupted.",
                                                                           @"Localizable",
                                                                           [NSBundle bundleWithIdentifier:kCoreAudioConverterIdentifier],
                                                                           @"Error description - Returned if the input file couldent be opened.");
            descr = [NSString stringWithFormat:locFormatString, userinfo];
            break;
        }
            
        case CACUnknownFileType: {
            NSString *locFormatString = NSLocalizedStringFromTableInBundle(@"Couldn't detect type for file: '%@', the file may be corrupted.",
                                                                           @"Localizable",
                                                                           [NSBundle bundleWithIdentifier:kCoreAudioConverterIdentifier],
                                                                           @"Error description - Returned if the file type of the input file couldent be detected.");
            descr = [NSString stringWithFormat:locFormatString, userinfo];
            break;
        }
            
        case CACFailedToCreateDecoder: {
            NSString *locFormatString = NSLocalizedStringFromTableInBundle(@"Couldn't create decoder for file: '%@'.",
                                                                           @"Localizable",
                                                                           [NSBundle bundleWithIdentifier:kCoreAudioConverterIdentifier],
                                                                           @"Error description - Returned if the decoder for the given file could not be create.");
            descr = [NSString stringWithFormat:locFormatString, userinfo];
            break;
        }
            
        case CACFileFormatNotSupported: {
            NSString *locFormatString = NSLocalizedStringFromTableInBundle(@"File format not supported for file: '%@'",
                                                                           @"Localizable",
                                                                           [NSBundle bundleWithIdentifier:kCoreAudioConverterIdentifier],
                                                                           @"Error description - Returned if the file format is not supported.");
            descr = [NSString stringWithFormat:locFormatString, userinfo];
            break;
        }
    }
    
    return descr;
}

#pragma mark - System Errors

NSError * cac_OSStatusError( OSStatus code ) {
    
    NSString *description = cac_systemErrorDescription(code);
    NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain
                                         code:code
                                     userInfo:@{ NSLocalizedDescriptionKey : description }];
    return error;
}

NSString * cac_systemErrorDescription(NSInteger code ) {
    
    NSString *descr = NSLocalizedStringFromTableInBundle(@"An unknown error occurred.",
                                                         @"Localizable",
                                                         [NSBundle bundleWithIdentifier:kCoreAudioConverterIdentifier],
                                                         @"Error description - Returned if an unknown error occurred.");
    
    /* Defined in <CoreServices/CarbonCore/MacErrors.h> */
    
    switch (code) {
            
        case userCanceledErr: {
            descr = NSLocalizedStringFromTableInBundle(@"Die Operation wurde vom Nutzer abgebrochen.",
                                                       @"Localizable",
                                                       [NSBundle bundleWithIdentifier:kCoreAudioConverterIdentifier],
                                                       @"Error description - Returned if the operation was canceled by the user.");
        }
            break;
            
        case dskFulErr: {
            descr = NSLocalizedStringFromTableInBundle(@"Es ist kein Platz mehr auf dem Laufwerk.",
                                                       @"Localizable",
                                                       [NSBundle bundleWithIdentifier:kCoreAudioConverterIdentifier],
                                                       @"Error description - Returned if there is no space on the disk.");
        }
            break;
            
        case nsvErr: {
            descr = NSLocalizedStringFromTableInBundle(@"Das Laufwerk konnte nicht gefunden werden.",
                                                       @"Localizable",
                                                       [NSBundle bundleWithIdentifier:kCoreAudioConverterIdentifier],
                                                       @"Error description - Returned if there is no such volume.");
        }
            break;
            
        case ioErr: {
            descr = NSLocalizedStringFromTableInBundle(@"Beim lesen/schreiben ist ein Fehler aufgetreten.",
                                                       @"Localizable",
                                                       [NSBundle bundleWithIdentifier:kCoreAudioConverterIdentifier],
                                                       @"Error description - Returned if an I/O error occurred.");
        }
            break;
            
            
        case bdNamErr: {
            descr = NSLocalizedStringFromTableInBundle(@"Der Dateiname ist nicht zulässig.",
                                                       @"Localizable",
                                                       [NSBundle bundleWithIdentifier:kCoreAudioConverterIdentifier],
                                                       @"Error description - Returned if a bad file name was passed to the routine.");
        }
            break;
            
        case fBsyErr: {
            descr = NSLocalizedStringFromTableInBundle(@"Das Volumen kann nicht ausgeworfen werden, weil es von einem anderen Prozess verwendet wird.",
                                                       @"Localizable",
                                                       [NSBundle bundleWithIdentifier:kCoreAudioConverterIdentifier],
                                                       @"Error description - Returned if the file/volume is beeing used by another process.");
        }
            break;
            
        case fsDataTooBigErr: {
            descr = NSLocalizedStringFromTableInBundle(@"Die Datei oder Partition ist zu groß.",
                                                       @"Localizable",
                                                       [NSBundle bundleWithIdentifier:kCoreAudioConverterIdentifier],
                                                       @"Error description - Returned if the file or volume is too big for the system.");
        }
            break;
            
        case volVMBusyErr: {
            descr = NSLocalizedStringFromTableInBundle(@"Das Laufwerk kann nicht ausgeworfen werden, weil es von der VM benutzt wird.",
                                                       @"Localizable",
                                                       [NSBundle bundleWithIdentifier:kCoreAudioConverterIdentifier],
                                                       @"Error description - Returned if the volume can't be ejected because it is used by the VM.");
        }
            break;
            
        case errFSUnknownCall: {
            descr = NSLocalizedStringFromTableInBundle(@"Die Aktion wird von dem Dateisystem nicht unterstützt.",
                                                       @"Localizable",
                                                       [NSBundle bundleWithIdentifier:kCoreAudioConverterIdentifier],
                                                       @"Error description - Returned if the selector is not recognized by the filesystem.");
        }
            break;
            
        case errFSNotAFolder: {
            descr = NSLocalizedStringFromTableInBundle(@"Das angegebene Objekt ist kein Ordner.",
                                                       @"Localizable",
                                                       [NSBundle bundleWithIdentifier:kCoreAudioConverterIdentifier],
                                                       @"Error description - Returned if a folder was expected and a file was passed.");
        }
            break;
            
        case errFSOperationNotSupported: {
            descr = NSLocalizedStringFromTableInBundle(@"Die Operation wird von dem Dateisystem nicht unterstützt.",
                                                       @"Localizable",
                                                       [NSBundle bundleWithIdentifier:kCoreAudioConverterIdentifier],
                                                       @"Error description - Returned if the attempted operation is not supported by the filesystem.");
        }
            break;
            
        case errFSNotEnoughSpaceForOperation: {
            descr = NSLocalizedStringFromTableInBundle(@"Es ist nicht genügend Speicherplatz vorhanden um die Operation auszuführen.",
                                                       @"Localizable",
                                                       [NSBundle bundleWithIdentifier:kCoreAudioConverterIdentifier],
                                                       @"Error description - Returned if there is not enough disk space to perform the requested operation.");
        }
            break;
            
        case fsmBusyFFSErr: {
            descr = NSLocalizedStringFromTableInBundle(@"Das Laufwerk ist beschäftigt und kann nicht entfernt werden.",
                                                       @"Localizable",
                                                       [NSBundle bundleWithIdentifier:kCoreAudioConverterIdentifier],
                                                       @"Error description - Returned if the file system is busy and cannot be removed.");
        }
            break;
            
        case coreFoundationUnknownErr: {
            descr = NSLocalizedStringFromTableInBundle(@"Es ist ein unbekannter Fehler im Core Foundation Framework aufgetreten.",
                                                       @"Localizable",
                                                       [NSBundle bundleWithIdentifier:kCoreAudioConverterIdentifier],
                                                       @"Error description - Returned if there occurred an unknown Core Foundation error.");
        }
            break;
    }
    
    return descr;
}

#pragma mark -
