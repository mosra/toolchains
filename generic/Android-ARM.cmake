#
# Toolchain for cross-compiling to Android ARM.
#
# Modify ANDROID_NDK_ROOT and ANDROID_SYSROOT to your liking. You might also
# need to update ANDROID_TOOLCHAIN_PREFIX and ANDROID_TOOLCHAIN_ROOT to fit
# your system. You have to add modules/ directory to CMAKE_MODULE_PATH before
# using the toolchain file so Android platform file can be found, e.g.:
#
#  mkdir build-android-arm && cd build-android-arm
#  cmake .. \
#       -DCMAKE_MODULE_PATH=/absolute/path/to/toolchains/modules \
#       -DCMAKE_TOOLCHAIN_FILE=../toolchains/generic/Android-ARM.cmake
#
# Shared library compiled using this toolchain should behave the same as the
# one compiled with ndk-build. The libraries should be then moved into
# libs/${ANDROID_ABI} to make it available for ant, e.g.:
#
#  set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}/libs/${ANDROID_ABI}")
#

set(CMAKE_SYSTEM_NAME Android)
set(ANDROID_ARCHITECTURE "arm")
set(ANDROID_ABI "armeabi-v7a")

# NDK root
set(ANDROID_NDK_ROOT "/opt/android-ndk")

# API level to use
set(ANDROID_SYSROOT "${ANDROID_NDK_ROOT}/platforms/android-19/arch-${ANDROID_ARCHITECTURE}")

# Toolchain. See ${ANDROID_NDK_ROOT}/toolchains/ for complete list
set(ANDROID_TOOLCHAIN "arm-linux-androideabi-4.8")
set(ANDROID_TOOLCHAIN_PREFIX "arm-linux-androideabi")
set(ANDROID_TOOLCHAIN_ROOT "${ANDROID_NDK_ROOT}/toolchains/${ANDROID_TOOLCHAIN}/prebuilt/linux-x86_64/")

set(CMAKE_C_COMPILER "${ANDROID_TOOLCHAIN_ROOT}/bin/${ANDROID_TOOLCHAIN_PREFIX}-gcc")
set(CMAKE_CXX_COMPILER "${ANDROID_TOOLCHAIN_ROOT}/bin/${ANDROID_TOOLCHAIN_PREFIX}-g++")
set(CMAKE_FIND_ROOT_PATH ${CMAKE_FIND_ROOT_PATH}
    "${ANDROID_SYSROOT}"
    "${ANDROID_TOOLCHAIN_ROOT}")

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

# Native App Glue
set(ANDROID_NATIVE_APP_GLUE_INCLUDE_DIR "${ANDROID_NDK_ROOT}/sources/android/native_app_glue/")
set(ANDROID_NATIVE_APP_GLUE_SRC "${ANDROID_NATIVE_APP_GLUE_INCLUDE_DIR}/android_native_app_glue.c")
