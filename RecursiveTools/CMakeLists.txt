# CMakeLists.txt for RecursiveTools contrib

# Read VERSION from FJCONTRIB.cfg or create a default
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/VERSION.txt")
    file(READ "${CMAKE_CURRENT_SOURCE_DIR}/VERSION.txt" CONTRIB_VERSION)
    string(STRIP "${CONTRIB_VERSION}" CONTRIB_VERSION)
else()
    set(CONTRIB_VERSION "1.0.0")
endif()

# Define source files
set(CONTRIB_SOURCES 
    BottomUpSoftDrop.cc
    IteratedSoftDrop.cc
    ModifiedMassDropTagger.cc
    Recluster.cc
    RecursiveSoftDrop.cc
    RecursiveSymmetryCutBase.cc
    SoftDrop.cc
)

# Define header files (they're in include/fastjet/contrib/)
set(CONTRIB_HEADERS 
    include/fastjet/contrib/BottomUpSoftDrop.hh
    include/fastjet/contrib/IteratedSoftDrop.hh
    include/fastjet/contrib/ModifiedMassDropTagger.hh
    include/fastjet/contrib/Recluster.hh
    include/fastjet/contrib/RecursiveSoftDrop.hh
    include/fastjet/contrib/RecursiveSymmetryCutBase.hh
    include/fastjet/contrib/SoftDrop.hh
)

# Create the library
add_library(RecursiveTools SHARED ${CONTRIB_SOURCES})

# Set library properties
set_target_properties(RecursiveTools PROPERTIES
    VERSION ${CONTRIB_VERSION}
    SOVERSION ${CONTRIB_VERSION}
)

# Include directories
target_include_directories(RecursiveTools PUBLIC 
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    $<INSTALL_INTERFACE:include>
)

# Link with FastJet
target_link_libraries(RecursiveTools ${FASTJET_LIBRARIES})

# Install library
install(TARGETS RecursiveTools
    EXPORT RecursiveToolsTargets
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
    DESTINATION share/doc/RecursiveTools
)

# Build examples if requested
if(BUILD_EXAMPLES)
    # Define examples
    set(EXAMPLES
        example_advanced_usage
        example_bottomup_softdrop
        example_isd
        example_mmdt
        example_mmdt_ee
        example_mmdt_sub
        example_recluster
        example_recursive_softdrop
        example_softdrop
    )
    
    # Build each example
    foreach(EXAMPLE ${EXAMPLES})
        add_executable(recursivetools_${EXAMPLE} ${EXAMPLE}.cc)
        target_link_libraries(recursivetools_${EXAMPLE} RecursiveTools ${FASTJET_LIBRARIES})
        target_include_directories(recursivetools_${EXAMPLE} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/include)
    endforeach()
    
    # Install examples
    foreach(EXAMPLE ${EXAMPLES})
        install(TARGETS recursivetools_${EXAMPLE}
            DESTINATION bin
        )
    endforeach()
endif()

# Add tests if enabled
if(BUILD_TESTING)
    add_test(NAME recursivetools_test
        COMMAND ${CMAKE_CURRENT_BINARY_DIR}/recursivetools_example_softdrop
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    )
endif()
