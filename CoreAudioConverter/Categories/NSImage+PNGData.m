//
//  NSImage+PNGData.m
//  CoreAudioConverter
//
//  Created by Simon Gaus on 08.08.16.
//  Copyright © 2016 Simon Gaus. All rights reserved.
//

#import "NSImage+PNGData.h"

@implementation NSImage (PNGData)

- (NSData *)pngData {
    
    NSEnumerator		*enumerator					= nil;
    NSImageRep			*currentRepresentation		= nil;
    NSBitmapImageRep	*bitmapRep					= nil;
    NSSize				size;
    
    enumerator = [self.representations objectEnumerator];
    while((currentRepresentation = [enumerator nextObject])) {
        if([currentRepresentation isKindOfClass:[NSBitmapImageRep class]]) {
            bitmapRep = (NSBitmapImageRep *)currentRepresentation;
        }
    }
    
    // Create a bitmap representation if one doesn't exist
    if(!bitmapRep) {
        size = self.size;
        [self lockFocus];
        bitmapRep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:NSMakeRect(0, 0, size.width, size.height)];
        [self unlockFocus];
    }
    
    return [bitmapRep representationUsingType:NSPNGFileType properties:@{}];
}

@end
