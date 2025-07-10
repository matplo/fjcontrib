#!/bin/bash
# Demo script showing the CMake setup for fjcontrib

echo "FastJet Contrib CMake Setup"
echo "==========================="
echo ""

echo "1. Project Structure:"
echo "   - Main CMakeLists.txt: Top-level build configuration"
echo "   - cmake/FindFastJet.cmake: FastJet detection module"
echo "   - build.sh: Convenient build script"
echo "   - generate_cmake.py: Auto-generator for contrib CMakeLists.txt"
echo ""

echo "2. Generated Files:"
echo "   ✓ CMakeLists.txt (main)"
echo "   ✓ cmake/FindFastJet.cmake"
echo "   ✓ build.sh"
echo "   ✓ generate_cmake.py"
echo "   ✓ CMAKE_README.md"
echo "   ✓ INSTALL_FASTJET.md"
echo ""

echo "3. Contrib CMakeLists.txt files generated:"
contrib_count=0
for dir in */; do
    if [[ -f "$dir/CMakeLists.txt" && "$dir" != "build/" ]]; then
        echo "   ✓ $dir"
        ((contrib_count++))
    fi
done
echo "   Total: $contrib_count contribs"
echo ""

echo "4. Available Build Commands:"
echo ""
echo "   Standard build:"
echo "   $ ./build.sh"
echo ""
echo "   Debug build:"
echo "   $ ./build.sh --build-type Debug"
echo ""
echo "   Without examples:"
echo "   $ ./build.sh --no-examples"
echo ""
echo "   With testing:"
echo "   $ ./build.sh --enable-testing"
echo ""
echo "   Manual CMake:"
echo "   $ mkdir build && cd build && cmake .. && make"
echo ""

echo "5. Prerequisites Check:"
if command -v cmake >/dev/null 2>&1; then
    cmake_version=$(cmake --version | head -n1 | cut -d' ' -f3)
    echo "   ✓ CMake: $cmake_version"
else
    echo "   ✗ CMake: Not found"
fi

if command -v fastjet-config >/dev/null 2>&1; then
    fastjet_version=$(fastjet-config --version)
    echo "   ✓ FastJet: $fastjet_version"
    echo "     Installation: $(which fastjet-config)"
else
    echo "   ✗ FastJet: Not found"
    echo "     See INSTALL_FASTJET.md for installation instructions"
fi

if command -v pkg-config >/dev/null 2>&1; then
    echo "   ✓ pkg-config: $(pkg-config --version)"
else
    echo "   ✗ pkg-config: Not found"
fi
echo ""

echo "6. Next Steps:"
if command -v fastjet-config >/dev/null 2>&1; then
    echo "   FastJet is available! You can now build:"
    echo "   $ ./build.sh"
else
    echo "   1. Install FastJet (see INSTALL_FASTJET.md)"
    echo "   2. Run: ./build.sh"
fi
echo "   3. Install: cd build && make install"
echo "   4. Use in your projects with CMake find_package() or pkg-config"
echo ""

echo "7. Documentation:"
echo "   - CMAKE_README.md: Detailed build instructions"
echo "   - INSTALL_FASTJET.md: FastJet installation guide"
echo "   - Original README: Traditional autotools build instructions"
echo ""

echo "CMake setup complete! 🎉"
