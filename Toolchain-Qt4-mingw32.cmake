# Target system name
SET(CMAKE_SYSTEM_NAME   Windows)

# Compilers and utilities
SET(CMAKE_C_COMPILER    i486-mingw32-gcc)
SET(CMAKE_CXX_COMPILER  i486-mingw32-g++)
SET(CMAKE_STRIP         i486-mingw32-strip)
SET(CMAKE_RC_COMPILER   i486-mingw32-windres)

# Croscompiler path
SET(CMAKE_FIND_ROOT_PATH /usr/i486-mingw32)

# Find executables in root path, libraries and includes are in crosscompiler
# path
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

# FindQt4.cmake asks native QMake for variables, which surely cannot work when
# crosscompiling.
set(MINGW_PREFIX        /usr/i486-mingw32)
set(QT_BINARY_DIR       ${MINGW_PREFIX}/bin)
set(QT_LIBRARY_DIR      ${MINGW_PREFIX}/lib)
set(QT_QTCORE_LIBRARY   ${MINGW_PREFIX}/lib/libQtCore4.a)
set(QT_MKSPECS_DIR      ${MINGW_PREFIX}/mkspecs)
set(QT_MOC_EXECUTABLE   /usr/bin/moc)
set(QT_QMAKE_EXECUTABLE /usr/bin/qmake)
set(QT_UIC_EXECUTABLE   /usr/bin/uic)
set(QT_RCC_EXECUTABLE   /usr/bin/rcc)

# Modules
set(QT_QTCORE_INCLUDE_DIR       ${MINGW_PREFIX}/include/QtCore)
set(QT_QTGUI_INCLUDE_DIR        ${MINGW_PREFIX}/include/QtGui)
set(QT_QTNETWORK_INCLUDE_DIR    ${MINGW_PREFIX}/include/QtNetwork)
set(QT_QTWEBKIT_INCLUDE_DIR     ${MINGW_PREFIX}/include/QtWebKit)
set(QT_QTSQL_INCLUDE_DIR        ${MINGW_PREFIX}/include/QtSql)
set(QT_QTXML_INCLUDE_DIR        ${MINGW_PREFIX}/include/QtXml)
