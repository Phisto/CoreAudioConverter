/*
 *  NSError+Exceptions.m
 *  CoreAudioConverter
 *
 *  Copyright © 2015-2016 Simon Gaus <simon.cay.gaus@gmail.com>
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
