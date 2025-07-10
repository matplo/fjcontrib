# FindFastJet.cmake
# Find the FastJet library and headers
#
# This module defines:
#  FASTJET_FOUND       - True if FastJet is found
#  FASTJET_INCLUDE_DIRS - Include directories for FastJet
#  FASTJET_LIBRARIES   - Libraries to link for FastJet
#  FASTJET_VERSION     - Version string of FastJet
#
# You can help this module find FastJet by setting:
#  FASTJET_DIR         - Environment variable pointing to FastJet installation root

# Get FASTJET_DIR from environment if set
if(DEFINED ENV{FASTJET_DIR})
    set(FASTJET_DIR $ENV{FASTJET_DIR})
    message(STATUS "Using FASTJET_DIR: ${FASTJET_DIR}")
endif()

find_package(PkgConfig QUIET)

# Try to find fastjet using pkg-config first
if(PKG_CONFIG_FOUND)
    # Add FASTJET_DIR to pkg-config search path if set
    if(FASTJET_DIR)
        set(ENV{PKG_CONFIG_PATH} "${FASTJET_DIR}/lib/pkgconfig:$ENV{PKG_CONFIG_PATH}")
    endif()
    pkg_check_modules(PC_FASTJET QUIET fastjet)
endif()

# Find the header file
find_path(FASTJET_INCLUDE_DIR
    NAMES fastjet/PseudoJet.hh
    HINTS 
        ${PC_FASTJET_INCLUDEDIR} 
        ${PC_FASTJET_INCLUDE_DIRS} 
        ${FASTJET_DIR}/include
        ${FASTJET_DIR}
    PATH_SUFFIXES include
    DOC "FastJet include directory"
)

# Find the library
find_library(FASTJET_LIBRARY
    NAMES fastjet
    HINTS 
        ${PC_FASTJET_LIBDIR} 
        ${PC_FASTJET_LIBRARY_DIRS} 
        ${FASTJET_DIR}/lib
        ${FASTJET_DIR}/lib64
        ${FASTJET_DIR}
    PATH_SUFFIXES lib lib64
    DOC "FastJet library"
)

# Find fastjet-config for additional info
find_program(FASTJET_CONFIG
    NAMES fastjet-config
    HINTS 
        ${PC_FASTJET_PREFIX}/bin 
        ${PC_FASTJET_BINDIR} 
        ${FASTJET_DIR}/bin
        ${FASTJET_DIR}
    DOC "FastJet configuration script"
)

# Get version from fastjet-config if available
if(FASTJET_CONFIG)
    execute_process(
        COMMAND ${FASTJET_CONFIG} --version
        OUTPUT_VARIABLE FASTJET_VERSION
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    
    # Get additional compiler flags
    execute_process(
        COMMAND ${FASTJET_CONFIG} --cxxflags
        OUTPUT_VARIABLE FASTJET_CXXFLAGS
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    
    # Get library flags
    execute_process(
        COMMAND ${FASTJET_CONFIG} --libs --plugins
				# --plugins is optional, but useful if you want to link against plugins
        OUTPUT_VARIABLE FASTJET_LDFLAGS
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )

		# execute_process(
		# 	COMMAND ${FASTJET_CONFIG} --plugins
		# 	OUTPUT_VARIABLE FASTJET_PLUGINS
		# 	OUTPUT_STRIP_TRAILING_WHITESPACE
		# )

    # Parse the library flags to separate libraries and link directories
    if(FASTJET_LDFLAGS)
        # Split the flags and process them
        separate_arguments(FASTJET_LDFLAGS_LIST UNIX_COMMAND "${FASTJET_LDFLAGS}")
        set(FASTJET_LINK_LIBRARIES "")
        set(FASTJET_LINK_DIRECTORIES "")
        
        foreach(flag ${FASTJET_LDFLAGS_LIST})
            if(flag MATCHES "^-L(.+)")
                list(APPEND FASTJET_LINK_DIRECTORIES "${CMAKE_MATCH_1}")
            elseif(flag MATCHES "^-l(.+)")
                list(APPEND FASTJET_LINK_LIBRARIES "${CMAKE_MATCH_1}")
            else()
                # Other flags (like -framework on macOS)
                list(APPEND FASTJET_LINK_LIBRARIES "${flag}")
            endif()
        endforeach()
    endif()
endif()

# Handle standard arguments
include(FindPackageHandleStandardArgs)

# Debug output
if(CMAKE_BUILD_TYPE STREQUAL "Debug" OR FASTJET_DEBUG)
    message(STATUS "FastJet Debug Info:")
    message(STATUS "  FASTJET_DIR: ${FASTJET_DIR}")
    message(STATUS "  FASTJET_INCLUDE_DIR: ${FASTJET_INCLUDE_DIR}")
    message(STATUS "  FASTJET_LIBRARY: ${FASTJET_LIBRARY}")
    message(STATUS "  FASTJET_CONFIG: ${FASTJET_CONFIG}")
    message(STATUS "  FASTJET_LDFLAGS: ${FASTJET_LDFLAGS}")
    message(STATUS "  FASTJET_CXXFLAGS: ${FASTJET_CXXFLAGS}")
    message(STATUS "  FASTJET_LIBRARIES (final): ${FASTJET_LIBRARIES}")
    message(STATUS "  PC_FASTJET_FOUND: ${PC_FASTJET_FOUND}")
endif()

find_package_handle_standard_args(FastJet
    REQUIRED_VARS FASTJET_LIBRARY FASTJET_INCLUDE_DIR
    VERSION_VAR FASTJET_VERSION
)

if(FASTJET_FOUND)
    # Set basic variables
    set(FASTJET_LIBRARIES ${FASTJET_LIBRARY})
    set(FASTJET_INCLUDE_DIRS ${FASTJET_INCLUDE_DIR})
    
    # If we have fastjet-config, prefer its output for linking
    if(FASTJET_CONFIG AND FASTJET_LDFLAGS)
        # Use the full ldflags from fastjet-config for most complete linking
        set(FASTJET_LIBRARIES ${FASTJET_LDFLAGS})
        
        # Also set the parsed components for flexibility
        if(FASTJET_LINK_LIBRARIES)
            set(FASTJET_LINK_LIBS ${FASTJET_LINK_LIBRARIES})
        endif()
        if(FASTJET_LINK_DIRECTORIES)
            set(FASTJET_LIBRARY_DIRS ${FASTJET_LINK_DIRECTORIES})
        endif()
    endif()
    
    # Create imported target
    if(NOT TARGET FastJet::FastJet)
        add_library(FastJet::FastJet UNKNOWN IMPORTED)
        set_target_properties(FastJet::FastJet PROPERTIES
            IMPORTED_LOCATION "${FASTJET_LIBRARY}"
            INTERFACE_INCLUDE_DIRECTORIES "${FASTJET_INCLUDE_DIR}"
        )
        
        # Add the full linking flags if available
        if(FASTJET_LDFLAGS)
            set_target_properties(FastJet::FastJet PROPERTIES
                INTERFACE_LINK_LIBRARIES "${FASTJET_LDFLAGS}"
            )
        endif()
    endif()
endif()

mark_as_advanced(FASTJET_INCLUDE_DIR FASTJET_LIBRARY FASTJET_CONFIG)
