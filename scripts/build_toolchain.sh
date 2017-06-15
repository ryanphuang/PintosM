#!/bin/bash

######################################################
# 
# Setup OS lab tool chain (i386-elf-* cross compiler). 
#
# Tested on Mac OS X.
#
# Author: Ryan Huang <huang@cs.jhu.edu>
#

perror()
{
  if [ $? -ne 0 ]; then
    echo $1
    exit 1
  fi
}

download_and_check()
{
  local fname=$(basename $1)
  cd $CWD/src
  # wget $1 
  if [ ! -f $fname ]; then
    echo "Failed to download $1"
    exit 1
  fi
  local checksum=$(shasum -a 256 $fname | cut -d' ' -f 1)
  if [ "$checksum" != "$2" ]; then
    echo "Corrupted or missing source $1: expecting $2 got $checksum"
    exit 1
  fi
  echo "Downloaded and verified $fname from $1"
  if [ $fname == *.tar.gz ]; then
    tar xzvf $fname
  elif [ $fname == *.tar.bz2 ]; then
    tar xjvf $fname
  elif [ $fname == *.tar.xz ]; then
    tar xJvf $fname
  else
    echo "Unrecognized archive extension $fname"
  fi
}

if [ $# -eq 0 ]; then
  CWD=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
else
  if [ ! -d $1 ]; then
    echo "Usage: $0 [DEST_DIR]"
    exit 1
  fi
  CWD=$(cd $1 && pwd)
fi

PREFIX=$CWD/dist
export PATH=$PREFIX/bin:$PATH
export DYLD_LIBRARY_PATH=$PREFIX/lib:$DYLD_LIBRARY_PATH
mkdir -p src build/{binutils,gcc,gdb} dist
TARGET=i386-elf

# Download sources
download_and_check https://ftp.gnu.org/gnu/binutils/binutils-2.27.tar.gz 26253bf0f360ceeba1d9ab6965c57c6a48a01a8343382130d1ed47c468a3094f
download_and_check https://ftp.gnu.org/gnu/gcc/gcc-6.2.0/gcc-6.2.0.tar.bz2 9944589fc722d3e66308c0ce5257788ebd7872982a718aa2516123940671b7c5
download_and_check https://ftp.gnu.org/gnu/gdb/gdb-7.9.1.tar.xz cd9c543a411a05b2b647dd38936034b68c2b5d6f10e0d51dc168c166c973ba40

cd $CWD/build/binutils
../../src/binutils-2.27/configure --prefix=$PREFIX --target=$TARGET \
  --disable-multilib --disable-nls --disable-werror
perror "Failed to configure binutils"
make -j8
perror "Failed to make binutils"
make install

cd $CWD/build/gcc
../../src/gcc-6.2.0/configure --prefix=$PREFIX --target=$TARGET \
  --disable-multilib --disable-nls --disable-werror --disable-libssp \
  --disable-libmudflap --with-newlib --without-headers --enable-languages=c,c++
perror "Failed to configure gcc"
make -j8 all-gcc 
perror "Failed to make gcc"
make install-gcc
make all-target-libgcc
perror "Failed to libgcc"
make install-target-libgcc

cd $CWD/build/gdb
../../src/gdb-7.9.1/configure --prefix=$PREFIX --target=$TARGET --disable-werror
perror "Failed to configure gdb"
make -j8
perror "Failed to make gdb"
make install
