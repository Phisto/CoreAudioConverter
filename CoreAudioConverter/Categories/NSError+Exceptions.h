/*
 *  NSError+Exceptions.h
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

@import Foundation;

/**
 
 The Exception categorie adds the capability to create an error object from an NSException object to the NSError class.
 
 */

NS_ASSUME_NONNULL_BEGIN

@interface NSError (Exception)
#pragma mark - Create an error
///-------------------------------------------
/// @name Create an error
///-------------------------------------------

/**
 
 Creates and initializes an NSError object for a given domain and code the user info will be extracted from a given excepction.
 
 @param exception The exception to use for the error userInfo.
 
 @param domain The error domain.
 
 @param code The error code for the error.
 
 @return An NSError object for domain with the specified error code and the dictionary of arbitrary data userInfo extracted from the exeption.
 
 */
+ (instancetype)errorWithException:(NSException *)exception domain:(NSString *)domain code:(NSInteger)code;



@end
NS_ASSUME_NONNULL_END
