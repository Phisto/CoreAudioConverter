/*
*  CoreAudioConverter.h
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

#import <Cocoa/Cocoa.h>

//! Project version number for CoreAudioConverter.
FOUNDATION_EXPORT double CoreAudioConverterVersionNumber;

//! Project version string for CoreAudioConverter.
FOUNDATION_EXPORT const unsigned char CoreAudioConverterVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <CoreAudioConverter/PublicHeader.h>

// Public
#import <CoreAudioConverter/EncoderTask.h>
#import <CoreAudioConverter/MP3Encoder.h>
#import <CoreAudioConverter/MP3EncoderDelegateProtocol.h>
#import <CoreAudioConverter/CADecoder.h>
