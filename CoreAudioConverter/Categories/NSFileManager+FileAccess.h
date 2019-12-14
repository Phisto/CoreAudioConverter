/*
 *  NSFileManager+FileAccess.h
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

NS_ASSUME_NONNULL_BEGIN

/**
 
 ## Overview
 These constants defines the different file access kinds. The values are taken from <unistd.h>.
 
 */
typedef NS_OPTIONS(NSInteger, AccessKind) {
    /// Test for read permission (1<<2)
    ReadAccess = R_OK,
    /// Test for write permission (1<<1)
    WriteAccess = W_OK,
    /// Test for execute or search permission (1<<0)
    ExecuteAccess = X_OK,
    /// Test for existence of file (0)
    PathExists = F_OK
};

/**
 
 The FileAccess categorie adds the capability to check for file access to the NSFileManager.
 
 ## Discussion
 This is implemented in a sandboxing friendly way, the sandbox won't be triggered if the calling application checks a file outside of it's sandbox.
 
 */
@interface NSFileManager (FileAccess)
#pragma mark - Check file access
///----------------------------------------------
/// @name Check file access
///----------------------------------------------

/**
 
 Determine whether a file or folder can be accessed.
 
 @see AccessKind enum for possible values for mode.
 
 @param path The path to the file or folder.
 
 @param mode The access mode to check for.
 
 @return Yes if the file or folder is accessible for the specified access mode, otherwise NO.
 
 */
- (BOOL)path:(NSString *)path isAccessibleFor:(AccessKind)mode;



@end
NS_ASSUME_NONNULL_END
