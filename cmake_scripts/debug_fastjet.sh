#!/bin/bash
# Debug script for FastJet detection

echo "FastJet Detection Debug"
echo "======================"
echo

# Check environment
echo "1. Environment Variables:"
echo "   FASTJET_DIR: ${FASTJET_DIR:-<not set>}"
echo "   PKG_CONFIG_PATH: ${PKG_CONFIG_PATH:-<not set>}"
echo

# Check if fastjet-config exists
echo "2. FastJet Config Script:"
if [[ -n "$FASTJET_DIR" ]]; then
    FASTJET_CONFIG_PATH="$FASTJET_DIR/bin/fastjet-config"
    if [[ -x "$FASTJET_CONFIG_PATH" ]]; then
        echo "   ✓ Found: $FASTJET_CONFIG_PATH"
        echo "   Version: $($FASTJET_CONFIG_PATH --version)"
        echo "   CXX Flags: $($FASTJET_CONFIG_PATH --cxxflags)"
        echo "   Libraries: $($FASTJET_CONFIG_PATH --libs)"
    else
        echo "   ✗ Not found at: $FASTJET_CONFIG_PATH"
    fi
else
    # Check system PATH
    if command -v fastjet-config >/dev/null 2>&1; then
        echo "   ✓ Found in PATH: $(which fastjet-config)"
        echo "   Version: $(fastjet-config --version)"
    else
        echo "   ✗ Not found in PATH"
    fi
fi
echo

# Check for header files
echo "3. Header Files:"
if [[ -n "$FASTJET_DIR" ]]; then
    HEADER_PATH="$FASTJET_DIR/include/fastjet/PseudoJet.hh"
    if [[ -f "$HEADER_PATH" ]]; then
        echo "   ✓ Found: $HEADER_PATH"
    else
        echo "   ✗ Not found at: $HEADER_PATH"
        # Try alternative locations
        for alt in "$FASTJET_DIR/include/fastjet" "$FASTJET_DIR/fastjet"; do
            if [[ -d "$alt" ]]; then
                echo "   Alternative: $alt/ contains:"
                ls "$alt"/*.hh 2>/dev/null | head -3
                break
            fi
        done
    fi
else
    # Check system locations
    for sys_path in /usr/include /usr/local/include /opt/local/include; do
        if [[ -f "$sys_path/fastjet/PseudoJet.hh" ]]; then
            echo "   ✓ Found: $sys_path/fastjet/PseudoJet.hh"
            break
        fi
    done
fi
echo

# Check for library files
echo "4. Library Files:"
if [[ -n "$FASTJET_DIR" ]]; then
    for lib_dir in "$FASTJET_DIR/lib" "$FASTJET_DIR/lib64"; do
        if [[ -d "$lib_dir" ]]; then
            echo "   Checking: $lib_dir"
            ls "$lib_dir"/libfastjet* 2>/dev/null || echo "     No libfastjet* found"
        fi
    done
else
    # Check system locations
    for sys_lib in /usr/lib /usr/local/lib /opt/local/lib; do
        if [[ -f "$sys_lib/libfastjet.so" ]] || [[ -f "$sys_lib/libfastjet.dylib" ]] || [[ -f "$sys_lib/libfastjet.a" ]]; then
            echo "   ✓ Found FastJet library in: $sys_lib"
            ls "$sys_lib"/libfastjet* 2>/dev/null
            break
        fi
    done
fi
echo

# Check pkg-config
echo "5. pkg-config:"
if command -v pkg-config >/dev/null 2>&1; then
    echo "   ✓ pkg-config available"
    
    # Add FASTJET_DIR to PKG_CONFIG_PATH if set
    if [[ -n "$FASTJET_DIR" ]]; then
        export PKG_CONFIG_PATH="$FASTJET_DIR/lib/pkgconfig:$PKG_CONFIG_PATH"
        echo "   Added to PKG_CONFIG_PATH: $FASTJET_DIR/lib/pkgconfig"
    fi
    
    if pkg-config --exists fastjet 2>/dev/null; then
        echo "   ✓ FastJet found via pkg-config"
        echo "   Version: $(pkg-config --modversion fastjet)"
        echo "   CFlags: $(pkg-config --cflags fastjet)"
        echo "   Libs: $(pkg-config --libs fastjet)"
    else
        echo "   ✗ FastJet not found via pkg-config"
        echo "   Current PKG_CONFIG_PATH: ${PKG_CONFIG_PATH:-<not set>}"
        
        # Look for .pc files
        if [[ -n "$FASTJET_DIR" ]]; then
            if [[ -f "$FASTJET_DIR/lib/pkgconfig/fastjet.pc" ]]; then
                echo "   Found .pc file: $FASTJET_DIR/lib/pkgconfig/fastjet.pc"
            else
                echo "   No .pc file found in: $FASTJET_DIR/lib/pkgconfig/"
            fi
        fi
    fi
else
    echo "   ✗ pkg-config not available"
fi
echo

echo "6. Suggested Solutions:"
if [[ -z "$FASTJET_DIR" ]]; then
    echo "   - Set FASTJET_DIR environment variable:"
    echo "     export FASTJET_DIR=/path/to/fastjet/installation"
else
    echo "   - Current FASTJET_DIR: $FASTJET_DIR"
    if [[ ! -f "$FASTJET_DIR/bin/fastjet-config" ]]; then
        echo "   - ⚠ fastjet-config not found, check FASTJET_DIR path"
    fi
    if [[ ! -f "$FASTJET_DIR/include/fastjet/PseudoJet.hh" ]]; then
        echo "   - ⚠ Headers not found, check FASTJET_DIR path"
    fi
fi

echo "   - Try building with explicit paths:"
echo "     cmake .. -DFASTJET_DIR=\$FASTJET_DIR"
echo "   - Enable debug output:"
echo "     cmake .. -DFASTJET_DEBUG=ON"
