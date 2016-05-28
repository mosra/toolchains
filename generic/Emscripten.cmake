#
# Toolchain for cross-compiling to JS using Emscripten
#
# Modify EMSCRIPTEN_PREFIX to your liking or use EMSCRIPTEN environment
# variable to point to it.
#
#  mkdir build-emscripten && cd build-emscripten
#  cmake .. -DCMAKE_TOOLCHAIN_FILE=../toolchains/generic/Emscripten.cmake
#

set(CMAKE_SYSTEM_NAME Emscripten)

# Help CMake find the platform file
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_LIST_DIR}/../modules)

if(NOT EMSCRIPTEN_PREFIX)
    if($ENV{EMSCRIPTEN})
        set(EMSCRIPTEN_PREFIX $ENV{EMSCRIPTEN})
    else()
        set(EMSCRIPTEN_PREFIX "/usr/lib/emscripten")
    endif()
endif()

# Spoonfeed CMakeFindBinUtils.cmake, as explicitly set CMAKE_AR/CMAKE_RANLIB
# would get overwritten with empty string
set(_CMAKE_TOOLCHAIN_PREFIX em)
set(_CMAKE_TOOLCHAIN_LOCATION ${EMSCRIPTEN_PREFIX})

set(EMSCRIPTEN_TOOLCHAIN_PATH "${EMSCRIPTEN_PREFIX}/system")
set(CMAKE_C_COMPILER "${EMSCRIPTEN_PREFIX}/emcc")
set(CMAKE_CXX_COMPILER "${EMSCRIPTEN_PREFIX}/em++")
set(CMAKE_FIND_ROOT_PATH ${CMAKE_FIND_ROOT_PATH}
    "${EMSCRIPTEN_TOOLCHAIN_PATH}"
    "${EMSCRIPTEN_PREFIX}")

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
