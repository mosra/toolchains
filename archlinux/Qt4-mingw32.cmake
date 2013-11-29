#
# Toolchain for crosscompiling Qt4 application for Windows on ArchLinux.
#
# Minimal dependencies:
#
#     mingw32-gcc
#     mingw32-qt
#

# Target system name
set(CMAKE_SYSTEM_NAME   Windows)

# Compilers and utilities
set(CMAKE_C_COMPILER    i486-mingw32-gcc)
set(CMAKE_CXX_COMPILER  i486-mingw32-g++)
set(CMAKE_RC_COMPILER   i486-mingw32-windres)
set(QT_QMAKE_EXECUTABLE i486-mingw32-qmake)

# Croscompiler path
set(CMAKE_FIND_ROOT_PATH ${CMAKE_FIND_ROOT_PATH}
    /usr/i486-mingw32)

# Find executables in root path, libraries and includes are in crosscompiler
# path
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

# FindQt4.cmake asks native QMake for variables, which surely cannot work when
# crosscompiling.
set(MINGW_PREFIX        /usr/i486-mingw32)
set(QT_LIBRARY_DIR      ${MINGW_PREFIX}/lib)
set(QT_MKSPECS_DIR      ${MINGW_PREFIX}/mkspecs)

# Modules
set(QT_INCLUDE_DIR              ${MINGW_PREFIX}/include)
set(QT_QTCORE_INCLUDE_DIR       ${MINGW_PREFIX}/include/QtCore)
set(QT_QTGUI_INCLUDE_DIR        ${MINGW_PREFIX}/include/QtGui)
set(QT_QTNETWORK_INCLUDE_DIR    ${MINGW_PREFIX}/include/QtNetwork)
set(QT_QTWEBKIT_INCLUDE_DIR     ${MINGW_PREFIX}/include/QtWebKit)
set(QT_QTSQL_INCLUDE_DIR        ${MINGW_PREFIX}/include/QtSql)
set(QT_QTXML_INCLUDE_DIR        ${MINGW_PREFIX}/include/QtXml)
set(QT_PHONON_INCLUDE_DIR       ${MINGW_PREFIX}/include/phonon)

# Directories where to search for DLLs
set(DLL_SEARCH_PATH
    ${MINGW_PREFIX}/lib
    ${MINGW_PREFIX}/bin
    ${MINGW_PREFIX}/bin/qt-plugins/plugins
)
