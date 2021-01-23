#!/usr/bin/env bash

# Copyright 2020 Mike Carlton
#
# Released under terms of the MIT License:
#   http://carlton.mit-license.org/

### configuration info
# get version and signature from https://www.ruby-lang.org/en/downloads/

src="https://cache.ruby-lang.org/pub/ruby/3.0/ruby-3.0.0.tar.gz"
sha256="a13ed141a1c18eb967aac1e33f4d6ad5f21be1ac543c344e0d6feeee54af8e28"
config_options="--with-jemalloc"

### end of configuration

set -e
set -u

red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`

cd /tmp

file=$(basename "$src")
dir="${file/.tar.*/}"
shasums="/tmp/ruby.sha256"

echo "$sha256  $file" > "$shasums"

if [[ ! -f "$file" ]] || ! shasum -a 256 --status -c "$shasums" ; then
  echo "#{green}Downloading ${file}${reset}"
  curl -L -O "$src"
fi

if ! shasum -a 256 --status -c "$shasums" ; then
  echo "#{red}Unable to download ruby source, giving up${reset}"
  exit 1
fi

echo "${green}Installing build requirements${reset}"
sudo apt install -y build-essential libjemalloc-dev libssl-dev libreadline-dev zlib1g-dev libyaml-dev libncurses5-dev libffi-dev

if [[ ! -d "$dir" ]] ; then
  echo "${green}Unpacking source${reset}"
  tar -xf "$file"
fi

cd "$dir"

echo "${green}Configuring ruby${reset}"
./configure "${config_options}"

echo "${green}Building ruby${reset}"
make

echo "${green}Installing ruby${reset}"
sudo make install
