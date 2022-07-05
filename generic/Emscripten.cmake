#
# Toolchain for cross-compiling to JS using Emscripten
#
# Modify EMSCRIPTEN_PREFIX to your liking; use EMSCRIPTEN environment variable
# to point to it or pass it explicitly via -DEMSCRIPTEN_PREFIX=<path>.
#
#  mkdir build-emscripten && cd build-emscripten
#  cmake .. -DCMAKE_TOOLCHAIN_FILE=../toolchains/generic/Emscripten.cmake
#
# On MSVC set "intelliSenseMode": "linux-gcc-x86" in CMakeSettings.json to get
# IntelliSense to work.

set(CMAKE_SYSTEM_NAME Emscripten)

# Help CMake find the platform file
set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/../modules ${CMAKE_MODULE_PATH})

# Give a hand to first-time Windows users
if(CMAKE_HOST_WIN32)
    if(CMAKE_GENERATOR MATCHES "Visual Studio")
        message(FATAL_ERROR "Visual Studio project generator doesn't support cross-compiling to Emscripten. Please use -G Ninja or other generators instead.")
    endif()
endif()

if(NOT EMSCRIPTEN_PREFIX)
    if(DEFINED ENV{EMSCRIPTEN})
        file(TO_CMAKE_PATH "$ENV{EMSCRIPTEN}" EMSCRIPTEN_PREFIX)
    # On Homebrew the sysroot is here, however emcc is also available in
    # /usr/local/bin. It's impossible to figure out the sysroot from there, so
    # try this first
    elseif(EXISTS "/usr/local/opt/emscripten/libexec/emcc")
        set(EMSCRIPTEN_PREFIX "/usr/local/opt/emscripten/libexec")
    # Look for emcc in the path as a last resort
    else()
        find_file(_EMSCRIPTEN_EMCC_EXECUTABLE emcc)
        if(EXISTS ${_EMSCRIPTEN_EMCC_EXECUTABLE})
            get_filename_component(EMSCRIPTEN_PREFIX ${_EMSCRIPTEN_EMCC_EXECUTABLE} DIRECTORY)
        else()
            set(EMSCRIPTEN_PREFIX "/usr/lib/emscripten")
        endif()
        mark_as_advanced(_EMSCRIPTEN_EMCC_EXECUTABLE)
    endif()
endif()

set(EMSCRIPTEN_TOOLCHAIN_PATH "${EMSCRIPTEN_PREFIX}/system")

if(CMAKE_HOST_WIN32)
    set(EMCC_SUFFIX ".bat")
else()
    set(EMCC_SUFFIX "")
endif()

# MSVC IntelliSense requires these variables to be put into cache:
# https://devblogs.microsoft.com/cppblog/configure-intellisense-with-cmake-toolchain-files-in-visual-studio-2019-16-9-preview-2/
set(CMAKE_C_COMPILER "${EMSCRIPTEN_PREFIX}/emcc${EMCC_SUFFIX}" CACHE FILEPATH "C compiler" FORCE)
set(CMAKE_CXX_COMPILER "${EMSCRIPTEN_PREFIX}/em++${EMCC_SUFFIX}" CACHE FILEPATH "CXX compiler" FORCE)

# The `CACHE PATH "bla"` *has to be* present as otherwise CMake < 3.13.0 would
# for some reason forget the path to `ar`, calling it as `"" qc bla`, failing
# with `/bin/sh: : command not found`. This is probably related to CMP0077 in
# some way but I didn't bother investigating further.
set(CMAKE_AR "${EMSCRIPTEN_PREFIX}/emar${EMCC_SUFFIX}" CACHE PATH "Path to Emscripten ar")
set(CMAKE_RANLIB "${EMSCRIPTEN_PREFIX}/emranlib${EMCC_SUFFIX}" CACHE PATH "Path to Emscripten ranlib")

set(CMAKE_FIND_ROOT_PATH ${CMAKE_FIND_ROOT_PATH}
    "${EMSCRIPTEN_TOOLCHAIN_PATH}"
    "${EMSCRIPTEN_PREFIX}")

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

# Otherwise FindCorrade fails to find _CORRADE_MODULE_DIR. Why the heck is this
# not implicit is beyond me.
set(CMAKE_SYSTEM_PREFIX_PATH ${CMAKE_FIND_ROOT_PATH})

# Since some unspecified release, -s WASM=1 is the default, so we need to
# explicitly say -s WASM=0 to use asm.js. The *_INIT variables are available
# since CMake 3.7, so it won't work in earlier versions. Sorry.
cmake_minimum_required(VERSION 3.7)
set(CMAKE_EXE_LINKER_FLAGS_INIT "-s WASM=0")
set(CMAKE_CXX_FLAGS_RELEASE_INIT "-DNDEBUG -O3")
set(CMAKE_EXE_LINKER_FLAGS_RELEASE_INIT "-O3 --llvm-lto 1")
