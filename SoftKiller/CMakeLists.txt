# CMakeLists.txt for SoftKiller contrib

# Read VERSION file or set default
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/VERSION.txt")
    file(READ "${CMAKE_CURRENT_SOURCE_DIR}/VERSION.txt" CONTRIB_VERSION)
    string(STRIP "${CONTRIB_VERSION}" CONTRIB_VERSION)
else()
    set(CONTRIB_VERSION "1.0.0")
endif()

# Define source files
set(CONTRIB_SOURCES 
    SoftKiller.cc
)

set(CONTRIB_HEADERS 
    SoftKiller.hh
)

# Create the library
add_library(SoftKiller SHARED ${CONTRIB_SOURCES})

# Set library properties
set_target_properties(SoftKiller PROPERTIES
    VERSION ${CONTRIB_VERSION}
    SOVERSION ${CONTRIB_VERSION}
    PUBLIC_HEADER "${CONTRIB_HEADERS}"
)

# Include directories
target_include_directories(SoftKiller PUBLIC 
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    $<INSTALL_INTERFACE:include>
)

# Link with FastJet
target_link_libraries(SoftKiller ${FASTJET_LIBRARIES})

# Install library
install(TARGETS SoftKiller
    EXPORT SoftKillerTargets
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
    PUBLIC_HEADER DESTINATION include/fastjet/contrib
)

# Install additional files
install(FILES AUTHORS COPYING NEWS README VERSION.txt
    DESTINATION share/doc/SoftKiller
)

# Build examples if requested
if(BUILD_EXAMPLES)
    # Define examples
    set(EXAMPLES
        example
    )
    
    # Build each example
    foreach(EXAMPLE ${EXAMPLES})
        add_executable(softkiller_${EXAMPLE} ${EXAMPLE}.cc)
        target_link_libraries(softkiller_${EXAMPLE} SoftKiller ${FASTJET_LIBRARIES})
    endforeach()
    
    # Install examples
    foreach(EXAMPLE ${EXAMPLES})
        install(TARGETS softkiller_${EXAMPLE}
            DESTINATION bin
        )
    endforeach()
endif()

# Add tests if enabled
if(BUILD_TESTING)
    add_test(NAME softkiller_test
        COMMAND ${CMAKE_CURRENT_BINARY_DIR}/softkiller_example
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    )
endif()