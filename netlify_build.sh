#!/bin/bash

# Exit on error
set -e

# Ensure flutter is available
if ! command -v flutter &> /dev/null
then
    echo "Flutter not found. Downloading stable channel..."
    git clone https://github.com/flutter/flutter.git -b stable --depth 1
    export PATH="$PATH:`pwd`/flutter/bin"
else
    echo "Flutter found at $(which flutter)"
fi

echo "Flutter version:"
flutter --version

echo "Enabling web support..."
flutter config --enable-web

echo "Getting dependencies..."
flutter pub get

echo "Building web app..."
flutter build web --release
