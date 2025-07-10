# CMakeLists.txt for IFNPlugin contrib

# Read VERSION file or set default
set(CONTRIB_VERSION "1.0.0")

# Define source files
set(CONTRIB_SOURCES 
    FlavNeutraliser.cc
    FlavInfo.cc
    IFNPlugin.cc
)

set(CONTRIB_HEADERS 
    include/fastjet/contrib/FlavInfo.hh
    include/fastjet/contrib/IFNPlugin.hh
    include/fastjet/contrib/FlavNeutraliser.hh
    include/fastjet/contrib/MassFlav.hh
)

# Create the library
add_library(IFNPlugin SHARED ${CONTRIB_SOURCES})

# Set library properties
set_target_properties(IFNPlugin PROPERTIES
    VERSION ${CONTRIB_VERSION}
    SOVERSION ${CONTRIB_VERSION}
)

# Include directories
target_include_directories(IFNPlugin PUBLIC 
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    $<INSTALL_INTERFACE:include>
)

# Link with FastJet
target_link_libraries(IFNPlugin ${FASTJET_LIBRARIES})

# Install library
install(TARGETS IFNPlugin
    EXPORT IFNPluginTargets
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
    DESTINATION share/doc/IFNPlugin
)

# Build examples if requested
if(BUILD_EXAMPLES)
    # Define examples
    set(EXAMPLES
        example-IFN
    )
    
    # Build each example
    foreach(EXAMPLE ${EXAMPLES})
        add_executable(ifnplugin_${EXAMPLE} ${EXAMPLE}.cc)
        target_link_libraries(ifnplugin_${EXAMPLE} IFNPlugin ${FASTJET_LIBRARIES})
        target_include_directories(ifnplugin_${EXAMPLE} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/include)
    endforeach()
    
    # Install examples
    foreach(EXAMPLE ${EXAMPLES})
        install(TARGETS ifnplugin_${EXAMPLE}
            DESTINATION bin
        )
    endforeach()
endif()

# Add tests if enabled
if(BUILD_TESTING)
    add_test(NAME ifnplugin_test
        COMMAND ${CMAKE_CURRENT_BINARY_DIR}/ifnplugin_example-IFN
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    )
endif()