#!/bin/bash
# Rizu MacOS Cross-Compilation Setup Script
# Builds osxcross using the Xcode SDK in downloads/

set -e

# Configuration (relative to build/ folder)
BUILD_DIR="$(pwd)"
DOWNLOADS_DIR="$BUILD_DIR/downloads"
OSXCROSS_DIR="$BUILD_DIR/osxcross"
SDK_XIP="$DOWNLOADS_DIR/Xcode_14.2.xip"
SDK_VERSION="13.1" # Xcode 14.2 contains MacOS SDK 13.1

echo "---------------------------------------------------"
echo "Setting up MacOS Cross-Compilation (osxcross)..."
echo "---------------------------------------------------"

# 1. Check for Xcode SDK
if [ ! -f "$SDK_XIP" ]; then
    echo "Error: $SDK_XIP not found."
    echo "Please ensure you have placed the Xcode_14.2.xip file in build/downloads/"
    exit 1
fi

# 2. Clone osxcross if not already present
if [ ! -d "$OSXCROSS_DIR" ]; then
    echo "Cloning osxcross..."
    git clone https://github.com/tpoechtrager/osxcross "$OSXCROSS_DIR"
else
    echo "osxcross directory already exists, skipping clone."
fi

# 3. Generate the SDK package
cd "$OSXCROSS_DIR"

if [ ! -f "tarballs/MacOSX$SDK_VERSION.sdk.tar.xz" ]; then
    echo "Extracting MacOS SDK from .xip (this may take a while)..."
    ./tools/gen_sdk_package_pbzx.sh "$SDK_XIP"
    
    echo "Moving generated SDK to tarballs directory..."
    mv MacOSX$SDK_VERSION.sdk.tar.xz tarballs/
else
    echo "MacOS SDK tarball already exists in tarballs/, skipping extraction."
fi

# 4. Build osxcross
echo "Building osxcross (UNATTENDED=1)..."
UNATTENDED=1 ./build.sh

echo ""
echo "---------------------------------------------------"
echo "MacOS Cross-Compilation Setup Complete!"
echo "---------------------------------------------------"
echo "To use the toolchain, add the following to your PATH:"
echo "export PATH=\$PATH:$OSXCROSS_DIR/target/bin"
echo ""
echo "You can then run './build.lua macos' (from inside the build/ folder)"
echo "---------------------------------------------------"
