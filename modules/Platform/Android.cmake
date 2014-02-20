#
# Platform file for generic/Android.cmake toolchain
#

# Start from something sane and working
include(Platform/Linux)

# Reset the values so they don't accumulate
set(CMAKE_C_FLAGS )
set(CMAKE_CXX_FLAGS )
set(CMAKE_EXE_LINKER_FLAGS )

# ARM-specific flags
if(${ANDROID_ARCHITECTURE} STREQUAL "arm")

    # Why do we need this?
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fPIC")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC")

    # Have consistent FP ABI, use Neon by default
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -mfloat-abi=softfp -mfpu=neon")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -mfloat-abi=softfp -mfpu=neon")

    # Fix hardware error in some Cortex A8 implementations
    # (is this still needed or already enabled by default?)
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,--fix-cortex-a8")

    if(${ANDROID_ABI} STREQUAL "armeabi-v7a")
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -march=armv7-a")
        set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -march=armv7-a")
    else()
        message(FATAL_ERROR "Unsupported Android ARM ABI ${ANDROID_ABI}")
    endif()

# x86-specific flags
elseif(${ANDROID_ARCHITECTURE} STREQUAL "x86")
    # (None)

# Otherwise unsupported
else()
    message(FATAL_ERROR "Unsupported Android ABI ${ANDROID_ABI}")
endif()

# Fix distributed build on GCC 4.6+
# https://android-review.googlesource.com/#/c/47564/
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -no-canonical-prefixes")

# Disallow undefined symbols, memory corruption mitigation, etc.
# This is needed to ensure that the native_app_glue is really linked in
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wa,--noexecstack")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wa,--noexecstack")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,--no-undefined -Wl,-z,noexecstack -Wl,-z,relro -Wl,-z,now")

# Specify sysroot so the compiler and linker can find stuff
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} --sysroot=${ANDROID_SYSROOT}")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} --sysroot=${ANDROID_SYSROOT}")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} --sysroot=${ANDROID_SYSROOT}")

# Make sure the flags don't get overriden
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS}" CACHE STRING "C compiler flags")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}" CACHE STRING "CXX compiler flags")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS}" CACHE STRING "Linker flags")
