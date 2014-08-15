#!/bin/bash
set -o nounset
set -o errexit

# this script is designed to run on debian/ubuntu
# how do I handle copying jarvis' json file of secrets

# check if $1 was provided, if not, echo "ARGV[1] should be <user>@<ip>"
test -z $1 && echo "ARGV[1] should be <user>@<ip>"
# check if $1 has ruby, if not, install ruby through apt-get
if [ -z $(which ruby) ]
    apt-get install ruby
fi
# check if $1 has git, if not, install git through apt-get
if [ -z $(which git) ]
    apt-get install git
fi
# check if $1 has bundler, if not, install bundler with gem install bundler
if [ -z $(which bundler) ]
    gem install bundler
fi
# check if $1 has jarvis already cloned, if so, blow it away
if [ -d "./jarvis" ]
    cd jarvis && git pull
else
    git clone https://github.com/stijlist/jarvis && cd jarvis
fi
bundle
ruby jarvis.rb
