## Overview

The Core Audio Converter framework provides facilities for converting various audio file formats to MPEG Audio Layer III, 
more commonly referred to as MP3.

Supported Audio Formats:

- Audio Interchange File Format
- Apple Lossless Audio Codec
- Advanced Audio Coding


## Usage

To use the CoreAudioConverter framework in your project, you must add the CoreAudioConverter framework (CoreAudioConverter.framework) to the project. 

The CoreAudioConverter framework is available for projects targeting macOS 10.10 or above.


##LAME

The CoreAudioConverter framework is using LAME to encode files to MP3.

LAME is a high quality MPEG Audio Layer III encoder licensed under the GNU Lesser General Public License (LGPL).

For more information on LAME visit http://lame.sourceforge.net


##Audio File Tagger 
The CoreAudioConverter framework is using the AudioFileTagger framework to tag the encoded MP3 files with ID3v2 tags.

The AudioFileTagger framework is licensed under the GNU Lesser General Public License (LGPL).

For more information on AudioFileTagger visit http://git...

## Credits

I used a lot of code from this repo: https://github.com/sbooth/Max

##License

Core Audio Converter is released under the GNU Lesser General Public License (LGPL). 

See <http://www.gnu.org/licenses/> for details.
