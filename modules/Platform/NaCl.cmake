#
# Platform file for generic/NaCl-*.cmake toolchains
#

# Start from something sane and working
include(Platform/Linux)

set(CMAKE_EXECUTABLE_SUFFIX "-${NACL_ARCH_NMF}.nexe")

# TODO: This is getting overrriden somehow
set(CMAKE_C_FLAGS "${NACL_ARCH_GCC}")
set(CMAKE_CXX_FLAGS "${CMAKE_C_FLAGS}")

# Otherwise .so have paths instead of library names
set(CMAKE_PLATFORM_USES_PATH_WHEN_NO_SONAME 1)

# TODO: Will this need -lpthread also?
set(CMAKE_EXE_LINKER_FLAGS "-lppapi_cpp -lppapi")