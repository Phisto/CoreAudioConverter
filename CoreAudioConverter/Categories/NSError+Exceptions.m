//
//  NSError+Exceptions.m
//  CoreAudioConverter
//
//  Created by Simon Gaus on 05.08.16.
//  Copyright © 2016 Simon Gaus. All rights reserved.
//

#import "NSError+Exceptions.h"

@implementation NSError (Exception)

+ (instancetype)errorWithException:(NSException *)exception domain:(NSString *)domain code:(NSInteger)code {
    
    NSMutableDictionary * info = [NSMutableDictionary dictionary];
    [info setValue:exception.name forKey:@"MONExceptionName"];
    [info setValue:exception.reason forKey:@"MONExceptionReason"];
    [info setValue:exception.callStackReturnAddresses forKey:@"MONExceptionCallStackReturnAddresses"];
    [info setValue:exception.callStackSymbols forKey:@"MONExceptionCallStackSymbols"];
    [info setValue:exception.userInfo forKey:@"MONExceptionUserInfo"];
    
    return [[NSError alloc] initWithDomain:domain
                                      code:code
                                  userInfo:[info copy]];
}

@end
