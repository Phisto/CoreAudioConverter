[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![License](https://img.shields.io/github/license/phisto/CoreAudioConverter.svg)](https://github.com/Phisto/CoreAudioConverter)


## Overview

The CoreAudioConverter framework provides facilities for converting various audio file formats to MPEG Audio Layer III, 
more commonly referred to as MP3.


## Supported Audio Formats

- Audio Interchange File Format (AIFF)
- Apple Lossless Audio Codec (ALAC)
- Advanced Audio Coding (ACC)


## Requirements

- macOS 10.10+
- Xcode 10.1+


## Installation

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks. To integrate CoreAudioConverter into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "Phisto/CoreAudioConverter" ~> 1.0
```

### Manually

If you prefer not to use Carthage, you can integrate CoreAudioConverter into your project manually.
You only need to build and add the CoreAudioConverter framework (CoreAudioConverter.framework) to your project. 


## Usage

```objectivec

// create the encoder task
NSURL *fileURL = <#...#>
NSURL *outFileUrl = <#...#>
EncoderTask *task = [EncoderTask taskWithInputURL:fileURL
                                        outputURL:outFileUrl
                                     temporaryURL:nil];

// create the encoder
MP3Encoder *mp3Encoder = [[MP3Encoder alloc] initWithDelegate:self];
if (!mp3Encoder) {
    <#// handle failure...#>
}


NSError *encodingError = nil;
BOOL erfolg = [mp3Encoder executeTask:task error:&encodingError];
if (!erfolg) {
    <#// handle failure...#>
}

```


## LAME

The CoreAudioConverter framework is using [LAME](http://lame.sourceforge.net/) to encode files to MP3.

LAME is a high quality MPEG Audio Layer III encoder licensed under the [GNU Lesser General Public License (LGPL)](https://www.gnu.org/licenses/). 


## Audio File Tagger 

The CoreAudioConverter framework is using the [AudioFileTagger](https://github.com/Phisto/AudioFileTagger) framework to tag the encoded MP3 files with ID3v2 tags.


## Credits

I learned a lot by browsing trough the [code repository](https://github.com/sbooth/Max) for the brilliant macOS application [Max](https://sbooth.org/Max/).


## License

CoreAudioConverter is released under the [GNU Lesser General Public License (LGPL)](https://www.gnu.org/licenses/). 

