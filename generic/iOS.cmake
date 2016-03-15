#
# Toolchain for cross-compiling to iOS using Xcode
#
# Set CMAKE_OSX_ROOT to SDK you want to target and enable all desired
# architectures in CMAKE_OSX_ARCHITECTURES. You have to addd modules/ directory
# to CMAKE_MODULE_PATH before using the toolchain file so the iOS platform file
# can be found.
#
#  mkdir build-ios && cd build-ios
#  cmake -DCMAKE_MODULE_PATH=/path/to/toolchains/modules/ \
#        -DCMAKE_TOOLCHAIN_FILE=../toolchains/generic/iOS.cmake \
#        -DCMAKE_OSX_SYSROOT=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk \
#        -DCMAKE_OSX_ARCHITECTURES="arm64;armv7;armv7s" -G Xcode ..
#

# We just need to name the platform differently so CMAKE_CROSSCOMPILING is set
set(CMAKE_SYSTEM_NAME "iOS")

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
