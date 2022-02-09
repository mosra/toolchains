# - Android tools for CMake
#
#   android_create_apk(target manifest)
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
# The function also creates a new target ${target}-deploy which you can use to
# install the APK directly from the IDE / command-line.
#
# Limitations:
#
# - It's packaging just one ABI, the one you are currently building with CMake.
#   It might be possible to work around this somehow in the future, but so far
#   it's like this.
# - No resources are packed or compiled, it's wrapping just a single *.so in
#   the APK.
# - There is lots of autodetection that can go wrong.
#

cmake_minimum_required(VERSION 3.7) # Android support is since 3.7

# Override this to point to your debug.keystore location (and specify a
# password)
if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Windows")
    set(ANDROID_APKSIGNER_KEY --ks $ENV{USERPROFILE}/.android/debug.keystore --ks-pass pass:android CACHE STRING "")
else()
    set(ANDROID_APKSIGNER_KEY --ks $ENV{HOME}/.android/debug.keystore --ks-pass pass:android CACHE STRING "")
endif()

# Path to Android SDK. The build-tools/ subdirectory must exist.
if(NOT ANDROID_SDK)
    # On Arch it's /opt/android-sdk and /opt/android-ndk
    if(EXISTS ${CMAKE_ANDROID_NDK}/../android-sdk/build-tools)
        get_filename_component(ANDROID_SDK ${CMAKE_ANDROID_NDK}/../android-sdk/ REALPATH CACHE)
    # On CircleCI it's /opt/android/sdk/ndk/<VERSION>
    elseif(EXISTS ${CMAKE_ANDROID_NDK}/../../build-tools)
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

    # Package this file together with the manifest
    # TODO: is there some possibility to set the zip compression ~~speed~~
    #   draaaag? it's slow!
    # TODO: what about aapt2? there's -A but it puts the so into assets/ :(
    # TODO: can pass -0 so to not compress anything, yay! but then upload may
    #   be slower
    # TODO: for resources i need to add -m -J src/
    get_filename_component(manifest_absolute ${manifest} REALPATH)
    add_custom_command(OUTPUT ${unaligned_apk}
        COMMAND ${tools_root}/aapt package -f -M ${manifest_absolute} -I ${ANDROID_SDK}/platforms/android-${ANDROID_PLATFORM_VERSION}/android.jar -F ${unaligned_apk} ${apk_root}/bin
        COMMENT "Packaging ${target}-unaligned.apk"
        DEPENDS ${library_destination} ${manifest})

    # TODO: compiling resources like icons etc.

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
