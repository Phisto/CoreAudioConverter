//
//  CDCError.m
//  CoreAudioConverter
//
//  Created by Simon Gaus on 04.03.19.
//  Copyright © 2019 Simon Gaus. All rights reserved.
//

#import "CDCError.h"

#pragma mark - Constants


static NSString * const kCoreAudioConverterIdentifier = @"de.simonsserver.CoreAudioConverter";


#pragma mark - HUSync Error Domain


NSString * const CDCCoreAudioErrorDomain = @"de.simonsserver.CoreAudioConverter.error";


#pragma mark - Funktion Prototypes


NSString * cdc_errorDescription( CDCErrorCode code, NSString * _Nullable userinfo);
NSString * cdc_systemErrorDescription(NSInteger code );


#pragma mark - Convenient Error Creation


NSError * cdc_error( CDCErrorCode code, NSString * _Nullable __unused userInfo ) {
    
    NSString *errorDomain = CDCCoreAudioErrorDomain;
    NSString *description = cdc_errorDescription(code, userInfo);
    
    // try to find a matching system error
    if (!description) {
        
        errorDomain = NSCocoaErrorDomain;
        description = cdc_systemErrorDescription(code);
    }
    
    NSError *error = [NSError errorWithDomain:errorDomain
                                         code:code
                                     userInfo:@{ NSLocalizedDescriptionKey : description }];
    return error;
}


inline NSString * cdc_errorDescription( CDCErrorCode code , NSString * _Nullable userinfo) {
    
    NSString *descr = nil;
    
    switch (code) {
            
        case CDCFilePermissionDenied: {
            NSString *locFormatString = NSLocalizedStringFromTableInBundle(@"The process is not allowed to access the requested file at path '%@'.",
                                                                           @"Localizable",
                                                                           [NSBundle bundleWithIdentifier:kCoreAudioConverterIdentifier],
                                                                           @"Error description - Returned if the process is not allowed to access the requested file.");
            descr = [NSString stringWithFormat:locFormatString, userinfo];
            break;
        }
            
        case CDCNotEnoughDiscSpace: {
            NSString *locFormatString = NSLocalizedStringFromTableInBundle(@"There is not enough disc space to encode the file at path '%@'.",
                                                                           @"Localizable",
                                                                           [NSBundle bundleWithIdentifier:kCoreAudioConverterIdentifier],
                                                                           @"Error description - Returned if there is not enough disc space to encode the file");
            descr = [NSString stringWithFormat:locFormatString, userinfo];
            break;
        }
    }
    
    return descr;
}


#pragma mark - System Errors


NSError * cdc_OSStatusError( OSStatus code ) {
    
    NSString *description = cdc_systemErrorDescription(code);
    NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain
                                         code:code
                                     userInfo:@{ NSLocalizedDescriptionKey : description }];
    return error;
}


NSString * cdc_systemErrorDescription(NSInteger code ) {
    
    NSString *descr = NSLocalizedStringFromTableInBundle(@"An unknown error occured.",
                                                         @"Localizable",
                                                         [NSBundle bundleWithIdentifier:kCoreAudioConverterIdentifier],
                                                         @"Error description - Returned if an unknown error occured.");
    
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
                                                       @"Error description - Returned if an I/O error occured.");
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
                                                       @"Error description - Returned if there occured an unknown Core Foundation error.");
        }
            break;
    }
    
    return descr;
}


#pragma mark -
