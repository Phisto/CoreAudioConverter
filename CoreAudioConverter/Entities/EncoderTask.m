//
//  EncoderTask.m
//  CoreAudioConverter
//
//  Created by Simon Gaus on 13.08.16.
//  Copyright © 2016 Simon Gaus. All rights reserved.
//

#import "EncoderTask.h"

@interface EncoderTask (/* Private */)

@property (nonatomic, strong) NSURL *tempURL;
@property (nonatomic, strong) NSURL *inputURL;
@property (nonatomic, strong) NSURL *outputURL;

@end

@implementation EncoderTask

+ (nullable instancetype)taskWithInputURL:(NSURL *)inputURL
                                outputURL:(NSURL *)outputURL
                             temporaryURL:(nullable NSURL *)tempURL {
    
    return [[[self class] alloc] initWithInputURL:inputURL
                                        outputURL:outputURL
                                     temporaryURL:tempURL];
}


- (instancetype)initWithInputURL:(NSURL *)inputURL
                       outputURL:(NSURL *)outputURL
                    temporaryURL:(nullable NSURL *)tempURL {
    
    if (!inputURL || !outputURL) {
        
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

- (NSURL *)tempURL {
    
    // if tempURL isnt set, just return outputURL.
    return (_tempURL) ? _tempURL : self.outputURL;
}

@end
