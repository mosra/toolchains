This repository contains toolchains usable for crosscompiling with CMake. They
are meant to be used on ArchLinux, but they can also (with some directory
structure modifications) work on other systems.

How to use them?
================

Suppose you have sources which use CMake build system. Create new clean build
directory, pick any toolchain and run cmake with your selected toolchain in it,
e.g.:

    mkdir build-win
    cd build-win
    cmake -DCMAKE_TOOLCHAIN_FILE=~/toolchains/archlinux/Qt4-mingw32.cmake ..

Now you can compile (and install/package) the application as usual:

    make -j3
    make package
    make me happy

The result is application crosscompiled for given architecture and system (here
it is Qt4 application for Windows).

Dependencies for crosscompiling
===============================

Every toolchain file has listed dependecies, which are needed for successful
crosscompilation. Packages are available either in official ArchLinux
repositories, in AUR or, for more exotic architectures, in [my own repository](http://github.com/mosra/archlinux).
