# CMakeLists.txt for GHSAlgo contrib

# Read VERSION file or set default
set(CONTRIB_VERSION "1.0.0")

# Define source files
set(CONTRIB_SOURCES 
    GHSAlgo.cc
)

set(CONTRIB_HEADERS 
    include/fastjet/contrib/GHSAlgo.hh
)

# Create the library
add_library(GHSAlgo SHARED ${CONTRIB_SOURCES})

# Set library properties
set_target_properties(GHSAlgo PROPERTIES
    VERSION ${CONTRIB_VERSION}
    SOVERSION ${CONTRIB_VERSION}
)

# Include directories
target_include_directories(GHSAlgo PUBLIC 
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    $<INSTALL_INTERFACE:include>
)

# Link with FastJet
target_link_libraries(GHSAlgo ${FASTJET_LIBRARIES} IFNPlugin)

# Install library
install(TARGETS GHSAlgo
    EXPORT GHSAlgoTargets
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
    DESTINATION share/doc/GHSAlgo
)

# Build examples if requested
if(BUILD_EXAMPLES)
    # Define examples
    set(EXAMPLES
        example-GHS
    )
    
    # Build each example
    foreach(EXAMPLE ${EXAMPLES})
        add_executable(ghsalgo_${EXAMPLE} ${EXAMPLE}.cc)
        target_link_libraries(ghsalgo_${EXAMPLE} GHSAlgo ${FASTJET_LIBRARIES})
        target_include_directories(ghsalgo_${EXAMPLE} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/include)
    endforeach()
    
    # Install examples
    foreach(EXAMPLE ${EXAMPLES})
        install(TARGETS ghsalgo_${EXAMPLE}
            DESTINATION bin
        )
    endforeach()
endif()

# Add tests if enabled
if(BUILD_TESTING)
    add_test(NAME ghsalgo_test
        COMMAND ${CMAKE_CURRENT_BINARY_DIR}/ghsalgo_example-GHS
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    )
endif()