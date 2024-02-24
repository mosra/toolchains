This repository contains toolchains usable for crosscompiling with CMake.
They're tailored for and mainly used by [Magnum](https://github.com/mosra/magnum)
but should work for other projects as well.

USAGE
=====

Assuming a CMake project, point `CMAKE_TOOLCHAIN_FILE` to one of the toolchain
files during the initial CMake invocation. While relative paths may work in
certain cases, it's better to always pass an absolute path. The
`CMAKE_TOOLCHAIN_FILE` variable is only used by CMake during the initial run,
it's ignored (and thus doesn't even need to be specified) in subsequent runs.

    mkdir build-emscripten && cd build-emscripten
    cmake .. -DCMAKE_TOOLCHAIN_FILE=path/to/toolchains/generic/Emscripten-wasm.cmake

The toolchain file then sets up other paths (such as pointing
`CMAKE_MODULE_PATH` to the `modules/Platform/` directory) and the process will
result in a configured build directory that can be subsequently used as any
other. See comments in particular toolchain files for platform-specific
details.

CONTACT & SUPPORT
=================

This project is maintained as part of Magnum, so it shares the same suppport
channels:

-   Project homepage — https://magnum.graphics/
-   Documentation — https://doc.magnum.graphics/
-   GitHub — https://github.com/mosra/toolchains and the
    [#magnum](https://github.com/topics/magnum) topic
-   GitLab — https://gitlab.com/mosra/toolchains
-   Gitter community chat — https://gitter.im/mosra/magnum
-   E-mail — info@magnum.graphics
-   Google Groups mailing list — magnum-engine@googlegroups.com
    ([archive](https://groups.google.com/forum/#!forum/magnum-engine))
-   Twitter — https://twitter.com/czmosra and the
    [#MagnumEngine](https://twitter.com/hashtag/MagnumEngine) hashtag

See also the Magnum Project [Contact & Support page](https://magnum.graphics/contact/)
for further information.

LICENSE
=======

While Magnum itself and its documentation are licensed under the MIT/Expat
license, the toolchains are put into public domain (or UNLICENSE) to free you
from any legal obstacles when using these to build your apps. See the
[COPYING](COPYING) file for details.
