//
//  NSFileManager+FileAccess.m
//  CoreAudioConverter
//
//  Created by Simon Gaus on 02.09.16.
//  Copyright © 2016 Simon Gaus. All rights reserved.
//

#import "NSFileManager+FileAccess.h"

@implementation NSFileManager (FileAccess)

- (BOOL)path:(NSString *)path isAccessibleFor:(AccessKind)mode {
    
    return (access(path.fileSystemRepresentation, mode) == noErr);
}

@end
