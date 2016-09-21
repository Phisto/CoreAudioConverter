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

@end

@implementation EncoderTask

+ (nullable instancetype)taskWithInputURL:(NSURL *)inputURL
                                outputURL:(NSURL *)outputURL
                             temporaryURL:(NSURL *)tempURL {
    
    return [[[self class] alloc] initWithInputURL:inputURL
                                        outputURL:outputURL
                                     temporaryURL:tempURL];
}


- (instancetype)initWithInputURL:(NSURL *)inputURL
                       outputURL:(NSURL *)outputURL
                    temporaryURL:(NSURL *)tempURL {
    
    if (!inputURL || !outputURL || !tempURL) {
        
        NSLog(@"Called %@ with nil argument.", NSStringFromSelector(_cmd));
        return nil;
    }
    
    self = [super init];
    
    if (self) {
     
        _inputURL = inputURL;
        _outputURL = outputURL;
        _tempURL = tempURL;

    }
    
    return self;
}

@end
