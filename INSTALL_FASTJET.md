# Installing FastJet for fjcontrib CMake Build

To build fjcontrib with CMake, you need FastJet installed first. Here are installation instructions for different systems:

## macOS (using Homebrew)

```bash
# Install FastJet using Homebrew
brew install fastjet

# Verify installation
fastjet-config --version
```

## Ubuntu/Debian

```bash
# Install FastJet from repositories
sudo apt-get update
sudo apt-get install libfastjet-dev fastjet-tools

# Verify installation
fastjet-config --version
```

## CentOS/RHEL/Fedora

```bash
# Install EPEL repository first (CentOS/RHEL)
sudo yum install epel-release  # or dnf install epel-release

# Install FastJet
sudo yum install fastjet-devel  # or dnf install fastjet-devel

# Verify installation
fastjet-config --version
```

## Building FastJet from Source

If FastJet is not available in your package manager:

```bash
# Download FastJet (replace X.Y.Z with the latest version)
wget http://fastjet.fr/repo/fastjet-3.4.2.tar.gz
tar -xzf fastjet-3.4.2.tar.gz
cd fastjet-3.4.2

# Configure and build
./configure --prefix=/usr/local
make -j$(nproc)
sudo make install

# Verify installation
fastjet-config --version
```

## Setting up Environment

Make sure `fastjet-config` is in your PATH:

```bash
# Check if FastJet is found
which fastjet-config
fastjet-config --version

# If not found, add to PATH (adjust path as needed)
export PATH=/usr/local/bin:$PATH
```

## Troubleshooting

### pkg-config cannot find fastjet

If you get errors about fastjet not being found by pkg-config:

```bash
# Check if fastjet.pc exists
find /usr -name "fastjet.pc" 2>/dev/null

# Add to PKG_CONFIG_PATH if needed
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:$PKG_CONFIG_PATH

# Test pkg-config
pkg-config --exists fastjet && echo "FastJet found" || echo "FastJet not found"
```

### Permission issues

If you get permission errors during installation:

- Use `sudo` for system-wide installation
- Or install to a user directory:
  ```bash
  ./configure --prefix=$HOME/local
  make install
  export PATH=$HOME/local/bin:$PATH
  export PKG_CONFIG_PATH=$HOME/local/lib/pkgconfig:$PKG_CONFIG_PATH
  ```

### Version compatibility

fjcontrib requires FastJet 3.0 or later. Check your version:

```bash
fastjet-config --version
```

Once FastJet is properly installed, you can proceed with building fjcontrib using the CMake instructions in CMAKE_README.md.
