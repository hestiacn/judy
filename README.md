<div align="center">

# Judy - High-Performance Dynamic Array Library

> A C language library for extremely large sparse dynamic arrays, allocating memory only when data is actually stored, with support for Peta-scale expansion.

**Latest Version:** [![releases](https://img.shields.io/github/v/tag/hestiacn/judy)](https://github.com/hestiacn/judy/tags) | [![Changelog](https://img.shields.io/badge/📖_Changelog-Click_to_View-important)](CHANGELOG.md)

[![Version](https://img.shields.io/badge/version-1.0.6-blue)](https://github.com/hestiacn/judy)
[![License](https://img.shields.io/badge/license-LGPL%202.1-green)](COPYING)
[![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20macOS%20%7C%20FreeBSD%20%7C%20HP--UX-lightgrey)]()
<br>
[📄 中文版](README-zh_CN.md) | [🐞 Report Bug](https://github.com/hestiacn/judy/issues)

</div>

---

## 📖 Table of Contents

- [Introduction](#introduction)
- [Important Notes](#important-notes)
- [Quick Start (Linux)](#quick-start-linux)
- [Building from Source](#building-from-source)
- [Windows Packages](#windows-packages)
- [Build Options](#build-options)
- [Directory Structure](#directory-structure)
- [Known Issues](#known-issues)

---

## Introduction

Judy is a high-performance dynamic array library implemented in C. Unlike traditional arrays or hash tables, a Judy array is initially just a null pointer — **it only consumes memory when data is actually stored**, while being able to dynamically expand to the limits of physical memory.

Judy arrays support insertion, retrieval, and deletion of numeric or string indexes. No configuration or tuning is required — in fact, it's impossible. Judy provides sorting, counting, and neighboring/empty space search functions. Indexes can be sequential, clustered, periodic, or random — it makes no difference to the algorithm. Judy arrays can be hierarchically arranged to handle arbitrary bit patterns — large indexes, key sets, etc.

### Why Choose Judy?

| Feature | Description |
|---------|-------------|
| ⚡ **High Performance** | Time complexity approaches O(log₂₅₆ n); a 256-fold increase in data volume requires only one additional memory access |
| 💾 **Extreme Memory Efficiency** | Zero memory footprint for empty arrays; allocates on demand with no internal fragmentation |
| 🔧 **Zero Configuration** | No tuning, no pre-sizing, no hash function selection required |
| 📈 **Extreme Scalability** | Seamless scaling from 0 to Peta-scale elements |
| 🎯 **Universal Indexing** | Supports numeric and string indexes; performance unaffected by sequential/clustered/periodic/random distributions |

### Comparison with Traditional Data Structures

Judy outperforms arrays, sparse arrays, hash tables, B-trees, binary trees, linked lists, skip lists, and more in most scenarios.

### This Branch (v1.0.6)

Maintained by **HestiaCN**, building upon the official version with the following additions:

- 🖥️ **Cross-platform runtime compiler auto-detection**: Automatically detects CC/CXX compiler at runtime
- 🔒 **Modern compiler support**: Added explicit compatibility flags for Clang 15+ strict mode
- 📦 **Windows batch port**: Fully ported the build logic for JudyL / JudySL / JudyHS modules
- 🛡️ **Enhanced shared library build**: Strengthened `-fPIC` handling to ensure correct `.so` file generation
- 🔗 **pkg-config support**: Installs a `judy.pc` file for easier integration with other projects
- 🪟 **Native MSVC support**: Build 32/64-bit DLLs on Windows using MSVC compiler via `build.bat`
- 🪟 **MSYS2/MinGW-w64 support**: Added full build support on Windows (i686 and x86_64) via the MSYS2 environment

---

## Important Notes

The `build.sh` script introduces an automatic copying mechanism for the `judy.pc` file, making the build process dependent on the `pkg-config` (or `pkgconf`) tool.
Please install it according to your system environment:

- **Unix / FreeBSD**: `pkg install pkgconf`
- **Debian / Ubuntu / Mint**: `apt install pkg-config`
- **Fedora**: `dnf install pkgconf` (or `dnf5 install pkgconf` for newer versions)
- **RHEL / CentOS / Rocky**: `dnf install pkgconf` (or `yum install pkgconfig` for older systems)
- **Arch Linux / Manjaro**: `pacman -S pkgconf`
- **Alpine Linux**: `apk add pkgconfig`
- **openSUSE / SLES**: `zypper install pkg-config`
- **macOS (Homebrew)**: `brew install pkg-config`

### After installation, execute the following command:

```bash
cd judy-1.0.6/src
sh build.sh
```

### 💡 Why was judy.pc added? (Technical Background)

Judy Array is a high-performance but extremely old C library. Due to historical reasons, it suffers from a critical "persistent issue" in modern multi-platform compilation. Introducing `judy.pc` is the solution:

**1. Resolving the Legacy Issue of Missing Package Configuration**

Modern large-scale software compilation uniformly uses the `pkg-config` tool to locate third-party libraries. However, Judy is so old that the official source code does not provide a `judy.pc` configuration file, often causing compiler errors due to "Judy not found."

**2. Bridging the "Path Divide" Across Different Systems**

Different operating systems have completely different rules for storing third-party libraries:
- Linux systems: `/usr/lib/` and `/usr/include/`
- Unix systems: `/usr/local/lib/` and `/usr/local/include/`

Without a `.pc` file, build scripts would require numerous if/else statements to hardcode system paths, making them bloated and error-prone.

The `judy.pc` file, combined with the `pkg-config` tool, allows `build.sh` to automatically adapt to different system paths at compile time, without manual user intervention.

This is why we recommend installing `pkg-config` (or `pkgconf`) before compiling.

---

## Quick Start (Linux)

On Linux systems, you can build and install Judy from source with the following steps:

```bash
# Clone the repository
git clone https://github.com/hestiacn/judy.git
cd judy

# Generate the build system (required after first clone or build file updates)
./bootstrap

# Configure (auto-detects native architecture)
./configure

# Build
make

# Run tests (recommended)
make check

# Install to system (default /usr/local, may require sudo)
sudo make install
```

> **Note**: `./bootstrap` is used to generate the `configure` script. It only needs to be run once after the initial clone or after build files are updated. For regular development, you can directly use `./configure`.

---

## Building from Source

If you need custom build options or want to build Judy from source in your own environment, you can clone this repository or download the source package and build it automatically:

```bash
# Clone the repository
git clone https://github.com/hestiacn/judy.git
cd judy

# Or download the source package
wget https://github.com/hestiacn/judy/archive/refs/tags/v1.0.6.tar.gz
tar -xzf v1.0.6.tar.gz
cd judy-1.0.6

# Generate the build system and compile
./bootstrap
./configure
make
sudo make install
```

For detailed build options and platform-specific examples, please refer to the [Build Options](#build-options) section below.

---

## Windows Packages

Pre-built Windows packages are available in the GitHub Release:

### MSVC (Visual Studio)

```
v1.0.6/
├── judy-windows-msvc-x86.zip
│   ├── Judy.dll
│   ├── Judy.lib
│   └── checksums.txt
└── judy-windows-msvc-x64.zip
    ├── Judy.dll
    ├── Judy.lib
    └── checksums.txt
```

### MSYS2 (MinGW-w64)

```
v1.0.6/
├── judy-windows-msys2-mingw-x86.zip
│   └── i686/
│       ├── libjudy-1.0.6-1-i686.pkg.tar.zst
│       ├── libjudy-devel-1.0.6-1-i686.pkg.tar.zst
│       └── checksums.txt
└── judy-windows-msys2-mingw-x64.zip
    └── x86_64/
        ├── libjudy-1.0.6-1-x86_64.pkg.tar.zst
        ├── libjudy-devel-1.0.6-1-x86_64.pkg.tar.zst
        └── checksums.txt
```

### Verify SHA256 Checksums

```bash
# For MSVC packages
cd judy-windows-msvc-x86
sha256sum -c checksums.txt

# For MSYS2 packages
cd i686  # or x86_64
sha256sum -c checksums.txt
```

### Usage

#### MSVC (Visual Studio)

1.  Extract the ZIP package.
2.  Add `Judy.lib` to your project's linker input.
3.  Ensure `Judy.dll` is in your PATH or in the same directory as your executable.
4.  Include `Judy.h` in your source code.

```c
#include "Judy.h"

// Link with Judy.lib
```

#### MSYS2 (MinGW-w64)

Install the packages using `pacman`:

```bash
# 32-bit
pacman -U i686/libjudy-1.0.6-1-i686.pkg.tar.zst
pacman -U i686/libjudy-devel-1.0.6-1-i686.pkg.tar.zst

# 64-bit
pacman -U x86_64/libjudy-1.0.6-1-x86_64.pkg.tar.zst
pacman -U x86_64/libjudy-devel-1.0.6-1-x86_64.pkg.tar.zst
```

After installation, the library and headers will be available in your MSYS2 environment.

---

## Build Options

### Quick Start

```bash
# 1. Generate the build system (required)
./bootstrap

# 2. Configure (auto-detects native architecture)
./configure

# 3. Build
make

# 4. Run tests (optional)
make check

# 5. Install (defaults to /usr/local)
sudo make install
```

### Install to Custom Directory

```bash
# Install to a temporary directory for testing
./bootstrap
./configure --prefix=/tmp/judy-install
make
make install

# Install to user's local directory
./bootstrap
./configure --prefix=$HOME/local
make
make install

# Install to system directory (requires root)
./bootstrap
./configure --prefix=/usr
make
sudo make install
```

### 32-bit / 64-bit

Judy can be built as a 32-bit or 64-bit library. `configure` automatically detects the native environment and uses the appropriate default. To explicitly specify a non-native architecture:

```bash
# Generate the build system
./bootstrap

# Force 32-bit
./configure --enable-32-bit

# Force 64-bit
./configure --enable-64-bit

make
make install
```

### Platform Examples

#### Linux AMD64 (x86_64)

```bash
./bootstrap

# Native 64-bit (default)
./configure
make
make check
sudo make install

# Force 32-bit
./configure --enable-32-bit
make
make check
sudo make install
```

#### HP-UX PA-RISC

```bash
./bootstrap

# Native 32-bit (default)
./configure
make
make check
make install

# 64-bit
CFLAGS=+DD64 ./configure --enable-64-bit
make
make check
make install
```

> 💡 **Note**: `./bootstrap` generates the `configure` script and only needs to be run once. For day-to-day development, use `./configure` directly.

> **Note**: Machines that support both 32-bit and 64-bit runtime environments (such as RISC platforms and x86-64) may default to either. If you wish to compile for the non-default target type, **you are responsible for setting the correct flags**, such as `CFLAGS` to make your compiler switch modes and `LDFLAGS` to make your linker behave correctly.

---

## Directory Structure

```bash
judy/
├── src/           # Header and source files
├── doc/           # Documentation (external and internal)
├── test/          # Test harnesses and timing programs
├── tool/          # Tools (jhton: HTML to man page converter)
│                  # Note: Contains the latest config.guess and config.sub, copied to root by bootstrap
├── examples/      # Example programs
├── packaging/     # Packaging-related (MSYS2 PKGBUILD, etc.)
├── .github/       # GitHub Actions CI/CD configuration
├── bootstrap      # Bootstrapping script (generates build system, copies tool/config.* to root)
├── configure.ac   # Autoconf configuration template
├── Makefile.am    # Automake template
├── configure      # Autoconf-generated executable script
├── Makefile.in    # Automake-generated template file
├── config.guess   # Copied from tool/ by bootstrap
├── config.sub     # Copied from tool/ by bootstrap
├── AUTHORS        # Authors and contributors
├── COPYING        # License (LGPL 2.1)
├── INSTALL        # Installation instructions
├── CHANGELOG.md   # Changelog
├── README.md      # English README
└── README-zh_CN.md # Chinese README
```

---

## Known Issues

**HP-UX Compilation Error**: You may encounter `error 1000: Unexpected symbol:`. This is an issue with the HP compiler, which does not accept `static inline` followed by a typedef type.

```bash
# Solution (execute in the Judy root directory)
find ./ -name \*.[ch] | xargs perl -i.BAK -pe 's/static inline/static/g'
```

---

<p align="center">
  <sub>A branch maintained by <a href="https://github.com/hestiacn">HestiaCN</a> | Original author <a href="https://sourceforge.net/projects/judy/">Doug Baskins</a></sub>
</p>