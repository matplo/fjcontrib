cmake_minimum_required(VERSION 3.12)
project(fjcontrib VERSION 1.101 LANGUAGES CXX)

# Set C++ standard
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)  # Force strict C++11, no compiler extensions

# Add custom module path for finding FastJet
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake")

# Find FastJet
# First try pkg-config, then fallback to our custom finder
find_package(PkgConfig QUIET)

# Check if FASTJET_DIR is set and add to PKG_CONFIG_PATH
if(DEFINED ENV{FASTJET_DIR} AND PKG_CONFIG_FOUND)
    set(ENV{PKG_CONFIG_PATH} "$ENV{FASTJET_DIR}/lib/pkgconfig:$ENV{PKG_CONFIG_PATH}")
endif()

# Try pkg-config first (not required, so it won't fail)
if(PKG_CONFIG_FOUND)
    pkg_check_modules(FASTJET fastjet)
endif()

# If pkg-config didn't find FastJet, use our custom finder
if(NOT FASTJET_FOUND)
    message(STATUS "pkg-config didn't find FastJet, trying custom finder...")
    find_package(FastJet REQUIRED)
    if(FastJet_FOUND)
        set(FASTJET_FOUND TRUE)
        # Note: FASTJET_LIBRARIES and FASTJET_INCLUDE_DIRS are already set by FindFastJet.cmake
    endif()
endif()

# Verify we found FastJet
if(NOT FASTJET_FOUND)
    message(FATAL_ERROR "FastJet not found! Please install FastJet or set FASTJET_DIR environment variable.")
endif()

# Set global compile options
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O3 -Wall -Wextra -g")

# Add FastJet compiler flags if available
if(FASTJET_CXXFLAGS)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${FASTJET_CXXFLAGS}")
endif()

# Include directories
include_directories(${FASTJET_INCLUDE_DIRS})

# Link directories
if(FASTJET_LIBRARY_DIRS)
    link_directories(${FASTJET_LIBRARY_DIRS})
endif()

# Add compile definitions
add_definitions(${FASTJET_CFLAGS_OTHER})

# Function to add a contrib
function(add_contrib CONTRIB_NAME)
    # Check if the contrib directory exists and has required files
    if(EXISTS "${CMAKE_SOURCE_DIR}/${CONTRIB_NAME}" AND 
       (EXISTS "${CMAKE_SOURCE_DIR}/${CONTRIB_NAME}/VERSION.txt" OR 
        EXISTS "${CMAKE_SOURCE_DIR}/${CONTRIB_NAME}/FJCONTRIB.cfg"))
        
        message(STATUS "Adding contrib: ${CONTRIB_NAME}")
        add_subdirectory(${CONTRIB_NAME})
    endif()
endfunction()

# List all available contribs
file(GLOB CONTRIB_DIRS RELATIVE ${CMAKE_SOURCE_DIR} *)
foreach(DIR ${CONTRIB_DIRS})
    if(IS_DIRECTORY ${CMAKE_SOURCE_DIR}/${DIR})
        # Skip non-contrib directories
        if(NOT ${DIR} STREQUAL "data" AND 
           NOT ${DIR} STREQUAL "scripts" AND 
           NOT ${DIR} STREQUAL "utils" AND
           NOT ${DIR} STREQUAL "cmake" AND
           NOT ${DIR} STREQUAL "build")
            add_contrib(${DIR})
        endif()
    endif()
endforeach()

# Create install targets
install(FILES AUTHORS COPYING NEWS README VERSION.txt 
        DESTINATION share/doc/fjcontrib)

# Add option to build examples
option(BUILD_EXAMPLES "Build example programs" ON)

# Add option to enable testing
option(BUILD_TESTING "Build tests" OFF)
if(BUILD_TESTING)
    enable_testing()
endif()

# Summary
message(STATUS "")
message(STATUS "FastJet Contrib ${PROJECT_VERSION} Configuration Summary")
message(STATUS "=====================================")
message(STATUS "FastJet include dirs: ${FASTJET_INCLUDE_DIRS}")
message(STATUS "FastJet libraries: ${FASTJET_LIBRARIES}")
message(STATUS "Build examples: ${BUILD_EXAMPLES}")
message(STATUS "Build testing: ${BUILD_TESTING}")
message(STATUS "")
