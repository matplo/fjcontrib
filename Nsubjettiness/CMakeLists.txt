# CMakeLists.txt for Nsubjettiness contrib

# Read VERSION file
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/VERSION.txt")
    file(READ "${CMAKE_CURRENT_SOURCE_DIR}/VERSION.txt" CONTRIB_VERSION)
    string(STRIP "${CONTRIB_VERSION}" CONTRIB_VERSION)
else()
    set(CONTRIB_VERSION "2.3.2")
endif()

# Define source files
set(CONTRIB_SOURCES 
    AxesDefinition.cc
    ExtraRecombiners.cc
    MeasureDefinition.cc
    Njettiness.cc
    NjettinessPlugin.cc
    Nsubjettiness.cc
    TauComponents.cc
    XConePlugin.cc
)

set(CONTRIB_HEADERS 
    AxesDefinition.hh
    ExtraRecombiners.hh
    MeasureDefinition.hh
    Njettiness.hh
    NjettinessPlugin.hh
    Nsubjettiness.hh
    TauComponents.hh
    XConePlugin.hh
)

# Create the library
add_library(Nsubjettiness SHARED ${CONTRIB_SOURCES})

# Set library properties
set_target_properties(Nsubjettiness PROPERTIES
    VERSION ${CONTRIB_VERSION}
    SOVERSION ${CONTRIB_VERSION}
    PUBLIC_HEADER "${CONTRIB_HEADERS}"
)

# Link with FastJet
target_link_libraries(Nsubjettiness ${FASTJET_LIBRARIES})
target_include_directories(Nsubjettiness PUBLIC 
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    $<INSTALL_INTERFACE:include>
)

# Important: Ensure current source directory is NOT in system include paths
# to avoid conflicts with standard C++ headers like <version>
target_include_directories(Nsubjettiness SYSTEM BEFORE PRIVATE ${FASTJET_INCLUDE_DIRS})

# Install library and headers
install(TARGETS Nsubjettiness
    EXPORT NsubjettinessTargets
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
    PUBLIC_HEADER DESTINATION include/fastjet/contrib
)

# Install additional files
install(FILES AUTHORS COPYING NEWS README VERSION.txt
    DESTINATION share/doc/Nsubjettiness
)

# Build examples if requested
if(BUILD_EXAMPLES)
    # Define examples
    set(EXAMPLES
        example_advanced_usage
        example_advanced_usage_ee
        example_basic_usage
        example_v1p0p3
    )
    
    # Build each example
    foreach(EXAMPLE ${EXAMPLES})
        add_executable(nsubjettiness_${EXAMPLE} ${EXAMPLE}.cc)
        target_link_libraries(nsubjettiness_${EXAMPLE} Nsubjettiness ${FASTJET_LIBRARIES})
    endforeach()
    
    # Install examples
    foreach(EXAMPLE ${EXAMPLES})
        install(TARGETS nsubjettiness_${EXAMPLE}
            DESTINATION bin
        )
    endforeach()
endif()

# Add tests if enabled
if(BUILD_TESTING)
    add_test(NAME nsubjettiness_test
        COMMAND ${CMAKE_CURRENT_BINARY_DIR}/nsubjettiness_example_basic_usage
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    )
endif()
