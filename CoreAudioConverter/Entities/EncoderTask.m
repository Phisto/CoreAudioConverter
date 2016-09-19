//
//  EncoderTask.m
//  CoreAudioConverter
//
//  Created by Simon Gaus on 13.08.16.
//  Copyright © 2016 Simon Gaus. All rights reserved.
//

#import "EncoderTask.h"

#import <Cocoa/Cocoa.h>

@interface EncoderTask (/* Private */)

@property (nonatomic, strong) NSURL *tempURL;
@property (nonatomic, strong) NSURL *inputURL;
@property (nonatomic, strong) NSURL *outputURL;

@property (nonatomic, nullable, strong) NSImage *artwork;
@property (nonatomic, readwrite) BOOL artworkAvailable;

@end

@implementation EncoderTask

+ (nullable instancetype)taskWithInputURL:(NSURL *)inputURL
                                outputURL:(NSURL *)outputURL
                             temporaryURL:(NSURL *)tempURL
                                  artwork:(NSImage *)artwork
                         artworkAvailable:(BOOL)artworkAvailable {
    
    return [[[self class] alloc] initWithInputURL:inputURL
                                        outputURL:outputURL
                                     temporaryURL:tempURL
                                          artwork:artwork
                                 artworkAvailable:artworkAvailable];
}


- (instancetype)initWithInputURL:(NSURL *)inputURL
                       outputURL:(NSURL *)outputURL
                    temporaryURL:(NSURL *)tempURL
                         artwork:(NSImage *)artwork
                artworkAvailable:(BOOL)artworkAvailable {
    
    self = [super init];
    if (self) {
     
        _inputURL = inputURL;
        _outputURL = outputURL;
        _tempURL = tempURL;
        _artwork = artwork;
        _artworkAvailable = artworkAvailable;
    }
    return self;
}

@end
