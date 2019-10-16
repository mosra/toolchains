#
# Toolchain for cross-compiling to iOS using Xcode
#
# Set CMAKE_OSX_ROOT to SDK you want to target and enable all desired
# architectures in CMAKE_OSX_ARCHITECTURES.
#
#  mkdir build-ios && cd build-ios
#  cmake .. \
#       -DCMAKE_TOOLCHAIN_FILE=../toolchains/generic/iOS.cmake \
#       -DCMAKE_OSX_SYSROOT=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk \
#       -DCMAKE_OSX_ARCHITECTURES="arm64;armv7;armv7s" -G Xcode
#

# We just need to name the platform differently so CMAKE_CROSSCOMPILING is set
set(CMAKE_SYSTEM_NAME "iOS")

# Help CMake find the platform file
set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/../modules ${CMAKE_MODULE_PATH})

# Required to make CMake's test_compile stuff pass
# https://cmake.org/Bug/view.php?id=15329
set(CMAKE_MACOSX_BUNDLE ON)
set(CMAKE_XCODE_ATTRIBUTE_CODE_SIGNING_REQUIRED "NO")

set(CMAKE_FIND_ROOT_PATH ${CMAKE_FIND_ROOT_PATH}
    ${CMAKE_OSX_SYSROOT}
    ${CMAKE_OSX_SYSROOT}/../.. # XCTest framework is there, e.g.
    ${CMAKE_PREFIX_PATH}
    ${CMAKE_INSTALL_PREFIX})

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

# iOS has pthreads too, only CMake doesn't know that
# source: https://stackoverflow.com/a/54606606
set(CMAKE_THREAD_LIBS_INIT "-lpthread")
set(CMAKE_HAVE_THREADS_LIBRARY 1)
set(CMAKE_USE_WIN32_THREADS_INIT 0)
set(CMAKE_USE_PTHREADS_INIT 1)
set(THREADS_PREFER_PTHREAD_FLAG ON)
