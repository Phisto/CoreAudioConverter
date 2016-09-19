//
//  NSFileManager+FileAccess.h
//  CoreAudioConverter
//
//  Created by Simon Gaus on 02.09.16.
//  Copyright © 2016 Simon Gaus. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    ///
    ReadAccess = R_OK,
    ///
    WriteAccess = W_OK,
    ///
    ExecuteAccess = X_OK,
    ///
    PathExists = F_OK
}AccessKind;

/**
 
 */
@interface NSFileManager (FileAccess)
/**
 @param path
 @param mode
 @return
 */
- (BOOL)path:(NSString *)path isAccessibleFor:(AccessKind)mode;

@end
NS_ASSUME_NONNULL_END
