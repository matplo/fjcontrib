# CMakeLists.txt for fragile lib of fj contrib

# Read VERSION file
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/VERSION.txt")
    file(READ "${CMAKE_CURRENT_SOURCE_DIR}/VERSION.txt" CONTRIB_VERSION)
    string(STRIP "${CONTRIB_VERSION}" CONTRIB_VERSION)
else()
    set(CONTRIB_VERSION "2.3.2")
endif()

# Read contribs.txt to get list of directories to include
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/contribs.txt")
    file(READ "${CMAKE_CURRENT_SOURCE_DIR}/contribs.txt" CONTRIB_DIRS_RAW)
    string(STRIP "${CONTRIB_DIRS_RAW}" CONTRIB_DIRS_RAW)
    string(REPLACE "\n" ";" CONTRIB_DIRS_LIST "${CONTRIB_DIRS_RAW}")
    
    # Debug: Print directories from contribs.txt
    message(STATUS "Directories from contribs.txt: ${CONTRIB_DIRS_LIST}")
    
    # Collect source and header files from specified directories
    set(CONTRIB_SOURCES "")
    set(CONTRIB_HEADERS "")
    
    foreach(contrib_dir ${CONTRIB_DIRS_LIST})
        string(STRIP "${contrib_dir}" contrib_dir)
        if(NOT "${contrib_dir}" STREQUAL "")
            set(full_contrib_path "${CMAKE_CURRENT_SOURCE_DIR}/../${contrib_dir}")
            
            # Find .cc files in this directory
            file(GLOB dir_sources "${full_contrib_path}/*.cc")
            list(FILTER dir_sources EXCLUDE REGEX ".*example.*\.cc$")
            list(APPEND CONTRIB_SOURCES ${dir_sources})
            
            # Find .hh files in this directory
            file(GLOB dir_headers "${full_contrib_path}/*.hh")
            list(APPEND CONTRIB_HEADERS ${dir_headers})
            
            message(STATUS "From ${contrib_dir}: found ${dir_sources}")
        endif()
    endforeach()
else()
    message(FATAL_ERROR "contribs.txt file not found!")
endif()

# Debug: Print found sources after filtering
message(STATUS "Found CONTRIB_SOURCES after filtering: ${CONTRIB_SOURCES}")
message(STATUS "Found CONTRIB_HEADERS: ${CONTRIB_HEADERS}")

# Check if we have any sources
list(LENGTH CONTRIB_SOURCES SOURCES_COUNT)
if(SOURCES_COUNT EQUAL 0)
    message(FATAL_ERROR "No source files found! Check your directory structure.")
endif()

# Create the library
add_library(fastjetcontribfragile SHARED ${CONTRIB_SOURCES})

# Debug: Print found sources
message(STATUS "Found CONTRIB_SOURCES: ${CONTRIB_SOURCES}")
message(STATUS "Found CONTRIB_HEADERS: ${CONTRIB_HEADERS}")

# Set library properties
set_target_properties(fastjetcontribfragile PROPERTIES
    VERSION ${CONTRIB_VERSION}
    SOVERSION ${CONTRIB_VERSION}
    # PUBLIC_HEADER "${CONTRIB_HEADERS}"
)

# Link with FastJet
target_link_libraries(fastjetcontribfragile ${FASTJET_LIBRARIES})
target_include_directories(fastjetcontribfragile PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    $<INSTALL_INTERFACE:include>
)
# make sure all the subdirs in the upper directory are included
target_include_directories(fastjetcontribfragile SYSTEM BEFORE PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/../>
    $<INSTALL_INTERFACE:include/fastjet/contrib>
)

# Important: Ensure current source directory is NOT in system include paths
# to avoid conflicts with standard C++ headers like <version>
target_include_directories(fastjetcontribfragile SYSTEM BEFORE PRIVATE ${FASTJET_INCLUDE_DIRS})

# Install library and headers
install(TARGETS fastjetcontribfragile
    EXPORT fastjetcontribfragileTargets
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
#     PUBLIC_HEADER DESTINATION include/fastjet/contrib
)

# Install additional files
install(FILES AUTHORS COPYING NEWS README VERSION.txt
    DESTINATION share/doc/fastjetcontribfragile
)
