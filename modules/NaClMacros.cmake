# - Macros for simplifying development with Google Chrome Native Client
#
# Find and install libraries for bundling with NaCl build.
#  nacl_bundle_libs(library_install_dir
#                   dlls...
#                   [PATHS paths...])
# It is possible to specify also additional paths for searching. Library names
# can also contain paths, they will be installed into exact specified path. If
# any library is not found, fatal error message is printed.
#
# The libraries are installed into ${library_install_dir}/x86-32 or
# ${library_install_dir}/x86-64 based on the architecture used.
#
# See documentation of NaCl toolchains for more information.
#

function(nacl_bundle_libs library_install_dir)
    # Get library and path lists
    foreach(arg ${ARGN})
        if(${arg} STREQUAL PATHS)
            set(__DOING_PATHS ON)
        else()
            if(__DOING_PATHS)
                if(NACL_BITS STREQUAL 32)
                    set(arg ${arg}/32)
                endif()
                set(paths ${paths} ${arg})
            else()
                set(libs ${libs} ${arg})
            endif()
        endif()
    endforeach()

    # Find and install all libraries
    foreach(lib ${libs})
        # Separate filename from path
        get_filename_component(path ${lib} PATH)
        get_filename_component(filename ${lib} NAME)

        # Add current library's path to search paths
        foreach(_path ${paths})
            set(${lib}_paths ${${lib}_paths} ${_path}/${path})
        endforeach()

        find_file(${lib}_found ${filename} PATHS ${${lib}_paths}
            NO_DEFAULT_PATH)

        if(${lib}_found)
            install(FILES ${${lib}_found} DESTINATION ${library_install_dir}/${NACL_ARCH_NMF}/${path})
        else()
            message(FATAL_ERROR "Library ${lib} needed for bundle not found!")
        endif()
    endforeach()
endfunction()
