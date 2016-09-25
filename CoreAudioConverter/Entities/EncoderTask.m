/*
 *  EncoderTask.m
 *  CoreAudioConverter
 *
 *  Copyright © 2016 Simon Gaus <simon.cay.gaus@gmail.com>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

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
