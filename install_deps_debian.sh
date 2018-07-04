#!/bin/bash

set -u
set -e


apt-get update
apt-get install -y git mercurial curl gcc make automake autoconf libtool cmake g++ pkg-config bison flex
apt-get install -y libfontconfig1-dev libfreetype6-dev libbz2-dev librubberband-dev libfftw3-dev libsamplerate0-dev
