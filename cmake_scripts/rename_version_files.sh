#!/bin/bash
# Script to rename all VERSION files to VERSION.txt to avoid C++ header conflicts

echo "Renaming VERSION files to VERSION.txt..."

# Find all VERSION files and rename them
find . -name "VERSION" -type f | while read -r version_file; do
    dir=$(dirname "$version_file")
    echo "Renaming: $version_file -> $dir/VERSION.txt"
    mv "$version_file" "$dir/VERSION.txt"
done

echo "Done! Now updating CMakeLists.txt files..."

# Update all CMakeLists.txt files to use VERSION.txt
find . -name "CMakeLists.txt" -type f | while read -r cmake_file; do
    if grep -q "VERSION" "$cmake_file"; then
        echo "Updating: $cmake_file"
        # Update file reading
        sed -i '' 's|"\${CMAKE_CURRENT_SOURCE_DIR}/VERSION"|"\${CMAKE_CURRENT_SOURCE_DIR}/VERSION.txt"|g' "$cmake_file"
        # Update install commands  
        sed -i '' 's|install(FILES.*VERSION|install(FILES AUTHORS COPYING NEWS README VERSION.txt|g' "$cmake_file"
        # Handle cases where VERSION is listed separately
        sed -i '' 's|FILES.*VERSION\b|FILES AUTHORS COPYING NEWS README VERSION.txt|g' "$cmake_file"
    fi
done

echo "All VERSION files renamed and CMakeLists.txt files updated!"
