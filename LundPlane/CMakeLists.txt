# CMakeLists.txt for LundPlane contrib

# Read VERSION file or set default
set(CONTRIB_VERSION "1.0.0")

# Define source files
set(CONTRIB_SOURCES 
    LundWithSecondary.cc
    SecondaryLund.cc
    RecursiveLundEEGenerator.cc
    LundGenerator.cc
)

set(CONTRIB_HEADERS 
    include/fastjet/contrib/RecursiveLundEEGenerator.hh
    include/fastjet/contrib/SecondaryLund.hh
    include/fastjet/contrib/LundWithSecondary.hh
    include/fastjet/contrib/LundEEHelpers.hh
    include/fastjet/contrib/LundJSON.hh
    include/fastjet/contrib/LundGenerator.hh
    include/fastjet/contrib/LundPlane.hh
)

# Create the library
add_library(LundPlane SHARED ${CONTRIB_SOURCES})

# Set library properties
set_target_properties(LundPlane PROPERTIES
    VERSION ${CONTRIB_VERSION}
    SOVERSION ${CONTRIB_VERSION}
)

# Include directories
target_include_directories(LundPlane PUBLIC 
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    $<INSTALL_INTERFACE:include>
)

# Link with FastJet
target_link_libraries(LundPlane ${FASTJET_LIBRARIES})

# Install library
install(TARGETS LundPlane
    EXPORT LundPlaneTargets
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
)

# Install headers preserving directory structure
install(DIRECTORY include/fastjet/contrib/
    DESTINATION include/fastjet/contrib
    FILES_MATCHING PATTERN "*.hh"
)

# Install additional files
install(FILES AUTHORS COPYING NEWS README FJCONTRIB.cfg
    DESTINATION share/doc/LundPlane
)

# Build examples if requested
if(BUILD_EXAMPLES)
    # Define examples
    set(EXAMPLES
        example
        example_secondary
        example_dpsi_collinear
        example_dpsi_slice
    )
    
    # Build each example
    foreach(EXAMPLE ${EXAMPLES})
        add_executable(lundplane_${EXAMPLE} ${EXAMPLE}.cc)
        target_link_libraries(lundplane_${EXAMPLE} LundPlane ${FASTJET_LIBRARIES})
        target_include_directories(lundplane_${EXAMPLE} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/include)
    endforeach()
    
    # Install examples
    foreach(EXAMPLE ${EXAMPLES})
        install(TARGETS lundplane_${EXAMPLE}
            DESTINATION bin
        )
    endforeach()
endif()

# Add tests if enabled
if(BUILD_TESTING)
    add_test(NAME lundplane_test
        COMMAND ${CMAKE_CURRENT_BINARY_DIR}/lundplane_example
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    )
endif()