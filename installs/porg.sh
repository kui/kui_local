#!/bin/bash
# -*- coding: utf-8-unix -*-
set -eux

BASE="$(cd "$(dirname $0)"; pwd)"

. "${BASE}/commons.sh"

if is_ubuntu; then
    run sudo apt-get install build-essential gcc g++
# elif is_mac_os_x; then
#     run sudo port install "${MACPORTS_INSTALLS[@]}" || abort "Require MacPorts"
else
    echo "Non supported platform" >&2
    exit 1
fi

TMP="/tmp/porg"
mkdir -p "$TMP"

cd "$TMP"
wget "http://downloads.sourceforge.net/project/porg/porg-0.7.tar.gz"
tar zxf porg-0.7.tar.gz

cd porg-0.7
./configure
make
sudo make install

echo "Success"
