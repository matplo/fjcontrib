# CMakeLists.txt for SDFPlugin contrib

# Read VERSION file or set default
set(CONTRIB_VERSION "1.0.0")

# Define source files
set(CONTRIB_SOURCES 
    SDFPlugin.cc
)

set(CONTRIB_HEADERS 
    include/fastjet/contrib/SDFPlugin.hh
)

# Create the library
add_library(SDFPlugin SHARED ${CONTRIB_SOURCES})

# Set library properties
set_target_properties(SDFPlugin PROPERTIES
    VERSION ${CONTRIB_VERSION}
    SOVERSION ${CONTRIB_VERSION}
)

message(STATUS "Building SDFPlugin version ${CONTRIB_VERSION}")
# Include directories
target_include_directories(SDFPlugin PUBLIC 
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/RecursiveTools/include>
    $<INSTALL_INTERFACE:include>
)

# Link with FastJet
target_link_libraries(SDFPlugin ${FASTJET_LIBRARIES} IFNPlugin)

# Install library
install(TARGETS SDFPlugin
    EXPORT SDFPluginTargets
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
    DESTINATION share/doc/SDFPlugin
)

# Build examples if requested
if(BUILD_EXAMPLES)
    # Define examples
    set(EXAMPLES
        example-SDF
    )
    
    # Build each example
    foreach(EXAMPLE ${EXAMPLES})
        add_executable(sdfplugin_${EXAMPLE} ${EXAMPLE}.cc)
        target_link_libraries(sdfplugin_${EXAMPLE} SDFPlugin ${FASTJET_LIBRARIES} IFNPlugin RecursiveTools)
        target_include_directories(sdfplugin_${EXAMPLE} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/include)
    endforeach()
    
    # Install examples
    foreach(EXAMPLE ${EXAMPLES})
        install(TARGETS sdfplugin_${EXAMPLE}
            DESTINATION bin
        )
    endforeach()
endif()

# Add tests if enabled
if(BUILD_TESTING)
    add_test(NAME sdfplugin_test
        COMMAND ${CMAKE_CURRENT_BINARY_DIR}/sdfplugin_example-SDF
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    )
endif()