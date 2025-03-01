#!/bin/bash

set -eou pipefail

# create and switch to build dir (Build Tree)
mkdir -p build
cd build

# configure
cmake -S .. -DCMAKE_CXX_COMPILER=/usr/bin/g++-13

# verify configuration
#cmake -LAH ..

# build
cmake --build .

# test
ctest
