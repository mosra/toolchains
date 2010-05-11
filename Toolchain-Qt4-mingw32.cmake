# Jméno cílového systému
SET(CMAKE_SYSTEM_NAME   Windows)

# Crosskompilátory
SET(CMAKE_C_COMPILER    i486-mingw32-gcc)
SET(CMAKE_CXX_COMPILER  i486-mingw32-g++)
SET(CMAKE_STRIP         i486-mingw32-strip)
SET(CMAKE_RC_COMPILER   i486-mingw32-windres)

# Root pro crosskompilátor
SET(CMAKE_FIND_ROOT_PATH /usr/i486-mingw32)

# Programy jsou v prostředí systému, knihovny a include má u sebe
# crosskompilátor
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

# FindQt4.cmake se ptá nativního cmake na proměnné, což zákonitě nemůže fungovat
# při kroskompilaci.
set(MINGW_PREFIX        /usr/i486-mingw32)
set(QT_BINARY_DIR       ${MINGW_PREFIX}/bin)
set(QT_LIBRARY_DIR      ${MINGW_PREFIX}/lib)
set(QT_QTCORE_LIBRARY   ${MINGW_PREFIX}/lib/libQtCore4.a)
set(QT_MKSPECS_DIR      ${MINGW_PREFIX}/mkspecs)
set(QT_MOC_EXECUTABLE   /usr/bin/moc)
set(QT_QMAKE_EXECUTABLE /usr/bin/qmake)
set(QT_UIC_EXECUTABLE   /usr/bin/uic)
set(QT_RCC_EXECUTABLE   /usr/bin/rcc)

# Moduly
set(QT_QTCORE_INCLUDE_DIR       ${MINGW_PREFIX}/include/QtCore)
set(QT_QTGUI_INCLUDE_DIR        ${MINGW_PREFIX}/include/QtGui)
set(QT_QTNETWORK_INCLUDE_DIR    ${MINGW_PREFIX}/include/QtNetwork)
set(QT_QTWEBKIT_INCLUDE_DIR     ${MINGW_PREFIX}/include/QtWebKit)
set(QT_QTSQL_INCLUDE_DIR        ${MINGW_PREFIX}/include/QtSql)
set(QT_QTXML_INCLUDE_DIR        ${MINGW_PREFIX}/include/QtXml)
