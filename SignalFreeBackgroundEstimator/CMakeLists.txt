# CMakeLists.txt for SignalFreeBackgroundEstimator contrib

# Read VERSION file or set default
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/VERSION.txt")
    file(READ "${CMAKE_CURRENT_SOURCE_DIR}/VERSION.txt" CONTRIB_VERSION)
    string(STRIP "${CONTRIB_VERSION}" CONTRIB_VERSION)
else()
    set(CONTRIB_VERSION "1.0.0")
endif()

# Define source files
set(CONTRIB_SOURCES 
    SignalFreeBackgroundEstimator.cc
)

set(CONTRIB_HEADERS 
    SignalFreeBackgroundEstimator.hh
    functions.hh
)

# Create the library
add_library(SignalFreeBackgroundEstimator SHARED ${CONTRIB_SOURCES})

# Set library properties
set_target_properties(SignalFreeBackgroundEstimator PROPERTIES
    VERSION ${CONTRIB_VERSION}
    SOVERSION ${CONTRIB_VERSION}
    PUBLIC_HEADER "${CONTRIB_HEADERS}"
)

# Include directories
target_include_directories(SignalFreeBackgroundEstimator PUBLIC 
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    $<INSTALL_INTERFACE:include>
)

# Link with FastJet
target_link_libraries(SignalFreeBackgroundEstimator ${FASTJET_LIBRARIES})

# Install library
install(TARGETS SignalFreeBackgroundEstimator
    EXPORT SignalFreeBackgroundEstimatorTargets
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
    PUBLIC_HEADER DESTINATION include/fastjet/contrib
)

# Install additional files
install(FILES AUTHORS COPYING NEWS README VERSION.txt
    DESTINATION share/doc/SignalFreeBackgroundEstimator
)

# Build examples if requested
if(BUILD_EXAMPLES)
    # Define examples
    set(EXAMPLES
        example
    )
    
    # Build each example
    foreach(EXAMPLE ${EXAMPLES})
        add_executable(signalfreebackgroundestimator_${EXAMPLE} ${EXAMPLE}.cc)
        target_link_libraries(signalfreebackgroundestimator_${EXAMPLE} SignalFreeBackgroundEstimator ${FASTJET_LIBRARIES})
    endforeach()
    
    # Install examples
    foreach(EXAMPLE ${EXAMPLES})
        install(TARGETS signalfreebackgroundestimator_${EXAMPLE}
            DESTINATION bin
        )
    endforeach()
endif()

# Add tests if enabled
if(BUILD_TESTING)
    add_test(NAME signalfreebackgroundestimator_test
        COMMAND ${CMAKE_CURRENT_BINARY_DIR}/signalfreebackgroundestimator_example
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    )
endif()