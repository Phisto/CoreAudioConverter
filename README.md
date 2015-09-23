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
