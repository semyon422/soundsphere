#!/bin/bash
# Rizu LuaJIT Setup Script
# Clones, builds, and installs LuaJIT into the tree/ directory

set -e

# Paths relative to build/ folder
BUILD_DIR="$(pwd)"
DEPS_DIR="$BUILD_DIR/deps"
TREE_DIR="$(pwd)/../tree"

echo "---------------------------------------------------"
echo "Setting up LuaJIT..."
echo "Target Directory: $TREE_DIR"
echo "---------------------------------------------------"

mkdir -p "$DEPS_DIR"
cd "$DEPS_DIR"

# 1. Clone LuaJIT
if [ ! -d "LuaJIT" ]; then
    echo "Cloning LuaJIT..."
    git clone https://github.com/LuaJIT/LuaJIT
else
    echo "LuaJIT directory already exists, skipping clone."
fi

# 2. Build LuaJIT
cd LuaJIT
echo "Building LuaJIT..."
make -j$(nproc)

# 3. Install LuaJIT
echo "Installing LuaJIT to $TREE_DIR..."
# We use DESTDIR and PREFIX= to install directly into our tree folder
make install DESTDIR="$TREE_DIR" PREFIX=

# 4. Create symlink
echo "Creating luajit symlink..."
ln -sf "$TREE_DIR/bin/luajit-"* "$TREE_DIR/bin/luajit"

echo "---------------------------------------------------"
echo "LuaJIT Setup Complete!"
echo "---------------------------------------------------"
