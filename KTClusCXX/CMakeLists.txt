# CMakeLists.txt for KTClusCXX contrib

# Read VERSION file or set default
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/VERSION.txt")
    file(READ "${CMAKE_CURRENT_SOURCE_DIR}/VERSION.txt" CONTRIB_VERSION)
    string(STRIP "${CONTRIB_VERSION}" CONTRIB_VERSION)
else()
    set(CONTRIB_VERSION "1.0.0")
endif()

# No source files found
set(CONTRIB_SOURCES)

set(CONTRIB_HEADERS 
    KTClusCXX.hh
)

# Install additional files
install(FILES AUTHORS COPYING NEWS README VERSION.txt
    DESTINATION share/doc/KTClusCXX
)

# Build examples if requested
if(BUILD_EXAMPLES)
    # Define examples
    set(EXAMPLES
        example
        exampleall
    )
    
    # Build each example
    foreach(EXAMPLE ${EXAMPLES})
        add_executable(ktcluscxx_${EXAMPLE} ${EXAMPLE}.cc)
        target_link_libraries(ktcluscxx_${EXAMPLE} ${FASTJET_LIBRARIES})
    endforeach()
    
    # Install examples
    foreach(EXAMPLE ${EXAMPLES})
        install(TARGETS ktcluscxx_${EXAMPLE}
            DESTINATION bin
        )
    endforeach()
endif()

# Add tests if enabled
if(BUILD_TESTING)
    add_test(NAME ktcluscxx_test
        COMMAND ${CMAKE_CURRENT_BINARY_DIR}/ktcluscxx_example
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    )
endif()