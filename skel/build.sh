#!/bin/bash

cd build || exit 1
git clone https://github.com/singularityware/singularity.git
cd singularity || exit 1
git checkout "$SINGULARITY_VERSION"
./autogen.sh
./configure
make
make install
make clean
