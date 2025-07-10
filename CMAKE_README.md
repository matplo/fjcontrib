# CMake Build Instructions for fjcontrib

This directory contains CMake build files for building fjcontrib (FastJet contrib) using CMake instead of the traditional autotools-based build system.

## Prerequisites

- CMake 3.12 or later
- FastJet installed and accessible via `fastjet-config`
- C++11 compatible compiler

## Quick Start

### Using the build script (recommended)

```bash
./build.sh
```

This will:
- Create a `build` directory
- Configure with CMake
- Build all contribs and examples
- Show instructions for installation

### Manual CMake build

```bash
mkdir build
cd build
cmake ..
make -j$(nproc)
```

## Build Options

### Using build.sh

```bash
./build.sh --help                    # Show all options
./build.sh --build-type Debug        # Debug build
./build.sh --no-examples             # Don't build examples
./build.sh --enable-testing          # Enable tests
./build.sh --prefix /opt/fjcontrib   # Custom install prefix
./build.sh --jobs 8                  # Use 8 parallel jobs
```

### Using CMake directly

```bash
mkdir build
cd build

# Basic configuration
cmake ..

# With options
cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr/local \
    -DBUILD_EXAMPLES=ON \
    -DBUILD_TESTING=OFF

make -j$(nproc)
```

## Available Options

| Option | Default | Description |
|--------|---------|-------------|
| `CMAKE_BUILD_TYPE` | Release | Build type (Release, Debug, RelWithDebInfo, MinSizeRel) |
| `CMAKE_INSTALL_PREFIX` | /usr/local | Installation directory |
| `BUILD_EXAMPLES` | ON | Build example programs |
| `BUILD_TESTING` | OFF | Build and enable tests |

## Installation

After building:

```bash
cd build
make install
```

This will install:
- Libraries to `${CMAKE_INSTALL_PREFIX}/lib/`
- Headers to `${CMAKE_INSTALL_PREFIX}/include/fastjet/contrib/`
- Examples to `${CMAKE_INSTALL_PREFIX}/bin/` (if `BUILD_EXAMPLES=ON`)
- Documentation to `${CMAKE_INSTALL_PREFIX}/share/doc/`

## Running Examples

Examples are built with the prefix `{contrib_name}_example_name`. For example:

```bash
# From build directory
./EnergyCorrelator/energycorrelator_example
./Nsubjettiness/nsubjettiness_example_basic_usage
./RecursiveTools/recursivetools_example_softdrop
```

## Testing

To run tests:

```bash
cd build
cmake .. -DBUILD_TESTING=ON
make
ctest
```

## Individual Contribs

Each contrib is built as a separate shared library. The following contribs are included:

- Centauro
- ClusteringVetoPlugin
- CMPPlugin
- ConstituentSubtractor
- EnergyCorrelator
- FlavorCone
- GHSAlgo
- GenericSubtractor
- IFNPlugin
- JetCleanser
- JetFFMoments
- JetsWithoutJets
- KTClusCXX
- LundPlane
- Nsubjettiness
- QCDAwarePlugin
- RecursiveTools
- ScJet
- SDFPlugin
- SignalFreeBackgroundEstimator
- SoftKiller
- SubjetCounting
- ValenciaPlugin
- VariableR

## Using in Your Project

After installation, you can use individual contribs in your CMake projects:

```cmake
find_package(PkgConfig REQUIRED)
pkg_check_modules(FASTJET REQUIRED fastjet)

# Link with specific contrib
target_link_libraries(your_target ${FASTJET_LIBRARIES} EnergyCorrelator)
target_include_directories(your_target PRIVATE ${FASTJET_INCLUDE_DIRS})
```

## Troubleshooting

### FastJet not found

Make sure FastJet is installed and `fastjet-config` is in your PATH:

```bash
which fastjet-config
fastjet-config --version
```

### Build fails

1. Check that you have all prerequisites installed
2. Try a clean build:
   ```bash
   rm -rf build
   ./build.sh
   ```
3. Check CMake configuration output for errors

### Missing contribs

The CMake build automatically detects available contribs based on directory structure. If a contrib is missing, check that:
- The contrib directory exists
- It contains either a `VERSION` file or `FJCONTRIB.cfg` file
- The contrib is not in the skip list in the main CMakeLists.txt

## Comparison with Autotools Build

| Feature | Autotools | CMake |
|---------|-----------|-------|
| Configuration | `./configure` | `cmake ..` |
| Build | `make` | `make` or `cmake --build .` |
| Install | `make install` | `make install` |
| Examples | Built by default | Controlled by `BUILD_EXAMPLES` |
| Tests | `make check` | `ctest` |
| Parallel build | `make -j` | `make -j` or `cmake --build . --parallel` |

The CMake build aims to be equivalent to the autotools build while providing better integration with modern C++ development tools and IDEs.
