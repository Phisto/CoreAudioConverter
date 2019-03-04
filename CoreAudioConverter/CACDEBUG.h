//
//  CACDEBUG.h
//  CoreAudioConverter
//
//  Created by Simon Gaus on 04.03.19.
//  Copyright © 2019 Simon Gaus. All rights reserved.
//

/**
 
 @brief CDCLog() will behave exactly as NSLog() in DEBUG builds but will do nothing in RELEASE builds.
 
 @brief CDCELog() will log extended information about the caller and other thinsg.
 
 */

#ifdef DEBUG
#define CDCLog(...) NSLog(__VA_ARGS__)
#define CDCELog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define CDCLog(...) /* No logging */
#define CDCELog(fmt, ...) /* No logging */
#endif
