# CMakeLists.txt for ScJet contrib

# Read VERSION file or set default
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/VERSION.txt")
    file(READ "${CMAKE_CURRENT_SOURCE_DIR}/VERSION.txt" CONTRIB_VERSION)
    string(STRIP "${CONTRIB_VERSION}" CONTRIB_VERSION)
else()
    set(CONTRIB_VERSION "1.0.0")
endif()

# Define source files
set(CONTRIB_SOURCES 
    ScJet.cc
)

set(CONTRIB_HEADERS 
    ScJet.hh
)

# Create the library
add_library(ScJet SHARED ${CONTRIB_SOURCES})

# Set library properties
set_target_properties(ScJet PROPERTIES
    VERSION ${CONTRIB_VERSION}
    SOVERSION ${CONTRIB_VERSION}
    PUBLIC_HEADER "${CONTRIB_HEADERS}"
)

# Include directories
target_include_directories(ScJet PUBLIC 
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    $<INSTALL_INTERFACE:include>
)

# Link with FastJet
target_link_libraries(ScJet ${FASTJET_LIBRARIES})

# Install library
install(TARGETS ScJet
    EXPORT ScJetTargets
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
    PUBLIC_HEADER DESTINATION include/fastjet/contrib
)

# Install additional files
install(FILES AUTHORS COPYING NEWS README VERSION.txt
    DESTINATION share/doc/ScJet
)

# Build examples if requested
if(BUILD_EXAMPLES)
    # Define examples
    set(EXAMPLES
        example
    )
    
    # Build each example
    foreach(EXAMPLE ${EXAMPLES})
        add_executable(scjet_${EXAMPLE} ${EXAMPLE}.cc)
        target_link_libraries(scjet_${EXAMPLE} ScJet ${FASTJET_LIBRARIES})
    endforeach()
    
    # Install examples
    foreach(EXAMPLE ${EXAMPLES})
        install(TARGETS scjet_${EXAMPLE}
            DESTINATION bin
        )
    endforeach()
endif()

# Add tests if enabled
if(BUILD_TESTING)
    add_test(NAME scjet_test
        COMMAND ${CMAKE_CURRENT_BINARY_DIR}/scjet_example
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    )
endif()