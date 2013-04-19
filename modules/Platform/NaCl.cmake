#
# Platform file for generic/NaCl-*.cmake toolchains
#

# Start from something sane and working
include(Platform/Linux)

set(CMAKE_EXECUTABLE_SUFFIX "-${NACL_ARCH_NMF}.nexe")

# TODO: This is getting overrriden somehow
set(CMAKE_C_FLAGS "${NACL_ARCH_GCC}")
set(CMAKE_CXX_FLAGS "${CMAKE_C_FLAGS}")
