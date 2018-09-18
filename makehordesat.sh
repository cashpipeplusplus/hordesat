#!/bin/bash

# get submodules
git submodule update --init

# make minisat
(cd submodules/minisat
cmake CMakeLists.txt
make)

# make lingeling
(cd submodules/lingeling
./configure.sh
make)

# make hordesat
(cd hordesat-src
make
mv hordesat ..)
