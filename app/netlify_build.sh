#!/bin/bash

# Exit on error
set -e

echo "Starting Netlify Build Script for Flutter Web..."

# Define install path relative to current directory (repo root)
FLUTTER_DIR="`pwd`/flutter"
FLUTTER_BIN="$FLUTTER_DIR/bin"

# Export PATH immediately for current shell and subshells
export PATH="$FLUTTER_BIN:$PATH"

# Check if flutter directory exists
if [ -d "$FLUTTER_DIR" ]; then
    echo "Flutter directory found at $FLUTTER_DIR"
    # Check if it's a valid flutter repo
    if [ -f "$FLUTTER_BIN/flutter" ]; then
        echo "Flutter executable exists. Verifying version..."
        flutter --version || { echo "Flutter version check failed. Re-installing..."; rm -rf "$FLUTTER_DIR"; }
    else
        echo "Flutter executable missing. Removing directory..."
        rm -rf "$FLUTTER_DIR"
    fi
else
    echo "Flutter directory not found."
fi

# Install Flutter if missing
if [ ! -d "$FLUTTER_DIR" ]; then
    echo "Cloning Flutter stable channel..."
    git clone https://github.com/flutter/flutter.git -b stable --depth 1 "$FLUTTER_DIR"
fi

# Verify installation
echo "Verifying Flutter installation..."
which flutter
flutter --version

echo "Configuring Flutter for web..."
flutter config --enable-web

echo "Getting dependencies..."
flutter pub get

echo "Building web app (release)..."
flutter clean
flutter build web --release --base-href "/" --no-tree-shake-icons

echo "Generating Netlify configuration files..."
echo "/* /index.html 200" > build/web/_redirects

cat << 'EOF' > build/web/_headers
/*
  Cross-Origin-Opener-Policy: same-origin
  Cross-Origin-Embedder-Policy: require-corp
EOF

echo "Build complete!"
ls -la build/web
