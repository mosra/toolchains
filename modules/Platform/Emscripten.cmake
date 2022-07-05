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

# Prefixes/suffixes for building
set(CMAKE_STATIC_LIBRARY_PREFIX "")
set(CMAKE_STATIC_LIBRARY_SUFFIX ".bc")
set(CMAKE_EXECUTABLE_SUFFIX ".js")

# Prefixes/suffixes for finding libraries
set(CMAKE_FIND_LIBRARY_PREFIXES "")
set(CMAKE_FIND_LIBRARY_SUFFIXES ".bc")

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

# Include the UseEmscripten file with useful macros
include(UseEmscripten)
