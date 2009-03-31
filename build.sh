#!/bin/sh

# I'm using air-config.xml because that has the right triggers
# for flash 10 compilation.

$HOME/lib/flex/bin/mxmlc -load-config $HOME/lib/flex/frameworks/air-config.xml GenerateAudio.as

