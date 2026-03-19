#!/bin/bash
# Rizu LuaJIT Windows Cross-Compilation Setup Script
# Builds LuaJIT for Windows (x86_64) from Linux using MinGW

set -e

# Paths relative to build/ folder
BUILD_DIR="$(pwd)"
DEPS_DIR="$BUILD_DIR/deps"
TREE_DIR="$(pwd)/../tree"

echo "---------------------------------------------------"
echo "Setting up LuaJIT for Windows (Cross-Compile)..."
echo "Target Directory: $TREE_DIR"
echo "---------------------------------------------------"

mkdir -p "$DEPS_DIR"
cd "$DEPS_DIR"

# 1. Clone LuaJIT
if [ ! -d "LuaJIT" ]; then
    echo "Cloning LuaJIT..."
    git clone https://github.com/LuaJIT/LuaJIT
else
    echo "LuaJIT directory already exists."
fi

# 2. Build LuaJIT for Windows
cd LuaJIT
echo "Building LuaJIT for Windows..."
# Clear previous build
make clean || true
# Cross-compile using MinGW
# On Windows, LuaJIT usually produces lua51.dll and libluajit.a (which is the import lib)
make -j$(nproc) HOST_CC="gcc -m64" CROSS=x86_64-w64-mingw32- TARGET_SYS=Windows

# 3. Install/Move files manually to tree/
echo "Installing Windows LuaJIT files to $TREE_DIR..."
mkdir -p "$TREE_DIR/lib" "$TREE_DIR/bin"

# We need the .dll for running and the import lib for linking
cp src/lua51.dll "$TREE_DIR/bin/"
cp src/lua51.dll "$TREE_DIR/lib/" # Also keep in lib for easy linking

if [ -f "src/libluajit-5.1.dll.a" ]; then
    cp src/libluajit-5.1.dll.a "$TREE_DIR/lib/"
elif [ -f "src/libluajit.a" ]; then
    cp src/libluajit.a "$TREE_DIR/lib/libluajit-5.1.dll.a"
else
    echo "Error: Could not find LuaJIT import library in src/"
    exit 1
fi

echo "---------------------------------------------------"
echo "LuaJIT Windows Setup Complete!"
echo "---------------------------------------------------"
