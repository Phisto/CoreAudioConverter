/*
 *  NSError+Exceptions.m
 *  CoreAudioConverter
 *
 *  Copyright © 2015-2019 Simon Gaus <simon.cay.gaus@gmail.com>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU Lesser General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public License
 *  along with this library.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

#import "NSError+Exceptions.h"

@implementation NSError (Exception)
#pragma mark - Create an error


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


#pragma mark -
@end
