#
# Platform file for generic/Emscripten.cmake toolchain
#

# Start from something sane and working
include(Platform/Linux)

if(_EMSCRIPTEN_INCLUDED)
    return()
endif()
set(_EMSCRIPTEN_INCLUDED 1)

# Set a global EMSCRIPTEN variable that can be used in client CMakeLists.txt to
# detect when building using Emscripten. The go-to way when using Corrade is
# to check CORRADE_TARGET_* variables, this is mainly to support 3rd party
# projects. It's set as INTERNAL to not be exposed through cmake-gui or ccmake
# which suggests it could be switched off.
set(EMSCRIPTEN ON CACHE INTERNAL "If true, we are targeting Emscripten output.")

# Make sure user-specified EMSCRIPTEN_PREFIX is propagated to try_compile()
# that's executed by CMakeTestCCompiler.cmake inside a project() call. Without
# that, the toolchain may fail to find the prefix even though EMSCRIPTEN_PREFIX
# is properly set in the outer scope.
set(CMAKE_TRY_COMPILE_PLATFORM_VARIABLES EMSCRIPTEN_PREFIX)

# Prefixes/suffixes for building. This used to be no prefix and *.bc, but as of
# 3.1.52 the *.bc extension is recognized as something different, resulting in
#   lib.bc:1:2: error: expected integer
#       1 | !<arch>
#         |  ^
# https://github.com/emscripten-core/emscripten/issues/21128
set(CMAKE_STATIC_LIBRARY_PREFIX "lib")
set(CMAKE_STATIC_LIBRARY_SUFFIX ".a")
set(CMAKE_EXECUTABLE_SUFFIX ".js")

# Prefixes/suffixes for finding libraries. Still recognizing the no-prefix and
# `*.bc` suffix for backwards compatibility, but note that 3.1.52+ will fail to
# use such files.
set(CMAKE_FIND_LIBRARY_PREFIXES ";lib")
set(CMAKE_FIND_LIBRARY_SUFFIXES ".bc;.a")

# Disable annoying warning about absolute includes
string(APPEND CMAKE_CXX_FLAGS " -Wno-warn-absolute-paths")

# Setting this prevents CMake from doing a relink on install (that is because
# of RPath, which is of no use on this platform). This also allows us to use
# Ninja, finally.
set(CMAKE_BUILD_WITH_INSTALL_RPATH TRUE)

# Emscripten has Clang underneath and it supports -isystem. For some reason the
# compiler autodetection fails to detect this and this cause overwhelming
# amount of spam messages when including third-party headers.
set(CMAKE_INCLUDE_SYSTEM_FLAG_CXX "-isystem")

# With Emscripten copying all its includes (but not libraries!) into the cache
# on 2.0.13, CMake configs (such as zstd's) have to be put into share/ (instead
# of lib/cmake/, which also gets copied) in the system directory in order to be
# able to locate the libraries. That however means the imported targets from
# those configs will use the system include directory, and passing it to the
# include path would result in issues with <emscripten/version.h> again. To fix
# that, this directory is marked as implicit. Which it actually isn't, but that
# doesn't matter, since the exact contents should be in its copy in the cache,
# which *is* among implicit include directories.
#
# This is slightly (but not completely) related to
#   https://github.com/emscripten-core/emscripten/issues/17132
# with the difference that there it caused an ordering issue with the
# `include/common`, while here is no ordering issue but it causes the wrong
# <emscripten/version.h> to be picked. In other words, again NONE of this crap
# would be needed if the doomed-to-fail version.h wasn't in the system include
# dir at all.
if(NOT EMSCRIPTEN_VERSION VERSION_LESS 2.0.13)
    list(APPEND CMAKE_C_IMPLICIT_INCLUDE_DIRECTORIES ${EMSCRIPTEN_PREFIX}/system/include)
    list(APPEND CMAKE_CXX_IMPLICIT_INCLUDE_DIRECTORIES ${EMSCRIPTEN_PREFIX}/system/include)
endif()

# Include the UseEmscripten file with useful macros
include(UseEmscripten)
