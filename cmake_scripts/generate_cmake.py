#!/usr/bin/env python3
"""
Script to generate CMakeLists.txt files for fjcontrib modules.
"""

import os
import glob
import re
from pathlib import Path

def find_contrib_dirs():
    """Find all contrib directories."""
    contribs = []
    for item in os.listdir('.'):
        if os.path.isdir(item):
            # Skip non-contrib directories
            if item in ['data', 'scripts', 'utils', 'cmake', 'build', '.git']:
                continue
            # Check if it's a contrib (has VERSION or FJCONTRIB.cfg)
            if os.path.exists(os.path.join(item, 'VERSION')) or \
               os.path.exists(os.path.join(item, 'FJCONTRIB.cfg')):
                contribs.append(item)
    return sorted(contribs)

def get_contrib_info(contrib_dir):
    """Extract information about a contrib."""
    info = {
        'name': contrib_dir,
        'sources': [],
        'headers': [],
        'examples': [],
        'version': '1.0.0',
        'has_include_dir': False,
        'include_path': ''
    }
    
    # Check for VERSION.txt file
    version_file = os.path.join(contrib_dir, 'VERSION.txt')
    if os.path.exists(os.path.join(contrib_dir, 'VERSION.txt')):
        with open(os.path.join(contrib_dir, 'VERSION.txt'), 'r') as f:
            info['version'] = f.read().strip()
    
    # Check for include directory structure
    include_dir = os.path.join(contrib_dir, 'include', 'fastjet', 'contrib')
    if os.path.exists(include_dir):
        info['has_include_dir'] = True
        info['include_path'] = 'include/fastjet/contrib/'
        # Find headers in include directory
        for hh_file in glob.glob(os.path.join(include_dir, '*.hh')):
            header_name = os.path.basename(hh_file)
            info['headers'].append(f"include/fastjet/contrib/{header_name}")
    else:
        # Find headers in main directory
        for hh_file in glob.glob(os.path.join(contrib_dir, '*.hh')):
            header_name = os.path.basename(hh_file)
            info['headers'].append(header_name)
    
    # Find source files
    for cc_file in glob.glob(os.path.join(contrib_dir, '*.cc')):
        source_name = os.path.basename(cc_file)
        # Skip example files
        if not source_name.startswith('example'):
            info['sources'].append(source_name)
        else:
            # This is an example
            example_name = source_name.replace('.cc', '')
            info['examples'].append(example_name)
    
    return info

def generate_cmake_content(info):
    """Generate CMakeLists.txt content for a contrib."""
    name = info['name']
    
    cmake_content = f'''# CMakeLists.txt for {name} contrib

# Read VERSION file or set default
'''
    
    if os.path.exists(os.path.join(name, 'VERSION.txt')):
        cmake_content += '''if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/VERSION.txt")
    file(READ "${CMAKE_CURRENT_SOURCE_DIR}/VERSION.txt" CONTRIB_VERSION)
    string(STRIP "${CONTRIB_VERSION}" CONTRIB_VERSION)
else()
    set(CONTRIB_VERSION "1.0.0")
endif()
'''
    else:
        cmake_content += f'''set(CONTRIB_VERSION "{info['version']}")
'''
    
    # Sources
    if info['sources']:
        cmake_content += f'''
# Define source files
set(CONTRIB_SOURCES 
'''
        for source in info['sources']:
            cmake_content += f'    {source}\n'
        cmake_content += ')\n'
    else:
        cmake_content += '\n# No source files found\nset(CONTRIB_SOURCES)\n'
    
    # Headers
    if info['headers']:
        cmake_content += f'''
set(CONTRIB_HEADERS 
'''
        for header in info['headers']:
            cmake_content += f'    {header}\n'
        cmake_content += ')\n'
    
    # Library creation
    if info['sources']:
        cmake_content += f'''
# Create the library
add_library({name} SHARED ${{CONTRIB_SOURCES}})

# Set library properties
set_target_properties({name} PROPERTIES
    VERSION ${{CONTRIB_VERSION}}
    SOVERSION ${{CONTRIB_VERSION}}
'''
        if info['headers']:
            if not info['has_include_dir']:
                cmake_content += '    PUBLIC_HEADER "${CONTRIB_HEADERS}"\n'
        cmake_content += ')\n'
        
        # Include directories
        cmake_content += f'''
# Include directories
target_include_directories({name} PUBLIC 
'''
        if info['has_include_dir']:
            cmake_content += f'''    $<BUILD_INTERFACE:${{CMAKE_CURRENT_SOURCE_DIR}}/include>
    $<BUILD_INTERFACE:${{CMAKE_CURRENT_SOURCE_DIR}}>
'''
        else:
            cmake_content += f'''    $<BUILD_INTERFACE:${{CMAKE_CURRENT_SOURCE_DIR}}>
'''
        cmake_content += '''    $<INSTALL_INTERFACE:include>
)

# Link with FastJet
target_link_libraries({} ${{FASTJET_LIBRARIES}})

# Install library
install(TARGETS {}
    EXPORT {}Targets
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin'''.format(name, name, name)
        
        if info['headers'] and not info['has_include_dir']:
            cmake_content += '\n    PUBLIC_HEADER DESTINATION include/fastjet/contrib'
        cmake_content += '\n)\n'
        
        # Install headers for include directory case
        if info['has_include_dir']:
            cmake_content += f'''
# Install headers preserving directory structure
install(DIRECTORY include/fastjet/contrib/
    DESTINATION include/fastjet/contrib
    FILES_MATCHING PATTERN "*.hh"
)
'''
    
    # Install docs
    cmake_content += f'''
# Install additional files
install(FILES AUTHORS COPYING NEWS README'''
    if os.path.exists(os.path.join(name, 'VERSION')):
        cmake_content += ' VERSION'
    if os.path.exists(os.path.join(name, 'FJCONTRIB.cfg')):
        cmake_content += ' FJCONTRIB.cfg'
    cmake_content += f'''
    DESTINATION share/doc/{name}
)
'''
    
    # Examples
    if info['examples']:
        cmake_content += f'''
# Build examples if requested
if(BUILD_EXAMPLES)
    # Define examples
    set(EXAMPLES
'''
        for example in info['examples']:
            cmake_content += f'        {example}\n'
        cmake_content += '    )\n    \n'
        
        cmake_content += f'''    # Build each example
    foreach(EXAMPLE ${{EXAMPLES}})
        add_executable({name.lower()}_${{EXAMPLE}} ${{EXAMPLE}}.cc)'''
        
        if info['sources']:
            cmake_content += f'''
        target_link_libraries({name.lower()}_${{EXAMPLE}} {name} ${{FASTJET_LIBRARIES}})'''
        else:
            cmake_content += f'''
        target_link_libraries({name.lower()}_${{EXAMPLE}} ${{FASTJET_LIBRARIES}})'''
        
        if info['has_include_dir']:
            cmake_content += f'''
        target_include_directories({name.lower()}_${{EXAMPLE}} PRIVATE ${{CMAKE_CURRENT_SOURCE_DIR}}/include)'''
        
        cmake_content += '''
    endforeach()
    
    # Install examples
    foreach(EXAMPLE ${EXAMPLES})
        install(TARGETS ''' + name.lower() + '''_${EXAMPLE}
            DESTINATION bin
        )
    endforeach()
endif()
'''
    
    # Tests
    if info['examples']:
        first_example = info['examples'][0]
        cmake_content += f'''
# Add tests if enabled
if(BUILD_TESTING)
    add_test(NAME {name.lower()}_test
        COMMAND ${{CMAKE_CURRENT_BINARY_DIR}}/{name.lower()}_{first_example}
        WORKING_DIRECTORY ${{CMAKE_CURRENT_SOURCE_DIR}}
    )
endif()'''
    
    return cmake_content

def main():
    contribs = find_contrib_dirs()
    
    # Skip contribs that already have CMakeLists.txt
    existing_cmake = ['EnergyCorrelator', 'Nsubjettiness', 'RecursiveTools']
    
    print(f"Found {len(contribs)} contribs")
    print("Generating CMakeLists.txt for contribs:")
    
    for contrib in contribs:
        if contrib in existing_cmake:
            print(f"  {contrib} - skipped (already exists)")
            continue
            
        print(f"  {contrib}")
        info = get_contrib_info(contrib)
        content = generate_cmake_content(info)
        
        cmake_file = os.path.join(contrib, 'CMakeLists.txt')
        with open(cmake_file, 'w') as f:
            f.write(content)
    
    print("Done!")

if __name__ == "__main__":
    main()
