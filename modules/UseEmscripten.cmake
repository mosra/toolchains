# - Macros for simplifying development with Emscripten
#
# Embed file into the virtual filesystem of given executable
#  emscripten_embed_file(MyExecutable
#                   path/to/file
#                   /path/in/virtual/filesystem)
# File path is absolute or relative to current source directory, path in
# virtual filesystem should start with `/`. Supports both files and
# directories. Useful e.g. in case of unit tests where you are testing output
# against some external file and manually embedding that file just to test on
# Emscripten is just not worth it.
#

function(emscripten_embed_file target file destination)
    get_filename_component(absolute_file ${file} ABSOLUTE)
    get_target_property(${target}_LINK_FLAGS ${target} LINK_FLAGS)
    if(NOT ${target}_LINK_FLAGS)
        set(${target}_LINK_FLAGS )
    endif()
    set_target_properties(${target} PROPERTIES LINK_FLAGS "${${target}_LINK_FLAGS} --embed-file ${absolute_file}@${destination}")
endfunction()
