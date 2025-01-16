#!/bin/bash

# Install system dependencies
apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# Install Rust 1.74.1
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain 1.74.1
source $HOME/.cargo/env

# Print versions
echo "Versions:"
node --version
npm --version
python3 --version
rustc --version
cargo --version
