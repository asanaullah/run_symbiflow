#!/bin/bash
export CXX="g++ -std=c++03"

mkdir gcc_build
cd gcc_build
${PWD}/../gcc-4.8.2/configure --prefix=${PWD}/../gcc --enable-languages=c,c++  --disable-multilib --disable-libsanitizer
make -j8
make install
cd ..
export CC="${PWD}/gcc/bin/gcc"
export CXX="${PWD}/gcc/bin/g++"


