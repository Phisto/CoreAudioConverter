//
//  XPCEncoderTask.m
//  CoreAudioConverter
//
//  Created by Simon Gaus on 01.09.16.
//  Copyright © 2016 Simon Gaus. All rights reserved.
//

#import "XPCEncoderTask.h"
#import <Cocoa/Cocoa.h>

#import "EncoderTask.h"

NSString * const kInputDataKey = @"_inputURLData";
NSString * const kOutputDataKey = @"_outputURLData";
NSString * const kTempDataKey = @"_tempURLData";
NSString * const kArtworkDataKey = @"_artwork";
NSString * const kArtworkAivailableDataKey = @"_artworkAvailable";

@interface XPCEncoderTask (/* Private */)

@property (nonatomic, strong) NSData *inputURLData;
@property (nonatomic, strong) NSData *outputURLData;
@property (nonatomic, strong) NSData *tempURLData;
@property (nonatomic, strong) NSImage *artwork;
@property (nonatomic, readwrite) BOOL artworkAvailable;

@end

@implementation XPCEncoderTask
#pragma mark - Object creation

- (EncoderTask *)encoderTask {
    
    NSError *resolveInError;
    BOOL isStale;
    NSURL *input = [NSURL URLByResolvingBookmarkData:self.inputURLData
                                          options:NSURLBookmarkResolutionWithoutUI
                                    relativeToURL:nil
                              bookmarkDataIsStale:&isStale
                                            error:&resolveInError];
    if (!input) {
        NSLog(@"URLByResolvingBookmarkData failed to create input url for EncoderTask : %@", resolveInError);
        return nil;
    }
    
    
    NSURL *output = [NSURL URLWithDataRepresentation:self.outputURLData relativeToURL:nil];
    NSURL *temp = [NSURL URLWithDataRepresentation:self.tempURLData relativeToURL:nil];
    
    EncoderTask *task = [EncoderTask taskWithInputURL:input
                                            outputURL:output
                                         temporaryURL:temp
                                              artwork:self.artwork
                                     artworkAvailable:self.artworkAvailable];
    return task;
}

+ (instancetype)xpcSaveTaskWithInputURLData:(NSData *)inData
                              outputURLData:(NSData *)outData
                                tempURLData:(NSData *)tempData
                                    artwork:(NSImage *)artwork
                           artworkAvailable:(BOOL)artworkAvailable {
    
    return [[[self class] alloc] initWithInputURLData:inData
                                        outputURLData:outData
                                          tempURLData:tempData
                                              artwork:artwork
                                     artworkAvailable:artworkAvailable];
    
}

- (instancetype)initWithInputURLData:(NSData *)inData
                       outputURLData:(NSData *)outData
                         tempURLData:(NSData *)tempData
                             artwork:(NSImage *)artwork
                    artworkAvailable:(BOOL)artworkAvailable {
    
    self = [super init];
    
    if (self) {
        
        _inputURLData = inData;
        _outputURLData = outData;
        _tempURLData = tempData;
        _artwork = artwork;
        _artworkAvailable = artworkAvailable;
        
    }
    
    return self;
}

#pragma mark - NSSecureCoding Methodes

- (instancetype)initWithCoder:(NSCoder *)coder
{
    if ((self = [super init]))
    {
        _inputURLData = [coder decodeObjectOfClass:[NSData class] forKey:kInputDataKey];
        _outputURLData = [coder decodeObjectOfClass:[NSData class] forKey:kOutputDataKey];
        _tempURLData = [coder decodeObjectOfClass:[NSData class] forKey:kTempDataKey];
        
        _artwork = [coder decodeObjectOfClass:[NSImage class] forKey:kArtworkDataKey];
        _artworkAvailable = [coder decodeBoolForKey:kArtworkAivailableDataKey];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    // Encode our ivars using string keys as normal
    [aCoder encodeObject:_inputURLData forKey:kInputDataKey];
    [aCoder encodeObject:_outputURLData forKey:kOutputDataKey];
    [aCoder encodeObject:_tempURLData forKey:kTempDataKey];
    
    [aCoder encodeObject:_artwork forKey:kArtworkDataKey];
    [aCoder encodeBool:_artworkAvailable forKey:kArtworkAivailableDataKey];
}

+ (BOOL)supportsSecureCoding {
    
    return YES;
}

#pragma mark -
@end
