#
# Toolchain for cross-compiling to Android x86.
#
# Modify ANDROID_NDK_ROOT and ANDROID_API_LEVEL to your liking. You might also
# need to update ANDROID_TOOLCHAIN_PREFIX and ANDROID_TOOLCHAIN_ROOT to fit
# your system. You have to add modules/ directory to CMAKE_MODULE_PATH before
# using the toolchain file so Android platform file can be found, e.g.:
#
#  mkdir build-android-x86 && cd build-android-x86
#  cmake .. \
#       -DCMAKE_MODULE_PATH=/absolute/path/to/toolchains/modules \
#       -DCMAKE_TOOLCHAIN_FILE=../toolchains/generic/Android-x86.cmake
#
# Shared library compiled using this toolchain should behave the same as the
# one compiled with ndk-build. The libraries are then moved into
# libs/${ANDROID_ABI} to make it available for ant.
#

set(CMAKE_SYSTEM_NAME Android)

# NDK root
set(ANDROID_NDK_ROOT "/opt/android-ndk")

# API level to use
set(ANDROID_API_LEVEL "android-19")

# Toolchain. See ${ANDROID_NDK_ROOT}/toolchains/ for complete list
set(ANDROID_ARCHITECTURE "x86")
set(ANDROID_ABI "x86")
set(ANDROID_TOOLCHAIN "x86-4.8")
set(ANDROID_TOOLCHAIN_PREFIX "i686-linux-android")
set(ANDROID_TOOLCHAIN_ROOT "${ANDROID_NDK_ROOT}/toolchains/${ANDROID_TOOLCHAIN}/prebuilt/linux-x86_64/")

set(CMAKE_C_COMPILER "${ANDROID_TOOLCHAIN_ROOT}/bin/${ANDROID_TOOLCHAIN_PREFIX}-gcc")
set(CMAKE_CXX_COMPILER "${ANDROID_TOOLCHAIN_ROOT}/bin/${ANDROID_TOOLCHAIN_PREFIX}-g++")
set(CMAKE_FIND_ROOT_PATH ${CMAKE_FIND_ROOT_PATH}
    "${ANDROID_NDK_ROOT}/platform/${ANDROID_API_LEVEL}/arch-${ANDROID_ARCHITECTURE}"
    "${ANDROID_TOOLCHAIN_ROOT}")

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

# Native App Glue
set(ANDROID_NATIVE_APP_GLUE_INCLUDE_DIR "${ANDROID_NDK_ROOT}/sources/android/native_app_glue/")
set(ANDROID_NATIVE_APP_GLUE_SRC "${ANDROID_NATIVE_APP_GLUE_INCLUDE_DIR}/android_native_app_glue.c")

# Output dir for compiled stuff
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}/libs/${ANDROID_ABI}")
