# - Macros for simplifying development with Mingw32
#
# Find and install DLLs for bundling with Windows build.
#  corrade_bundle_dlls(library_install_dir
#                      dlls...
#                      [PATHS paths...])
# It is possible to specify also additional paths for searching. DLL names can
# also contain paths, they will be installed into exact specified path. If an
# DLL is not found, fatal error message is printed.
#

function(mingw_bundle_dlls library_install_dir)
    # Default search path, taken from mingw32.cmake toolchain
    if(DLL_SEARCH_PATH)
        set(paths ${DLL_SEARCH_PATH})
    endif()

    # Get DLL and path lists
    foreach(arg ${ARGN})
        if(${arg} STREQUAL PATHS)
            set(__DOING_PATHS ON)
        else()
            if(__DOING_PATHS)
                set(paths ${paths} ${arg})
            else()
                set(dlls ${dlls} ${arg})
            endif()
        endif()
    endforeach()

    # Find and install all DLLs
    foreach(dll ${dlls})
        # Separate filename from path
        get_filename_component(path ${dll} PATH)
        get_filename_component(filename ${dll} NAME)

        # Add current DLL's path to search paths
        foreach(_path ${paths})
            set(${dll}_paths ${${dll}_paths} ${_path}/${path})
        endforeach()

        find_file(${dll}_found ${filename} PATHS ${${dll}_paths}
            NO_DEFAULT_PATH)

        if(${dll}_found)
            install(FILES ${${dll}_found} DESTINATION ${library_install_dir}/${path})
        else()
            message(FATAL_ERROR "DLL ${dll} needed for bundle not found!")
        endif()
    endforeach()
endfunction()
