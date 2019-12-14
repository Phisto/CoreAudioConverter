/*
*  CACDebug.h
*  CoreAudioConverter
*
*  Copyright © 2015-2019 Simon Gaus <simon.cay.gaus@gmail.com>
*
*  This program is free software; you can redistribute it and/or modify
*  it under the terms of the Lesser General Public License (LGPL) as published by
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

NS_ASSUME_NONNULL_BEGIN

/**
 
 Define DEBUG_LEVEL if it is not defined in the build settings.
 
 */
#ifndef DEBUG_LEVEL
#define DEBUG_LEVEL CACDebugLevelTrace
#endif

/**
 @enum CACDebugLevel
 @brief The debug level for a more fine grained control over what is logged.
 */
typedef NS_ENUM(NSUInteger, CACDebugLevel) {
    /// Only logs conditions that are fatal and should lead to an exception.
    CACDebugLevelFatal   = 0,
    /// Additionaly logs conditions regarded as an error and wont result in an exception.
    CACDebugLevelError   = 1,
    /// Additionaly logs information that could be helpfull for debugging.
    CACDebugLevelInfo    = 2,
    /// Logs everything. Meant for tracing the flow of the frameworks doings.
    CACDebugLevelTrace   = 3
};



/**
 
 @brief Prints the given message according to the defined DEBUG_LEVEL and the given debugLevel.
 
 @discussion This funktion will only log the message in DEBUG builds.
 
 @param debugLevel The debug level of the message.
 
 @param format The format string used to printing the format string.
 
 @param ... The arguments for the format sting.
 
 */
FOUNDATION_EXPORT void CACLog(CACDebugLevel debugLevel, NSString *format, ...) NS_FORMAT_FUNCTION(2,3) NS_NO_TAIL_CALL;



NS_ASSUME_NONNULL_END
