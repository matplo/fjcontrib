# CMakeLists.txt for Nsubjettiness contrib

# Read VERSION file
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/VERSION.txt")
    file(READ "${CMAKE_CURRENT_SOURCE_DIR}/VERSION.txt" CONTRIB_VERSION)
    string(STRIP "${CONTRIB_VERSION}" CONTRIB_VERSION)
else()
    set(CONTRIB_VERSION "2.3.2")
endif()

# Define source files
# find all *.cc files in the upper directory but not in the current directory
file(GLOB_RECURSE FASTJET_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/../*.cc")
# filter out the current directory's files
list(FILTER FASTJET_SOURCES EXCLUDE REGEX "${CMAKE_CURRENT_SOURCE_DIR}/.*.cc")
list(FILTER FASTJET_SOURCES EXCLUDE REGEX "${CMAKE_CURRENT_SOURCE_DIR}/../example*.cc")
# find all *.hh files in the upper directory but not in the current directory
file(GLOB_RECURSE FASTJET_HEADERS "${CMAKE_CURRENT_SOURCE_DIR}/../*.hh")
# filter out the current directory's files
list(FILTER FASTJET_HEADERS EXCLUDE REGEX "${CMAKE_CURRENT_SOURCE_DIR}/.*.hh")

# Create the library
add_library(fastjetcontribfragile SHARED ${CONTRIB_SOURCES})

# Set library properties
set_target_properties(fastjetcontribfragile PROPERTIES
    VERSION ${CONTRIB_VERSION}
    SOVERSION ${CONTRIB_VERSION}
    PUBLIC_HEADER "${CONTRIB_HEADERS}"
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
    PUBLIC_HEADER DESTINATION include/fastjet/contrib
)

# Install additional files
install(FILES AUTHORS COPYING NEWS README VERSION.txt
    DESTINATION share/doc/fastjetcontribfragile
)
