## Overview

The Core Audio Converter framework provides facilities for converting various audio file formats to MPEG Audio Layer III, 
more commonly referred to as MP3.

Supported Audio Formats:

- Audio Interchange File Format
- Apple Lossless Audio Codec
- Advanced Audio Coding


## Usage

To use the Core Audio Converter framework in your project, you must add the Core Audio Converter framework (CoreAudioConverter.framework) to the project. 

The Core Audio Converter framework is available for projects targeting macOS 10.10 or above.


##LAME

The Core Audio Converter framework is using LAME to encode files to MP3.

LAME is a high quality MPEG Audio Layer III encoder licensed under the GNU Lesser General Public License (LGPL).

For more information on LAME visit http://lame.sourceforge.net


##Audio File Tagger 
The Core Audio Converter framework is using the AudioFileTagger framework to tag the encoded MP3 files with ID3v2 tags.

The AudioFileTagger framework is licensed under the GNU Lesser General Public License (LGPL).

For more information on AudioFileTagger visit http://stack...

##License

Core Audio Converter is released under the GNU Lesser General Public License (LGPL). 

See <http://www.gnu.org/licenses/> for details.


# CoreAudioConverter
This is a framework to convert various audio file formats (aif | aiff | aac | m4a) to the mp3 format using LAME.

I used a lot of code from this repo: https://github.com/sbooth/Max

Don't use this in your productive code, or at least double check my source!

More informations about the LAME Project can be found here: http://lame.sourceforge.net/

IMPORTANT

Too use the code you have to add the lame library by hand:

- Install lame on your machine (i used homebrew: http://brew.sh/)
- add lame.h and libmp3lame.a to the project 

when using homebrew you can find this files in

    /usr/local/cellar/lame/<version>/lib
    /usr/local/cellar/lame/<version>/include/lame

USE

    NSError *error = nil;

    MP3Encoder *converter = [MP3Encoder encoderForFile:sourceUrl error:&error];

    if (!converter) {

        NSLog(@"converter init failed: %@", error.localizedDescription);
  
    }

    converter.delegate = self; // the delegate need to implement the <MP3EncoderDelegate> protocol

    [converter encodeToUrl:outputUrl];
    
    
