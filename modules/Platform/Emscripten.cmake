#
# Platform file for generic/Emscripten.cmake toolchain
#

# Start from something sane and working
include(Platform/Linux)

# TODO: with this suffix CMake is unable to find the libraries
# set(CMAKE_STATIC_LIBRARY_PREFIX "")
# set(CMAKE_STATIC_LIBRARY_SUFFIX ".bc")
set(CMAKE_EXECUTABLE_SUFFIX ".js")
