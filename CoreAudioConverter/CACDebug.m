/*
*  CACDebug.m
*  CoreAudioConverter
*
*  Copyright © 2015-2020 Simon Gaus <simon.cay.gaus@gmail.com>
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

#import "CACDebug.h"

#pragma mark - IMPLEMENTATION

void CACLog(CACDebugLevel debugLevel, NSString *format, ...) {
    
#if DEBUG
    
    va_list argp;
    va_start(argp, format);
    __unused NSString *log = [[NSString alloc] initWithFormat:format arguments:argp];
    va_end(argp);
    
    #pragma GCC diagnostic push
    #pragma GCC diagnostic ignored "-Wunreachable-code"
    
    if (debugLevel == CACDebugLevelFatal) {
        if (DEBUG_LEVEL >= CACDebugLevelFatal) {
            NSLog(@"%@", log);
        }
    }
    else if (debugLevel == CACDebugLevelError) {
        if (DEBUG_LEVEL >= CACDebugLevelError) {
            NSLog(@"%@", log);
        }
    }
    else if (debugLevel == CACDebugLevelInfo) {
        if (DEBUG_LEVEL >= CACDebugLevelInfo) {
            NSLog(@"%@", log);
        }
    }
    else if (debugLevel == CACDebugLevelTrace) {
        if (DEBUG_LEVEL >= CACDebugLevelTrace) {
            NSLog(@"%@", log);
        }
    }
    
    #pragma GCC diagnostic pop
    
#endif    
}

#pragma mark -
