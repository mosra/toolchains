#
# Platform file for generic/Android.cmake toolchain
#

# Start from something sane and working
include(Platform/Linux)

# Reset the values so they don't accumulate
set(ANDROID_COMPILER_FLAGS )
set(ANDROID_LINKER_FLAGS )

# ARM-specific flags
if(${ANDROID_ARCHITECTURE} STREQUAL "arm")

    # Why do we need this?
    set(ANDROID_COMPILER_FLAGS "${ANDROID_COMPILER_FLAGS} -fPIC")

    # Have consistent FP ABI, use Neon by default
    set(ANDROID_COMPILER_FLAGS "${ANDROID_COMPILER_FLAGS} -mfloat-abi=softfp -mfpu=neon")

    # Fix hardware error in some Cortex A8 implementations
    # (is this still needed or already enabled by default?)
    set(ANDROID_LINKER_FLAGS "${ANDROID_LINKER_FLAGS} -Wl,--fix-cortex-a8")

    if(${ANDROID_ABI} STREQUAL "armeabi-v7a")
        set(ANDROID_COMPILER_FLAGS "${ANDROID_COMPILER_FLAGS} -march=armv7-a")
        set(ANDROID_LINKER_FLAGS "${ANDROID_LINKER_FLAGS} -march=armv7-a")
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
set(ANDROID_LINKER_FLAGS "${ANDROID_LINKER_FLAGS} -no-canonical-prefixes")

# Disallow undefined symbols, memory corruption mitigation, etc.
# This is needed to ensure that everything is really linked in, because it
# won't print any info on runtime
set(ANDROID_COMPILER_FLAGS "${ANDROID_COMPILER_FLAGS} -Wa,--noexecstack")
set(ANDROID_LINKER_FLAGS "${ANDROID_LINKER_FLAGS} -Wl,--no-undefined -Wl,-z,noexecstack -Wl,-z,relro -Wl,-z,now")

# Specify sysroot so the compiler and linker can find stuff
set(ANDROID_COMPILER_FLAGS "${ANDROID_COMPILER_FLAGS} --sysroot=${ANDROID_SYSROOT}")
set(ANDROID_LINKER_FLAGS "${ANDROID_LINKER_FLAGS} --sysroot=${ANDROID_SYSROOT}")

# Set the flags and make sure they don't get overriden
set(CMAKE_C_FLAGS "${ANDROID_COMPILER_FLAGS}" CACHE STRING "C compiler flags")
set(CMAKE_CXX_FLAGS "${ANDROID_COMPILER_FLAGS}" CACHE STRING "CXX compiler flags")
set(CMAKE_EXE_LINKER_FLAGS "${ANDROID_LINKER_FLAGS}" CACHE STRING "Executable linker flags")
set(CMAKE_SHARED_LINKER_FLAGS "${ANDROID_LINKER_FLAGS}" CACHE STRING "Shared library linker flags")
set(CMAKE_MODULE_LINKER_FLAGS "${ANDROID_LINKER_FLAGS}" CACHE STRING "Module linker flags")

# We are using GCC's libstdc++
include_directories(SYSTEM
    "${ANDROID_NDK_ROOT}/sources/cxx-stl/gnu-libstdc++/4.8/include"
    "${ANDROID_NDK_ROOT}/sources/cxx-stl/gnu-libstdc++/4.8/libs/${ANDROID_ABI}/include")
