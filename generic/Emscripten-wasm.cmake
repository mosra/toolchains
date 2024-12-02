#
# Toolchain for cross-compiling to JS using Emscripten with WebAssembly
#
# Modify EMSCRIPTEN_PREFIX to your liking; use EMSCRIPTEN environment variable
# to point to it or pass it explicitly via -DEMSCRIPTEN_PREFIX=<path>.
#
#  mkdir build-emscripten-wasm && cd build-emscripten-wasm
#  cmake .. -DCMAKE_TOOLCHAIN_FILE=../toolchains/generic/Emscripten-wasm.cmake
#
# On MSVC set "intelliSenseMode": "linux-gcc-x86" in CMakeSettings.json to get
# IntelliSense to work.

set(CMAKE_SYSTEM_NAME Emscripten)

# Help CMake find the platform file
set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR}/../modules ${CMAKE_MODULE_PATH})

# Give a hand to first-time Windows users
if(CMAKE_HOST_WIN32)
    if(CMAKE_GENERATOR MATCHES "Visual Studio")
        message(FATAL_ERROR "Visual Studio project generator doesn't support cross-compiling to Emscripten. Please use -G Ninja or other generators instead.")
    endif()
endif()

if(NOT EMSCRIPTEN_PREFIX)
    if(DEFINED ENV{EMSCRIPTEN})
        file(TO_CMAKE_PATH "$ENV{EMSCRIPTEN}" EMSCRIPTEN_PREFIX)
    # On Homebrew the sysroot is here, however emcc is also available in
    # /usr/local/bin. It's impossible to figure out the sysroot from there, so
    # try this first
    elseif(EXISTS "/usr/local/opt/emscripten/libexec/emcc")
        set(EMSCRIPTEN_PREFIX "/usr/local/opt/emscripten/libexec")
    # Some Linux distributions like Arch have it in /usr/lib/emscripten
    elseif(EXISTS "/usr/lib/emscripten")
        set(EMSCRIPTEN_PREFIX "/usr/lib/emscripten")
    # Look for emcc in the path as a last resort
    else()
        find_file(_EMSCRIPTEN_EMCC_EXECUTABLE emcc)
        if(NOT EXISTS ${_EMSCRIPTEN_EMCC_EXECUTABLE})
            message(FATAL_ERROR "Neither the EMSCRIPTEN_PREFIX CMake variable nor the EMSCRIPTEN environment variable was set and emcc wasn't found in PATH. Please specify either of the two explicitly.")
        endif()
        get_filename_component(EMSCRIPTEN_PREFIX ${_EMSCRIPTEN_EMCC_EXECUTABLE} DIRECTORY)
        mark_as_advanced(_EMSCRIPTEN_EMCC_EXECUTABLE)
    endif()
endif()

if(CMAKE_HOST_WIN32)
    set(EMCC_SUFFIX ".bat")
else()
    set(EMCC_SUFFIX "")
endif()

# MSVC IntelliSense requires these variables to be put into cache:
# https://devblogs.microsoft.com/cppblog/configure-intellisense-with-cmake-toolchain-files-in-visual-studio-2019-16-9-preview-2/
set(CMAKE_C_COMPILER "${EMSCRIPTEN_PREFIX}/emcc${EMCC_SUFFIX}" CACHE FILEPATH "C compiler" FORCE)
set(CMAKE_CXX_COMPILER "${EMSCRIPTEN_PREFIX}/em++${EMCC_SUFFIX}" CACHE FILEPATH "CXX compiler" FORCE)
# These variables are usually hidden in the Advanced section by default, but if
# given language isn't enabled for the project, there wouldn't be a pre-
# existing (advanced) CMAKE_<LANG>_COMPILER variable and so it'd show up in the
# default view.
mark_as_advanced(CMAKE_C_COMPILER CMAKE_CXX_COMPILER)

# The `CACHE PATH "bla"` *has to be* present as otherwise CMake < 3.13.0 would
# for some reason forget the path to `ar`, calling it as `"" qc bla`, failing
# with `/bin/sh: : command not found`. This is probably related to CMP0077 in
# some way but I didn't bother investigating further.
set(CMAKE_AR "${EMSCRIPTEN_PREFIX}/emar${EMCC_SUFFIX}" CACHE PATH "Path to Emscripten ar")
set(CMAKE_RANLIB "${EMSCRIPTEN_PREFIX}/emranlib${EMCC_SUFFIX}" CACHE PATH "Path to Emscripten ranlib")
# When CMAKE_INTERPROCEDURAL_OPTIMIZATION is set, CMake apparently uses these
# instead of CMAKE_AR and such. Couldn't find any official documentation on
# why, https://github.com/emscripten-core/emscripten/issues/11143 seems to be
# the only place mentioning this.
set(CMAKE_C_COMPILER_AR "${CMAKE_AR}")
set(CMAKE_CXX_COMPILER_AR "${CMAKE_AR}")
set(CMAKE_C_COMPILER_RANLIB "${CMAKE_RANLIB}")
set(CMAKE_CXX_COMPILER_RANLIB "${CMAKE_RANLIB}")

# Fetch Emscripten version, needed for the below setup. Taken from
# https://github.com/emscripten-core/emscripten/blob/74d6a15644e7f6e76ed6a1da9c6937b5cb7aef6e/cmake/Modules/Platform/Emscripten.cmake#L152
execute_process(COMMAND ${CMAKE_C_COMPILER} -v
    RESULT_VARIABLE _EMSCRIPTEN_VERSION_RESULT
    ERROR_VARIABLE EMSCRIPTEN_VERSION
    # The command should only print to the error output if it succeeds. If it
    # fails, we may want to know what's the standard output as well, so put
    # both to the same variable.
    OUTPUT_VARIABLE EMSCRIPTEN_VERSION)
if(NOT _EMSCRIPTEN_VERSION_RESULT EQUAL 0)
    message(FATAL_ERROR "Failed to query Emscripten version with the following output:\n${EMSCRIPTEN_VERSION}")
endif()
string(REGEX MATCH "emcc \\([^)]+\\) ([0-9\\.]+)" "\\1" "${EMSCRIPTEN_VERSION}")
if(NOT CMAKE_MATCH_1)
    message(FATAL_ERROR "Failed to extract Emscripten version from the following:\n${EMSCRIPTEN_VERSION}")
endif()
set(EMSCRIPTEN_VERSION ${CMAKE_MATCH_1})

# As of Emscripten 2.0.13, the whole include dir is copied over to the
# Emscripten cache dir in an attempt to have includes next to the libraries
# that were always built on-the-fly directly into the cache, such as libGL etc.
# See https://github.com/emscripten-core/emscripten/issues/9353 for the
# original discussion. Since 3.1.4, the cache dir is then the *only* sysroot
# that is complete, as it contains a generated version.h:
# https://github.com/emscripten-core/emscripten/pull/16147; and since 3.1.9
# it's not possible to use the system directory anymore:
# https://github.com/emscripten-core/emscripten/pull/16715.
#
# The inevitable consequence is that includes updated in the system path aren't
# automatically picked up, but only after explicitly copying the files to the
# cache dir with `embuilder build sysroot --force`. See
# https://github.com/emscripten-core/emscripten/pull/13090 for related
# discussion.
#
# The code in https://github.com/emscripten-core/emscripten/blob/0566a76b500bd2bbd535e108f657fce1db7f6f75/tools/system_libs.py#L2298-L2345
# however DOES NOT copy any binaries from lib/, only the include files, so
# <prefix>/system/lib still has to be added to CMAKE_FIND_ROOT_PATH. Yay for
# the "single sysroot" attempt, FFS.
#
# The cache dir can be queried by asking em-config. Taken from
# https://github.com/emscripten-core/emscripten/blob/74d6a15644e7f6e76ed6a1da9c6937b5cb7aef6e/cmake/Modules/Platform/Emscripten.cmake#L223
if(NOT EMSCRIPTEN_VERSION VERSION_LESS 2.0.13)
    execute_process(COMMAND ${EMSCRIPTEN_PREFIX}/em-config${EMCC_SUFFIX} CACHE
        RESULT_VARIABLE _EMSCRIPTEN_CACHE_RESULT
        OUTPUT_VARIABLE _EMSCRIPTEN_CACHE
        ERROR_VARIABLE _EMSCRIPTEN_CACHE_ERROR
        OUTPUT_STRIP_TRAILING_WHITESPACE)
    if(NOT _EMSCRIPTEN_CACHE_RESULT EQUAL 0)
        message(FATAL_ERROR "Failed to query Emscripten cache directory with the following output:\n${_EMSCRIPTEN_CACHE_ERROR}")
    endif()
    set(EMSCRIPTEN_SYSROOTS
        "${_EMSCRIPTEN_CACHE}/sysroot"
        "${EMSCRIPTEN_PREFIX}/system")
else()
    set(EMSCRIPTEN_SYSROOTS "${EMSCRIPTEN_PREFIX}/system")
endif()

set(CMAKE_FIND_ROOT_PATH ${CMAKE_FIND_ROOT_PATH}
    ${EMSCRIPTEN_SYSROOTS}
    ${EMSCRIPTEN_PREFIX})

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

# Otherwise FindCorrade fails to find _CORRADE_MODULE_DIR. Why the heck is this
# not implicit is beyond me.
set(CMAKE_SYSTEM_PREFIX_PATH ${CMAKE_FIND_ROOT_PATH})

# Compared to the classic (asm.js) compilation, -s WASM=1 is added to both
# compiler and linker. The *_INIT variables are available since CMake 3.7, so
# it won't work in earlier versions. Sorry. CMake 3.31+ warns if anything older
# than 3.10 is used, so it's used as the policy max version.
cmake_minimum_required(VERSION 3.7...3.10)
set(CMAKE_EXE_LINKER_FLAGS_INIT "-s WASM=1")
set(CMAKE_CXX_FLAGS_RELEASE_INIT "-DNDEBUG -O3 -flto")
set(CMAKE_EXE_LINKER_FLAGS_RELEASE_INIT "-O3 -flto")

# Look for Node.js. Ïf found, use it as the crosscompiling emulator. You can
# disable this behavior by defining CMAKE_CROSSCOMPILING_EMULATOR to empty.
if(NOT DEFINED CMAKE_CROSSCOMPILING_EMULATOR)
    # Not using find_package(NodeJs) as that'd mean I'd have to bundle
    # FindNodeJs. Additionally, I cannot use NodeJs::NodeJs here -- while
    # CORRADE_CROSSCOMPILING_EMULATOR set to NodeJs::NodeJs seems to work for
    # add_test(), it doesn't get expanded to the actual executable location for
    # the custom command in corrade_add_resource(), for example. So there's no
    # point in using FindNodeJs at all, simply just find_program() and reuse
    # the same variable so it doesn't try to find the same thing again in the
    # actual FindNodeJs.
    #
    # Also note that by creating the NodeJs::NodeJs target this early if
    # find_package(NodeJs) would be used, it makes it behave like it's not
    # project-local. A consequence of that is that if NodeJs::NodeJs is used
    # again as a COMMAND in add_test(), it *doesn't* get prepended with
    # CMAKE_CROSSCOMPILING_EMULATOR, whereas if the NodeJs::NodeJs target isn't
    # created here already, CMAKE_CROSSCOMPILING_EMULATOR gets prepended to
    # add_test(), leading to nodejs being twice in the command. See
    # https://github.com/mosra/corrade/issues/185 for more details.
    find_program(NODEJS_EXECUTABLE node)
    mark_as_advanced(NODEJS_EXECUTABLE)
    if(NODEJS_EXECUTABLE)
        # This is a verbatim copy from FindNodeJs.cmake, see above for why is
        # find_package(NodeJs) not called directly
        execute_process(COMMAND ${NODEJS_EXECUTABLE} --version
            OUTPUT_VARIABLE NodeJs_VERSION
            ERROR_QUIET OUTPUT_STRIP_TRAILING_WHITESPACE)
        if(NodeJs_VERSION MATCHES "^v[0-9]")
            string(SUBSTRING ${NodeJs_VERSION} 1 -1 NodeJs_VERSION)
        else()
            unset(NodeJs_VERSION)
        endif()

        # Node.js 18 doesn't work with Emscripten before 3.1.13 unless the
        # fetch functionality is disabled.
        #   https://github.com/emscripten-core/emscripten/pull/16917
        #   https://github.com/emscripten-core/emscripten/issues/16915
        #   https://cmake.org/cmake/help/latest/variable/CMAKE_CROSSCOMPILING_EMULATOR.html
        if(NodeJs_VERSION VERSION_GREATER_EQUAL 18.1.0 AND EMSCRIPTEN_VERSION VERSION_LESS 3.1.13)
            if(CMAKE_VERSION VERSION_LESS 3.15)
                message(FATAL_ERROR "In order to use Node.js 18 as a CMAKE_CROSSCOMPILING_EMULATOR with Emscripten older than 3.1.13, an extra flag needs to be passed, which requires CMake 3.15+. Use different versions or explicitly set CMAKE_CROSSCOMPILING_EMULATOR to empty to prevent it from being used.")
            endif()
            set(CMAKE_CROSSCOMPILING_EMULATOR "${NODEJS_EXECUTABLE};--no-experimental-fetch" CACHE FILEPATH "Path to the emulator for the target system.")
        else()
            set(CMAKE_CROSSCOMPILING_EMULATOR ${NODEJS_EXECUTABLE} CACHE FILEPATH "Path to the emulator for the target system.")
        endif()

        mark_as_advanced(CMAKE_CROSSCOMPILING_EMULATOR)
    endif()
endif()
