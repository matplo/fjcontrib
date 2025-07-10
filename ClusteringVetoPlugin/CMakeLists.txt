# CMakeLists.txt for ClusteringVetoPlugin contrib

# Read VERSION file or set default
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/VERSION.txt")
    file(READ "${CMAKE_CURRENT_SOURCE_DIR}/VERSION.txt" CONTRIB_VERSION)
    string(STRIP "${CONTRIB_VERSION}" CONTRIB_VERSION)
else()
    set(CONTRIB_VERSION "1.0.0")
endif()

# Define source files
set(CONTRIB_SOURCES 
    ClusteringVetoPlugin.cc
)

set(CONTRIB_HEADERS 
    ClusteringVetoPlugin.hh
)

# Create the library
add_library(ClusteringVetoPlugin SHARED ${CONTRIB_SOURCES})

# Set library properties
set_target_properties(ClusteringVetoPlugin PROPERTIES
    VERSION ${CONTRIB_VERSION}
    SOVERSION ${CONTRIB_VERSION}
    PUBLIC_HEADER "${CONTRIB_HEADERS}"
)

# Include directories
target_include_directories(ClusteringVetoPlugin PUBLIC 
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    $<INSTALL_INTERFACE:include>
)

# Link with FastJet
target_link_libraries(ClusteringVetoPlugin ${FASTJET_LIBRARIES})

# Install library
install(TARGETS ClusteringVetoPlugin
    EXPORT ClusteringVetoPluginTargets
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
    PUBLIC_HEADER DESTINATION include/fastjet/contrib
)

# Install additional files
install(FILES AUTHORS COPYING NEWS README VERSION.txt
    DESTINATION share/doc/ClusteringVetoPlugin
)

# Build examples if requested
if(BUILD_EXAMPLES)
    # Define examples
    set(EXAMPLES
        example
    )
    
    # Build each example
    foreach(EXAMPLE ${EXAMPLES})
        add_executable(clusteringvetoplugin_${EXAMPLE} ${EXAMPLE}.cc)
        target_link_libraries(clusteringvetoplugin_${EXAMPLE} ClusteringVetoPlugin ${FASTJET_LIBRARIES})
    endforeach()
    
    # Install examples
    foreach(EXAMPLE ${EXAMPLES})
        install(TARGETS clusteringvetoplugin_${EXAMPLE}
            DESTINATION bin
        )
    endforeach()
endif()

# Add tests if enabled
if(BUILD_TESTING)
    add_test(NAME clusteringvetoplugin_test
        COMMAND ${CMAKE_CURRENT_BINARY_DIR}/clusteringvetoplugin_example
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    )
endif()