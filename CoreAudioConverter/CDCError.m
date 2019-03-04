//
//  CDCError.m
//  CoreAudioConverter
//
//  Created by Simon Gaus on 04.03.19.
//  Copyright © 2019 Simon Gaus. All rights reserved.
//

#import "CDCError.h"

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
            descr = [NSString stringWithFormat:@"The process is not allowed to access the requested file at path '%@'.", userinfo];
            break;
        }
            
        case CDCNotEnoughDiscSpace: {
            descr = [NSString stringWithFormat:@"There is not enough disc space to encode the file at path '%@'.", userinfo];
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
    
    /* Defined in <CoreServices/CarbonCore/MacErrors.h> */
    
    NSString *descr = @"An unknown error occured.";
    
    switch (code) {
            
        case userCanceledErr: {
            descr = NSLocalizedString(@"Die Operation wurde vom Nutzer abgebrochen.",
                                      @"Error description - Returned if the operation was canceled by the user.");
        }
            break;
            
        case dskFulErr: {
            descr = NSLocalizedString(@"Es ist kein Platz mehr auf dem Laufwerk.",
                                      @"Error description - Returned if there is no space on the disk.");
        }
            break;
            
        case nsvErr: {
            descr = NSLocalizedString(@"Das Laufwerk konnte nicht gefunden werden.",
                                      @"Error description - Returned if there is no such volume.");
        }
            break;
            
        case ioErr: {
            descr = NSLocalizedString(@"Beim lesen/schreiben ist ein Fehler aufgetreten.",
                                      @"Error description - Returned if an I/O error occured.");
        }
            break;
            
            
        case bdNamErr: {
            descr = NSLocalizedString(@"Der Dateiname ist nicht zulässig.",
                                      @"Error description - Returned if a bad file name was passed to the routine.");
        }
            break;
            
        case fBsyErr: {
            descr = NSLocalizedString(@"Das Volumen kann nicht ausgeworfen werden, weil es von einem anderen Prozess verwendet wird.",
                                      @"Error description - Returned if the file/volume is beeing used by another process.");
        }
            break;
            
        case notARemountErr: {
            descr = NSLocalizedString(@"Nur remounts sind zulässig.",
                                      @"Error description - Returned if _Mount allows only remounts and doesn't get one.");
        }
            break;
            
        case fsDataTooBigErr: {
            descr = NSLocalizedString(@"Die Datei oder Partition ist zu groß.",
                                      @"Error description - Returned if the file or volume is too big for the system.");
        }
            break;
            
        case volVMBusyErr: {
            descr = NSLocalizedString(@"Das Laufwerk kann nicht ausgeworfen werden, weil es von der VM benutzt wird.",
                                      @"Error description - Returned if the volume can't be ejected because it is used by the VM.");
        }
            break;
            
        case errFSUnknownCall: {
            descr = NSLocalizedString(@"Die Aktion wird von dem Dateisystem nicht unterstützt.",
                                      @"Error description - Returned if the selector is not recognized by the filesystem.");
        }
            break;
            
        case errFSNotAFolder: {
            descr = NSLocalizedString(@"Das angegebene Objekt ist kein Ordner.",
                                      @"Error description - Returned if a folder was expected and a file was passed.");
        }
            break;
            
        case errFSOperationNotSupported: {
            descr = NSLocalizedString(@"Die Operation wird von dem Dateisystem nicht unterstützt.",
                                      @"Error description - Returned if the attempted operation is not supported by the filesystem.");
        }
            break;
            
        case errFSNotEnoughSpaceForOperation: {
            descr = NSLocalizedString(@"Es ist nicht genügend Speicherplatz vorhanden um die Operation auszuführen.",
                                      @"Error description - Returned if there is not enough disk space to perform the requested operation.");
        }
            break;
            
        case fsmBusyFFSErr: {
            descr = NSLocalizedString(@"Das Laufwerk ist beschäftigt und kann nicht entfernt werden.",
                                      @"Error description - Returned if the file system is busy and cannot be removed.");
        }
            break;
            
            /* ASP Error Codes */
            
        case aspBadVersNum: {
            descr = NSLocalizedString(@"Diese Version von ASP wird vom Server nicht untersützt.",
                                      @"Error description - Returned if the server cannot support this ASP (AppleTalk Session Protocol) version.");
        }
            break;
            
        case aspNoServers: {
            descr = NSLocalizedString(@"Unter dieser Adresse ist kein Server zu erreichen.",
                                      @"Error description - Returned if there are no ASP (AppleTalk Session Protocol) servers at that address.");
        }
            break;
            
        case aspParamErr: {
            descr = NSLocalizedString(@"Einer der Parameter führte zu einem Fehler.",
                                      @"Error description - Returned if an parameter error occures.");
        }
            break;
            
        case aspServerBusy: {
            descr = NSLocalizedString(@"Der Server kann keine weitere Verbindung öffnen.",
                                      @"Error description - Returned if the server cannot open another ASP (AppleTalk Session Protocol) session.");
        }
            break;
            
        case aspSessClosed: {
            descr = NSLocalizedString(@"Die Verbindung zum Server wurde geschlossen.",
                                      @"Error description - Returned if the ASP (AppleTalk Session Protocol) session was closed.");
        }
            break;
            
        case aspTooMany: {
            descr = NSLocalizedString(@"Der Server akzeptiert keine weiteren Verbindungen.",
                                      @"Error description - Returned if there are too many clients (server error).");
        }
            break;
            
        case coreFoundationUnknownErr: {
            descr = NSLocalizedString(@"Es ist ein unbekannter Fehler im Core Foundation Framework aufgetreten.",
                                      @"Error description - Returned if there occured an unknown Core Foundation error.");
        }
            break;
            
            /* AFP Error Codes */
            
        case afpAccessDenied: {
            descr = NSLocalizedString(@"Der Zugriff wurde verweigert.",
                                      @"Error description - AFP Protocol Errors - Returned if one have insufficient access privileges for the operation.");
        }
            break;
            
        case afpAuthContinue: {
            descr = NSLocalizedString(@"Die Anmeldeinformationen sind unvollständig.",
                                      @"Error description - AFP Protocol Errors - Returned if further information are required to complete the AFPLogin call.");
        }
            break;
            
        case afpBadUAM: {
            descr = NSLocalizedString(@"Der Nutzer konnte nicht authentifiziert werden.",
                                      @"Error description - AFP Protocol Errors - Returned if an unknown user authentication method is specified.");
        }
            break;
            
        case afpBadVersNum: {
            descr = NSLocalizedString(@"Die benutzte Version von AFP wird nicht unterstützt.",
                                      @"Error description - AFP Protocol Errors - Returned if an unknown AFP protocol version number specified.");
        }
            break;
            
        case afpNoServer: {
            descr = NSLocalizedString(@"Der Server antwortet nicht.",
                                      @"Error description - AFP Protocol Errors - Returned if the AFP server is not responding.");
        }
            break;
            
        case afpServerGoingDown: {
            descr = NSLocalizedString(@"Der Server fährt gerade herunter.",
                                      @"Error description - AFP Protocol Errors - Returned if the AFP server is shutting down.");
        }
            break;
            
        case afpPwdExpiredErr: {
            descr = NSLocalizedString(@"Das Passwort ist abgelaufen und muss erneuert werden.",
                                      @"Error description - AFP Protocol Errors - Returned if the password being used is too old: this requires the user to change the password before log-in can continue.");
        }
            break;
            
        case afpPwdNeedsChangeErr: {
            descr = NSLocalizedString(@"Das Passwort muss erneuert werden.",
                                      @"Error description - AFP Protocol Errors - Returned if the password needs to be changed.");
        }
            break;
            
        case afpAlreadyLoggedInErr: {
            descr = NSLocalizedString(@"Der Benutzer ist bereits angemeldet.",
                                      @"Error description - AFP Protocol Errors - Returned if the user has been authenticated but is already logged in from another machine (and that's not allowed on this server).");
        }
            break;
            
        case afpCantMountMoreSrvre: {
            descr = NSLocalizedString(@"Es kann keine weitere Verbindung zu einem Server aufgebaut werden.",
                                      @"Error description - AFP Protocol Errors - Returned if the maximum number of server connections has been reached.");
        }
            break;
            
        case afpAlreadyMounted: {
            descr = NSLocalizedString(@"Das Netzwerklaufwerk ist bereits verbunden.",
                                      @"Error description - AFP Protocol Errors - Returned if the volume is already mounted.");
        }
            break;
            
        case afpSameNodeErr: {
            descr = NSLocalizedString(@"Das Netzwerklaufwerk befindet sich auf dieser Maschine.",
                                      @"Error description - AFP Protocol Errors - Returned if an Attempt was made to connect to a file server running on the same machine.");
        }
            break;
    }
    
    return descr;
}


#pragma mark -
