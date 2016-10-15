#
# Platform file for generic/Emscripten.cmake toolchain
#

# Start from something sane and working
include(Platform/Linux)

# Prefixes/suffixes for building
set(CMAKE_STATIC_LIBRARY_PREFIX "")
set(CMAKE_STATIC_LIBRARY_SUFFIX ".bc")
set(CMAKE_EXECUTABLE_SUFFIX ".js")

# Prefixes/suffixes for finding libraries. If I leave just "" in
# CMAKE_FIND_LIBRARY_PREFIXES, CMake then sometimes complains that the variable
# is empty, this works around that.
set(CMAKE_FIND_LIBRARY_PREFIXES "" "somebogusprefix")
set(CMAKE_FIND_LIBRARY_SUFFIXES ".bc")

# Disable annoying warning about absolute includes
set(CMAKE_CXX_FLAGS "-Wno-warn-absolute-paths")

# Best possible options for code size in release mode
set(CMAKE_CXX_FLAGS_RELEASE "-DNDEBUG -O3 --closure 1" CACHE STRING "Flags used by Emscripten compiler for Release builds")
set(CMAKE_EXE_LINKER_FLAGS_RELEASE "-O3 --closure 1 --llvm-lto 1" CACHE STRING "Flags used by Emscripten linker for Release builds")

# Setting this prevents CMake from doing a relink on install (that is because
# of RPath, which is of no use on this platform). This also allows us to use
# Ninja, finally.
set(CMAKE_BUILD_WITH_INSTALL_RPATH TRUE)

# Emscripten has Clang underneath and it supports -isystem. For some reason the
# compiler autodetection fails to detect this and this cause overwhelming
# amount of spam messages when including third-party headers.
set(CMAKE_INCLUDE_SYSTEM_FLAG_CXX "-isystem")
