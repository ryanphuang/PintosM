# Pintos
Labs for undergraduate OS class (600.318) at Johns Hopkins. [Pintos](http://pintos-os.org) 
is a teaching operating system for x86, challenging but not overwhelming, small
but realistic enough to understand OS in depth (it can run x86 machine and simulators 
including QEMU, Bochs and VMWare Player!). The main source code, documentation and assignments 
are developed by Ben Pfaff and others from Stanford (refer to its [LICENSE](./LICENSE)).

## Changes
The course instructor ([Ryan Huang](huang@cs.jhu.edu)) made some changes to the original
Pintos labs to tailor for his class. They include:
* Tweaks to Makefiles for tool chain configuration and some new targets
* Make qemu image and run it in non-test mode.
* TODO

## Setup
Developing Pintos requires standard Unix develop tools (make, ctags, Vim, gcc, etc.) 
and an 80x86 cross-compiler tool chain for generating code into ELF binary format
for 32-bit architecture. You may need to build the tool chain from source: a
quick test is to run `objdump -i | grep elf32-i386`, if it returns matching lines,
your system's default tool chain supports the target so you don't need to build
the tool chain. Otherwise, build the following:

* GNU binutils:
  - **URL**: https://ftp.gnu.org/gnu/binutils/binutils-2.27.tar.gz
  - **ENV**:
    ```bash
    PREFIX=/path/to/install
    export PATH=$PREFIX/bin:$PATH
    export LD_LIBRARY_PATH=$PREFIX/lib:$LD_LIBRARY_PATH
    ```
  - **build flag**
    ```bash
    $ cd binutils-2.27 && ./configure --prefix=$PREFIX --target=i386-elf \
      --disable-multilib --disable-nls --disable-werror
    $ make -j8
    $ make install
    ```

* GCC:  
  - **URL**: https://ftp.gnu.org/gnu/gcc/gcc-6.2.0/gcc-6.2.0.tar.bz2
  - **pre-requisite**:
    - `gmp`, `mpfr`, `mpc`
    - the corresponding versions can be downloaded using script `gcc-6.2.0/download_prerequisites`
  - **build flag**:
    ```bash
    $ cd gcc-6.2.0 && ./configure --prefix=$PREFIX --target=i386-elf \
    --disable-multilib --disable-nls --disable-werror --disable-libssp \
    --disable-libmudflap --with-newlib --without-headers --enable-languages=c,c++
    $ make -j8 all-gcc 
    $ make install-gcc
    $ make all-target-libgcc
    $ make install-target-libgcc
    ```

* GDB:
  - **URL**: https://ftp.gnu.org/gnu/gdb/gdb-7.9.1.tar.xz 
  - **build flag**:
   ```bash
    $ cd gdb-7.9.1 && ./configure --prefix=$PREFIX --target=i386-elf --disable-werror
    $ make -j8
    $ make install
   ```

A sample build script that does the above is provided at `scripts/build_toolchain.sh`. 
It has been tested on macOS Sierra and Ubuntu 16.04.

In addition to the compiler tool chain, it is best to run Pintos in x86 simulator,
QEMU and Bochs, rather than bare metal while doing development. 

TODO: build and instructions for QEMU/Bochs.
