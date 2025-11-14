#!/bin/bash
set -euo pipefail

# Default build type
BUILD_TYPE="${1:-debug}"  # Accepts 'debug' or 'release'

ANDROID_SRC="/app/src"
OUTPUT_DIR="/app/build"

echo "======================================"
echo " Starting Android APK build"
echo " Build type: $BUILD_TYPE"
echo " Source: $ANDROID_SRC"
echo " Output: $OUTPUT_DIR"
echo "======================================"

cd "$ANDROID_SRC"

# Check gradle wrapper
if [ ! -f "./gradlew" ]; then
    echo "✗ Gradle wrapper not found!"
    exit 1
fi

# Make gradlew executable
chmod +x ./gradlew

echo ""
echo "→ Cleaning previous build..."
# Clean without deleting mounted directories
./gradlew clean || {
    echo "⚠ Clean failed, trying to continue..."
    # Fallback: manually remove build artifacts but keep directory structure
    find ./app/build -type f -name "*.apk" -delete 2>/dev/null || true
}

echo ""
echo "→ Building $BUILD_TYPE APK..."

# Build APK
if [ "$BUILD_TYPE" = "debug" ]; then
    ./gradlew assembleDebug
    APK_PATH="./app/build/outputs/apk/debug"
elif [ "$BUILD_TYPE" = "release" ]; then
    ./gradlew assembleRelease
    APK_PATH="./app/build/outputs/apk/release"
else
    echo "✗ Unknown build type: $BUILD_TYPE"
    echo "  Usage: $0 [debug|release]"
    exit 1
fi

echo ""
echo "======================================"
echo " Copying APK to output..."
echo "======================================"

# Verify APK exists
if [ ! -d "$APK_PATH" ]; then
    echo "✗ APK directory not found: $APK_PATH"
    echo ""
    echo "Searching for APK files..."
    find ./app/build -name "*.apk" -type f
    exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR/$BUILD_TYPE"

# Copy APK(s)
APK_COUNT=$(find "$APK_PATH" -name "*.apk" -type f | wc -l)

if [ "$APK_COUNT" -eq 0 ]; then
    echo "✗ No APK files found in $APK_PATH"
    exit 1
fi

echo "Found $APK_COUNT APK file(s)"
echo ""

for apk in "$APK_PATH"/*.apk; do
    if [ -f "$apk" ]; then
        filename=$(basename "$apk")
        cp -v "$apk" "$OUTPUT_DIR/$BUILD_TYPE/$filename"
        
        # Show file info
        size=$(du -h "$OUTPUT_DIR/$BUILD_TYPE/$filename" | cut -f1)
        echo "  ✓ $filename ($size)"
    fi
done

echo ""
echo "======================================"
echo " ✓ Build complete!"
echo "======================================"
echo " APKs available in: ./android-output/$BUILD_TYPE/"
echo "======================================"