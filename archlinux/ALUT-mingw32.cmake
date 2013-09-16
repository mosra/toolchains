#
# Toolchain for crosscompiling ALUT applications for Windows on ArchLinux.
#
# Minimal dependencies:
#
#     mingw32-gcc
#     mingw32-openal
#     mingw32-freealut-bin
#

# Target system name
set(CMAKE_SYSTEM_NAME   Windows)

# Compilers and utilities
set(CMAKE_C_COMPILER    i486-mingw32-gcc)
set(CMAKE_CXX_COMPILER  i486-mingw32-g++)
set(CMAKE_STRIP         i486-mingw32-strip)
set(CMAKE_RC_COMPILER   i486-mingw32-windres)
set(QT_QMAKE_EXECUTABLE i486-mingw32-qmake)

# Croscompiler path
set(CMAKE_FIND_ROOT_PATH /usr/i486-mingw32)

# Find executables in root path, libraries and includes are in crosscompiler
# path
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

# FindQt4.cmake asks native QMake for variables, which surely cannot work when
# crosscompiling.
set(MINGW_PREFIX        /usr/i486-mingw32)

# Directories where to search for DLLs
set(DLL_SEARCH_PATH
    ${MINGW_PREFIX}/lib
    ${MINGW_PREFIX}/bin
)

# OpenAL, ALUT
set(OPENAL_INCLUDE_DIR ${MINGW_PREFIX}/include/AL)
set(ALUT_INCLUDE_DIR ${OPENAL_INCLUDE_DIR})
