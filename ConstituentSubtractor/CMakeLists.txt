# CMakeLists.txt for ConstituentSubtractor contrib

# Read VERSION file or set default
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/VERSION.txt")
    file(READ "${CMAKE_CURRENT_SOURCE_DIR}/VERSION.txt" CONTRIB_VERSION)
    string(STRIP "${CONTRIB_VERSION}" CONTRIB_VERSION)
else()
    set(CONTRIB_VERSION "1.0.0")
endif()

# Define source files
set(CONTRIB_SOURCES 
    RescalingClasses.cc
    IterativeConstituentSubtractor.cc
    ConstituentSubtractor.cc
)

set(CONTRIB_HEADERS 
    RescalingClasses.hh
    example_jet_by_jet.hh
    IterativeConstituentSubtractor.hh
    functions.hh
    ConstituentSubtractor.hh
)

# Create the library
add_library(ConstituentSubtractor SHARED ${CONTRIB_SOURCES})

# Set library properties
set_target_properties(ConstituentSubtractor PROPERTIES
    VERSION ${CONTRIB_VERSION}
    SOVERSION ${CONTRIB_VERSION}
    PUBLIC_HEADER "${CONTRIB_HEADERS}"
)

# Include directories
target_include_directories(ConstituentSubtractor PUBLIC 
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    $<INSTALL_INTERFACE:include>
)

# Link with FastJet
target_link_libraries(ConstituentSubtractor ${FASTJET_LIBRARIES})

# Install library
install(TARGETS ConstituentSubtractor
    EXPORT ConstituentSubtractorTargets
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
    PUBLIC_HEADER DESTINATION include/fastjet/contrib
)

# Install additional files
install(FILES AUTHORS COPYING NEWS README VERSION.txt
    DESTINATION share/doc/ConstituentSubtractor
)

# Build examples if requested
if(BUILD_EXAMPLES)
    # Define examples
    set(EXAMPLES
        example_whole_event_using_charged_info
        example_background_rescaling
        example_jet_by_jet
        example_iterative
        example_event_wide
    )
    
    # Build each example
    foreach(EXAMPLE ${EXAMPLES})
        add_executable(constituentsubtractor_${EXAMPLE} ${EXAMPLE}.cc)
        target_link_libraries(constituentsubtractor_${EXAMPLE} ConstituentSubtractor ${FASTJET_LIBRARIES})
    endforeach()
    
    # Install examples
    foreach(EXAMPLE ${EXAMPLES})
        install(TARGETS constituentsubtractor_${EXAMPLE}
            DESTINATION bin
        )
    endforeach()
endif()

# Add tests if enabled
if(BUILD_TESTING)
    add_test(NAME constituentsubtractor_test
        COMMAND ${CMAKE_CURRENT_BINARY_DIR}/constituentsubtractor_example_whole_event_using_charged_info
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    )
endif()