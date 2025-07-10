# CMakeLists.txt for EnergyCorrelator contrib

# Read VERSION file
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/VERSION.txt")
    file(READ "${CMAKE_CURRENT_SOURCE_DIR}/VERSION.txt" CONTRIB_VERSION)
    string(STRIP "${CONTRIB_VERSION}" CONTRIB_VERSION)
else()
    set(CONTRIB_VERSION "1.0.0")
endif()

# Define source files
set(CONTRIB_SOURCES EnergyCorrelator.cc)
set(CONTRIB_HEADERS EnergyCorrelator.hh)

# Create the library
add_library(EnergyCorrelator SHARED ${CONTRIB_SOURCES})

# Set library properties
set_target_properties(EnergyCorrelator PROPERTIES
    VERSION ${CONTRIB_VERSION}
    SOVERSION ${CONTRIB_VERSION}
    PUBLIC_HEADER "${CONTRIB_HEADERS}"
)

# Link with FastJet
target_link_libraries(EnergyCorrelator ${FASTJET_LIBRARIES})
target_include_directories(EnergyCorrelator PUBLIC 
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    $<INSTALL_INTERFACE:include>
)

# Install library and headers
install(TARGETS EnergyCorrelator
    EXPORT EnergyCorrelatorTargets
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
    PUBLIC_HEADER DESTINATION include/fastjet/contrib
)

# Install additional files
install(FILES AUTHORS COPYING NEWS README VERSION.txt
    DESTINATION share/doc/EnergyCorrelator
)

# Build examples if requested
if(BUILD_EXAMPLES)
    # example program
    add_executable(energycorrelator_example example.cc)
    target_link_libraries(energycorrelator_example EnergyCorrelator ${FASTJET_LIBRARIES})
    
    # example_basic_usage program
    add_executable(energycorrelator_example_basic_usage example_basic_usage.cc)
    target_link_libraries(energycorrelator_example_basic_usage EnergyCorrelator ${FASTJET_LIBRARIES})
    
    # Install examples
    install(TARGETS energycorrelator_example energycorrelator_example_basic_usage
        DESTINATION bin
    )
endif()

# Add tests if enabled
if(BUILD_TESTING)
    add_test(NAME energycorrelator_test
        COMMAND ${CMAKE_CURRENT_BINARY_DIR}/energycorrelator_example
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    )
endif()
