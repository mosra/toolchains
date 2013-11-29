# Target system name
set(CMAKE_SYSTEM_NAME   Linux)

# Compilers and utilities
set(CMAKE_C_COMPILER    arm-angstrom-linux-gnueabi-gcc)
set(CMAKE_CXX_COMPILER  arm-angstrom-linux-gnueabi-g++)

# Croscompiler paths
set(CMAKE_FIND_ROOT_PATH ${CMAKE_FIND_ROOT_PATH}
    /usr/local/angstrom/arm
    /usr/local/angstrom/arm/arm-angstrom-linux-gnueabi/usr
)

# Libraries and includes are in crosscompiler path
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

# Set installation prefix
set(CMAKE_INSTALL_PREFIX /usr/local/angstrom/arm/arm-angstrom-linux-gnueabi/usr)
