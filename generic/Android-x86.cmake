#
# Toolchain for cross-compiling to Android x86.
#
# Modify ANDROID_NDK_ROOT and ANDROID_SYSROOT to your liking. You might also
# need to update ANDROID_TOOLCHAIN_PREFIX and ANDROID_TOOLCHAIN_ROOT to fit
# your system.
#
#  mkdir build-android-x86 && cd build-android-x86
#  cmake .. -DCMAKE_TOOLCHAIN_FILE=../toolchains/generic/Android-x86.cmake
#
# Shared library compiled using this toolchain should behave the same as the
# one compiled with ndk-build. The libraries should be then moved into
# libs/${ANDROID_ABI} to make it available for ant, e.g.:
#
#  set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}/libs/${ANDROID_ABI}")
#

set(CMAKE_SYSTEM_NAME Android)
set(ANDROID_ARCHITECTURE "x86")
set(ANDROID_ABI "x86")

# Help CMake find the platform file
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_LIST_DIR}/../modules)

# NDK root. It *has* to be passed as environment variable and not via -D,
# because this toolchain file gets included from project() and then from
# CMakeSystem.cmake, which FOR SOME REASON doesn't propagate stuff passed from
# command-line. I SPENT TWO DAYS FIGHTING THIS, GODDAMIT.
if(DEFINED ENV{ANDROID_NDK})
    set(ANDROID_NDK_ROOT $ENV{ANDROID_NDK})
else()
    if(WINDOWS)
        set(ANDROID_NDK_ROOT "C:/Users/Squareys/Documents/android-ndk-r11b")
    else()
        set(ANDROID_NDK_ROOT "/opt/android-ndk")
    endif()
endif()

# API level to use
set(ANDROID_SYSROOT "${ANDROID_NDK_ROOT}/platforms/android-19/arch-${ANDROID_ARCHITECTURE}")

# Toolchain. See ${ANDROID_NDK_ROOT}/toolchains/ for complete list
set(ANDROID_TOOLCHAIN "x86-4.9")
set(ANDROID_TOOLCHAIN_PREFIX "i686-linux-android")
set(ANDROID_TOOLCHAIN_ROOT "${ANDROID_NDK_ROOT}/toolchains/${ANDROID_TOOLCHAIN}/prebuilt/linux-x86_64/")

set(CMAKE_C_COMPILER "${ANDROID_TOOLCHAIN_ROOT}/bin/${ANDROID_TOOLCHAIN_PREFIX}-gcc")
set(CMAKE_CXX_COMPILER "${ANDROID_TOOLCHAIN_ROOT}/bin/${ANDROID_TOOLCHAIN_PREFIX}-g++")
set(CMAKE_FIND_ROOT_PATH ${CMAKE_FIND_ROOT_PATH}
    ${ANDROID_TOOLCHAIN_ROOT}
    ${ANDROID_SYSROOT})

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

# Native App Glue
set(ANDROID_NATIVE_APP_GLUE_INCLUDE_DIR "${ANDROID_NDK_ROOT}/sources/android/native_app_glue/")
set(ANDROID_NATIVE_APP_GLUE_SRC "${ANDROID_NATIVE_APP_GLUE_INCLUDE_DIR}/android_native_app_glue.c")

# The rest is shared between ARM and x86
include(${CMAKE_CURRENT_LIST_DIR}/../modules/AndroidSetup.cmake)
