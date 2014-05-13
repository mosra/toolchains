#
# Toolchain for crosscompiling 32bit Windows applications on ArchLinux.
#
# Minimal dependencies:
#
#     mingw-w64-gcc
#

# Target system name
set(CMAKE_SYSTEM_NAME   Windows)

# Compilers and utilities
set(CMAKE_C_COMPILER    i686-w64-mingw32-gcc)
set(CMAKE_CXX_COMPILER  i686-w64-mingw32-g++)
set(CMAKE_RC_COMPILER   i686-w64-mingw32-windres)

# Croscompiler path
set(CMAKE_FIND_ROOT_PATH ${CMAKE_FIND_ROOT_PATH}
    /usr/i686-w64-mingw32)

# This helps find_path(), otherwise it's not able to find e.g.
# /usr/i686-w64-mingw32/share/cmake/Corrade/. I don't know why it's needed when
# there is already CMAKE_FIND_ROOT_PATH, but probably related to
# http://public.kitware.com/Bug/view.php?id=14337
set(CMAKE_PREFIX_PATH /usr/i686-w64-mingw32)

# Find executables in root path, libraries and includes are in crosscompiler
# path
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

# Directories where to search for DLLs
set(MINGW_PREFIX /usr/i686-w64-mingw32)
set(DLL_SEARCH_PATH
    ${MINGW_PREFIX}/lib
    ${MINGW_PREFIX}/bin)
