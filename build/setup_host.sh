#!/bin/bash
# Rizu Ubuntu Setup Script
# Prepares the system for cross-compilation (Linux, Windows, MacOS)

set -e

echo "---------------------------------------------------"
echo "Setting up Ubuntu for Rizu Cross-Compilation..."
echo "Targeting: Linux (x86_64), Windows (x86_64), MacOS (x86_64)"
echo "---------------------------------------------------"

# Update package list
sudo apt-get update

# Install core build tools and dependencies
echo "Installing system packages..."
sudo apt-get install -y \
    build-essential \
    gcc-mingw-w64-x86-64 \
    clang \
    cmake \
    patch \
    libssl-dev \
    liblzma-dev \
    libxml2-dev \
    curl \
    unzip \
    tar \
    wget \
    p7zip-full \
    libasound2-dev \
    git

echo ""
echo "---------------------------------------------------"
echo "Basic Setup Complete!"
echo "---------------------------------------------------"
echo "Next steps (from inside the build/ folder):"
echo "1. Run './fetch_deps.lua linux' and './fetch_deps.lua windows'"
echo "2. Run './build.lua linux' and './build.lua windows'"
echo ""
echo "For MacOS (x86_64) targeting:"
echo "1. Run './setup_cross_macos.sh' (requires Xcode_14.2.xip in downloads/)"
echo "---------------------------------------------------"

