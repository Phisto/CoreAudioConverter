/*
 *  NSFileManager+FileAccess.m
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

#import "NSFileManager+FileAccess.h"

@implementation NSFileManager (FileAccess)
#pragma mark - Check file access


- (BOOL)path:(NSString *)path isAccessibleFor:(AccessKind)mode {
    
    return (access(path.fileSystemRepresentation, (int)mode) == noErr);
}


#pragma mark -
@end
