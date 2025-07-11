# CMakeLists.txt for CMPPlugin contrib

# Read VERSION file or set default
set(CONTRIB_VERSION "1.0.0")

# Define source files
set(CONTRIB_SOURCES 
    CMPPlugin.cc
)

set(CONTRIB_HEADERS 
    include/fastjet/contrib/CMPPlugin.hh
)

# Create the library
add_library(CMPPlugin SHARED ${CONTRIB_SOURCES})

# Set library properties
set_target_properties(CMPPlugin PROPERTIES
    VERSION ${CONTRIB_VERSION}
    SOVERSION ${CONTRIB_VERSION}
)

# Include directories
# Include directories
target_include_directories(CMPPlugin 
    PUBLIC 
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
        $<INSTALL_INTERFACE:include>
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/include
)

# Link with FastJet
target_link_libraries(CMPPlugin ${FASTJET_LIBRARIES} IFNPlugin)

# Install library
install(TARGETS CMPPlugin
    EXPORT CMPPluginTargets
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
    DESTINATION share/doc/CMPPlugin
)

# Build examples if requested
if(BUILD_EXAMPLES)
    # Define examples
    set(EXAMPLES
        example-CMP
    )
    
    # Build each example
    foreach(EXAMPLE ${EXAMPLES})
        add_executable(cmpplugin_${EXAMPLE} ${EXAMPLE}.cc)
        target_link_libraries(cmpplugin_${EXAMPLE} CMPPlugin ${FASTJET_LIBRARIES} IFNPlugin)
        target_include_directories(cmpplugin_${EXAMPLE} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/include)
    endforeach()
    
    # Install examples
    foreach(EXAMPLE ${EXAMPLES})
        install(TARGETS cmpplugin_${EXAMPLE}
            DESTINATION bin
        )
    endforeach()
endif()

# Add tests if enabled
if(BUILD_TESTING)
    add_test(NAME cmpplugin_test
        COMMAND ${CMAKE_CURRENT_BINARY_DIR}/cmpplugin_example-CMP
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    )
endif()