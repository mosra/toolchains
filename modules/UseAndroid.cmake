# - Android tools for CMake
#
#   android_create_apk(<target> <manifest>
#       [RESOURCE_DIRECTORY <res>]
#       [ASSET_DIRECTORY <assets>])
#
# The script should autodetect the `ANDROID_SDK`, `ANDROID_BUILD_TOOLS_VERSION`,
# `ANDROID_PLATFORM_VERSION` variables and print them to the configure output.
# If it doesn't or the values are different than you'd like, set them from the
# CMake cache.
#
# You may want to update `ANDROID_APKSIGNER_KEY` to match your keystore
# location and password. Here I just took the default debug.keystore that
# Gradle generated on my system and guesstimated its password to be "android".
#
# You can pass a path to a directory with resources using `RESOURCE_DIRECTORY`,
# which will then get copied to the APK. Similarly, a directory with assets can
# be specified with `ASSET_DIRECTORY`. Both options track file dependencies, so
# the APK gets repacked when any files in the directories change contents, are
# added or removed. CMake before 3.12 checks the directories only during CMake
# runs, on newer versions at every incremental build.
#
# The function also creates a new target ${target}-deploy which you can use to
# install the APK directly from the IDE / command-line.
#
# Limitations:
#
# - It's packaging just one ABI, the one you are currently building with CMake.
#   It might be possible to work around this somehow in the future, but so far
#   it's like this.
# - There is lots of autodetection that can go wrong.
#

# Android support is since 3.7. 3.10 matches Corrade requirement, see its root
# CMakeLists for more information.
cmake_minimum_required(VERSION 3.7...3.10)

# Override this to point to your debug.keystore location (and specify a
# password)
if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
    set(ANDROID_APKSIGNER_KEY --ks $ENV{USERPROFILE}/.android/debug.keystore --ks-pass pass:android CACHE STRING "")
else()
    set(ANDROID_APKSIGNER_KEY --ks $ENV{HOME}/.android/debug.keystore --ks-pass pass:android CACHE STRING "")
endif()

# Path to Android SDK. The tools/source.properties file is expected to exist to
# avoid accidentally matching some arbitrary other directory.
if(NOT ANDROID_SDK)
    # Use the env var, if present
    if(DEFINED ENV{ANDROID_SDK_ROOT})
        set(ANDROID_SDK $ENV{ANDROID_SDK_ROOT})
    # On Arch it's /opt/android-sdk and /opt/android-ndk
    elseif(EXISTS ${CMAKE_ANDROID_NDK}/../android-sdk/tools/source.properties)
        get_filename_component(ANDROID_SDK ${CMAKE_ANDROID_NDK}/../android-sdk/ REALPATH CACHE)
    # On CircleCI it's /opt/android/sdk/ndk/<VERSION>
    elseif(EXISTS ${CMAKE_ANDROID_NDK}/../../tools/source.properties)
        get_filename_component(ANDROID_SDK ${CMAKE_ANDROID_NDK}/../../ REALPATH CACHE)
    # Otherwise no idea
    endif()

    if(ANDROID_SDK)
        message(STATUS "ANDROID_SDK not set, detected ${ANDROID_SDK}")
    else()
        message(FATAL_ERROR "ANDROID_SDK not set and autodetection failed")
    endif()
endif()

# Build tools version to use. Picks the newest version.
if(NOT ANDROID_BUILD_TOOLS_VERSION)
    file(GLOB _ANDROID_BUILD_TOOLS_FOR_VERSION RELATIVE ${ANDROID_SDK}/build-tools/ ${ANDROID_SDK}/build-tools/*.*.*)
    if(NOT _ANDROID_BUILD_TOOLS_FOR_VERSION)
        message(FATAL_ERROR "No Android build tools found in ${ANDROID_SDK}/build-tools")
    endif()
    list(GET _ANDROID_BUILD_TOOLS_FOR_VERSION -1 ANDROID_BUILD_TOOLS_VERSION)
    set(ANDROID_BUILD_TOOLS_VERSION ${ANDROID_BUILD_TOOLS_VERSION} CACHE STRING "")
    if(ANDROID_BUILD_TOOLS_VERSION)
        message(STATUS "ANDROID_BUILD_TOOLS_VERSION not set, detected ${ANDROID_BUILD_TOOLS_VERSION}")
    else()
        message(FATAL_ERROR "ANDROID_BUILD_TOOLS_VERSION not set and autodetection failed")
    endif()
endif()

# Platform version that matches build tools version.
# TODO: why not CMAKE_SYSTEM_VERSION?
if(NOT ANDROID_PLATFORM_VERSION)
    string(REGEX REPLACE "([0-9]+)\\.[0-9]+\\.[0-9]+" "\\1" ANDROID_PLATFORM_VERSION ${ANDROID_BUILD_TOOLS_VERSION})
    set(ANDROID_PLATFORM_VERSION ${ANDROID_PLATFORM_VERSION} CACHE STRING "")
    if(ANDROID_PLATFORM_VERSION)
        message(STATUS "ANDROID_PLATFORM_VERSION not set, detected ${ANDROID_PLATFORM_VERSION}")
    else()
        message(FATAL_ERROR "ANDROID_PLATFORM_VERSION not set and autodetection failed")
    endif()
endif()

function(android_create_apk target manifest)
    cmake_parse_arguments(CREATE_APK "" "RESOURCE_DIRECTORY;ASSET_DIRECTORY" "" ${ARGN})
    if(CREATE_APK_UNPARSED_ARGUMENTS)
        string (REPLACE ";" " " CREATE_APK_UNPARSED_ARGUMENTS "${CREATE_APK_UNPARSED_ARGUMENTS}")
        message(SEND_ERROR "Unrecognized android_create_apk() arguments: ${CREATE_APK_UNPARSED_ARGUMENTS}")
    endif()

    set(jar ${ANDROID_SDK}/platforms/android-${ANDROID_PLATFORM_VERSION}/android.jar)
    if(NOT EXISTS ${jar})
        message(SEND_ERROR "Android platform JAR not found at ${jar}")
    endif()

    set(tools_root ${ANDROID_SDK}/build-tools/${ANDROID_BUILD_TOOLS_VERSION})
    set(apk_root ${CMAKE_CURRENT_BINARY_DIR}/${target}-apk)
    # TODO: can't use $<TARGET_FILE_NAME:target> here because of
    # https://gitlab.kitware.com/cmake/cmake/issues/12877 -- mention that in
    # limitations
    set(library_destination_path ${apk_root}/bin/lib/${CMAKE_ANDROID_ARCH_ABI})
    set(library_destination ${library_destination_path}/lib${target}.so)
    set(unaligned_apk ${apk_root}/${target}-unaligned.apk)
    set(unsigned_apk ${apk_root}/${target}-unsigned.apk)
    set(apk ${CMAKE_CURRENT_BINARY_DIR}/${target}.apk)

    # Copy the library to the destination, stripping it in the process. It
    # needs to be in a folder that corresponds to its ABI, otherwise the java
    # interface won't find it. Without the strip the apk creation would take
    # *ages*.
    add_custom_command(OUTPUT ${library_destination}
        COMMAND ${CMAKE_COMMAND} -E make_directory ${library_destination_path}
        COMMAND ${CMAKE_STRIP} $<TARGET_FILE:${target}> -o ${library_destination}
        COMMENT "Copying stripped ${target} for an APK build"
        DEPENDS $<TARGET_FILE:${target}>)

    # Pass a path to the resource directory, if specified, and track the
    # dependencies
    if(CREATE_APK_RESOURCE_DIRECTORY)
        get_filename_component(resource_directory_absolute ${CREATE_APK_RESOURCE_DIRECTORY} REALPATH)
        set(resources -S ${resource_directory_absolute})

        # Glob all resource files in given directory to properly repack the APK
        # when they change. Additionally, on CMake 3.12+ make sure the
        # directory is globbed again on every build to ensure newly appearing
        # files are properly picked up.
        if(NOT CMAKE_VERSION VERSION_LESS 3.12)
            set(glob_configure_depends CONFIGURE_DEPENDS)
        endif()
        file(GLOB_RECURSE resource_files ${glob_configure_depends} ${resource_directory_absolute}/*)

        # On the other hand, if a file gets removed from the directory, or a
        # file with an old timestamp gets added, it won't trigger a repack. To
        # fix that, record also the list of actual globbed files and track it
        # as another dependency. To avoid a repack on every CMake run, (ab)use
        # configure_file() to write it with a changed timestamp only if the
        # list actually changes.
        file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/${target}-resource-dependencies.txt.orig ${resource_files})
        configure_file(${CMAKE_CURRENT_BINARY_DIR}/${target}-resource-dependencies.txt.orig ${CMAKE_CURRENT_BINARY_DIR}/${target}-resource-dependencies.txt COPYONLY)
        list(APPEND resource_files ${CMAKE_CURRENT_BINARY_DIR}/${target}-resource-dependencies.txt)
    endif()

    # Pass a path to the asset directory, if specified, and track the
    # dependencies. Logic the same as in the CREATE_APK_RESOURCE_DIRECTORY
    # above.
    if(CREATE_APK_ASSET_DIRECTORY)
        get_filename_component(asset_directory_absolute ${CREATE_APK_ASSET_DIRECTORY} REALPATH)
        set(assets -A ${asset_directory_absolute})

        if(NOT CMAKE_VERSION VERSION_LESS 3.12)
            set(glob_configure_depends CONFIGURE_DEPENDS)
        endif()
        file(GLOB_RECURSE asset_files ${glob_configure_depends} ${asset_directory_absolute}/*)

        file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/${target}-asset-dependencies.txt.orig ${resource_files})
        configure_file(${CMAKE_CURRENT_BINARY_DIR}/${target}-asset-dependencies.txt.orig ${CMAKE_CURRENT_BINARY_DIR}/${target}-asset-dependencies.txt COPYONLY)
        list(APPEND asset_files ${CMAKE_CURRENT_BINARY_DIR}/${target}-asset-dependencies.txt)
    endif()

    # Package this file together with the manifest
    # TODO: is there some possibility to set the zip compression ~~speed~~
    #   draaaag? it's slow!
    # TODO: what about aapt2? there's -A but it puts the so into assets/ :(
    # TODO: can pass -0 so to not compress anything, yay! but then upload may
    #   be slower
    # TODO: for resources i need to add -m -J src/
    get_filename_component(manifest_absolute ${manifest} REALPATH)
    add_custom_command(OUTPUT ${unaligned_apk}
        COMMAND ${tools_root}/aapt package -f
            -M ${manifest_absolute}
            ${resources} # present only if RESOURCE_DIRECTORY was specified
            ${assets} # present only if ASSET_DIRECTORY was specified
            -I ${ANDROID_SDK}/platforms/android-${ANDROID_PLATFORM_VERSION}/android.jar
            -F ${unaligned_apk}
            ${apk_root}/bin
        COMMENT "Packaging ${target}-unaligned.apk"
        DEPENDS ${library_destination} ${manifest} ${resource_files} ${asset_files})

    # Align the APK
    add_custom_command(OUTPUT ${unsigned_apk}
        COMMAND ${tools_root}/zipalign -f 4 ${unaligned_apk} ${unsigned_apk}
        COMMENT "Aligning ${target}-unsigned.apk"
        DEPENDS ${unaligned_apk})

    # Sign the APK
    # TODO: make this configurable better
    add_custom_command(OUTPUT ${apk}
        COMMAND ${tools_root}/apksigner sign ${ANDROID_APKSIGNER_KEY} --out ${apk} ${unsigned_apk}
        COMMENT "Signing ${target}.apk"
        DEPENDS ${unsigned_apk})

    # Make the APK dependency of an "always build" target so it gets built by
    # default
    add_custom_target(${target}-apk ALL DEPENDS ${apk})

    # Add an explicit deploy target for easy install
    add_custom_target(${target}-deploy
        COMMAND ${ANDROID_SDK}/platform-tools/adb install -r ${apk}
        COMMENT "Installing ${target}.apk"
        DEPENDS ${apk})

    # TODO: Could be also possible to do this, but that makes sense only for
    # projects that only ever have just one APK output -- have it as an option?
    # The COMPONENTS is useless as one can't just `ninja install/component` :(
    # install(CODE "execute_process(COMMAND adb install -r ${apk})"
    #     EXCLUDE_FROM_ALL)
endfunction()
