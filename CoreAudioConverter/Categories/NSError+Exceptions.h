//
//  NSError+Exceptions.h
//  CoreAudioConverter
//
//  Created by Simon Gaus on 05.08.16.
//  Copyright © 2016 Simon Gaus. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN
/**
 
 */
@interface NSError (Exception)
/**
 @param exception
 @param domain
 @param code
 @return
 */
+ (instancetype)errorWithException:(NSException *)exception domain:(NSString *)domain code:(NSInteger)code;

@end
NS_ASSUME_NONNULL_END
