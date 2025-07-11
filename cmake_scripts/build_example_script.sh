#!/bin/bash
# Build script for fjcontrib using CMake

savedir=${PWD}

function thisdir()
{
	SOURCE="${BASH_SOURCE[0]}"
	while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
	  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
	  SOURCE="$(readlink "$SOURCE")"
	  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
	done
	DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
	echo ${DIR}
}
THISD=$(thisdir)

cd ${THISD}/..

set -e

# Default values
BUILD_TYPE="Release"
BUILD_DIR="build"
INSTALL_PREFIX="/usr/local"
BUILD_EXAMPLES="ON"
BUILD_TESTING="OFF"
PARALLEL_JOBS=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --build-type)
            BUILD_TYPE="$2"
            shift 2
            ;;
        --build-dir)
            BUILD_DIR="$2"
            shift 2
            ;;
        --prefix)
            INSTALL_PREFIX="$2"
            shift 2
            ;;
        --no-examples)
            BUILD_EXAMPLES="OFF"
            shift
            ;;
        --enable-testing)
            BUILD_TESTING="ON"
            shift
            ;;
        --jobs|-j)
            PARALLEL_JOBS="$2"
            shift 2
            ;;
        --help|-h)
            echo "Usage: $0 [options]"
            echo "Options:"
            echo "  --build-type TYPE     Build type (Release, Debug, RelWithDebInfo) [default: Release]"
            echo "  --build-dir DIR       Build directory [default: build]"
            echo "  --prefix PREFIX       Install prefix [default: /usr/local]"
            echo "  --no-examples         Don't build examples"
            echo "  --enable-testing      Enable testing"
            echo "  --jobs, -j N          Number of parallel jobs [default: auto-detect]"
            echo "  --help, -h            Show this help"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

echo "Building fjcontrib with CMake"
echo "============================="
echo "Build type: $BUILD_TYPE"
echo "Build directory: $BUILD_DIR"
echo "Install prefix: $INSTALL_PREFIX"
echo "Build examples: $BUILD_EXAMPLES"
echo "Build testing: $BUILD_TESTING"
echo "Parallel jobs: $PARALLEL_JOBS"
echo ""

# Check for FastJet
echo "Checking for FastJet..."
if ! command -v fastjet-config &> /dev/null; then
    echo "Error: fastjet-config not found in PATH"
    echo "Please install FastJet or add it to your PATH"
    exit 1
fi

FASTJET_VERSION=$(fastjet-config --version)
echo "Found FastJet version: $FASTJET_VERSION"
echo ""

# Create build directory
if [[ -d "$BUILD_DIR" ]]; then
		echo "Build directory '$BUILD_DIR' already exists. Removing it..."
		rm -rf "$BUILD_DIR"
fi
echo "Creating build directory: $BUILD_DIR"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Configure
echo "Configuring with CMake..."
cmake .. \
    -DCMAKE_BUILD_TYPE="$BUILD_TYPE" \
    -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX" \
    -DBUILD_EXAMPLES="$BUILD_EXAMPLES" \
    -DBUILD_TESTING="$BUILD_TESTING" \
    -DFASTJET_DIR="$FASTJET_DIR"

echo ""
echo "Building..."
PARALLEL_JOBS=1
make -j"$PARALLEL_JOBS"

if [[ "$BUILD_TESTING" == "ON" ]]; then
    echo ""
    echo "Running tests..."
    ctest --output-on-failure
fi

echo ""
echo "Build completed successfully!"
echo ""
echo "To install, run:"
echo "  cd $BUILD_DIR && make install"
echo ""
echo "To run examples (if built), they are in:"
echo "  $BUILD_DIR/*/example_name"

cd "$savedir"