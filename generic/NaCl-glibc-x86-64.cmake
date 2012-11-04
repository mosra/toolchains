#
# Toolchain for compiling NaCl applications for x86-64 using glibc.
#
# - Modify NACL_PREFIX to your liking
# - Add `cmake/` directory to CMAKE_MODULE_PATH, so NaCl platform file is
#   found
#

SET(CMAKE_SYSTEM_NAME NaCl)

set(NACL_PREFIX "/home/mosra/Code/nacl/nacl_sdk/pepper_22")

set(NACL_TOOLCHAIN glibc)
set(NACL_ARCH x86_64)
set(NACL_ARCH_GCC -m64)
set(NACL_ARCH_NMF x86-64)

set(NACL_TOOLCHAIN "${NACL_PREFIX}/toolchain/linux_x86_${NACL_TOOLCHAIN}/")

set(CMAKE_C_COMPILER   "${NACL_TOOLCHAIN}/bin/${NACL_ARCH}-nacl-gcc")
set(CMAKE_CXX_COMPILER "${NACL_TOOLCHAIN}/bin/${NACL_ARCH}-nacl-g++")
set(CMAKE_EXECUTABLE_SUFFIX ".nexe")

set(CMAKE_FIND_ROOT_PATH  "${NACL_TOOLCHAIN}/bin")
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)

set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
