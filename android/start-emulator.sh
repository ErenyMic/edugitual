#!/bin/bash
set -euo pipefail

export ANDROID_SDK_ROOT="$HOME/Android/Sdk"
CMDLINE_TOOLS="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin"
EMULATOR="$ANDROID_SDK_ROOT/emulator/emulator"
AVD_NAME="Medium_Phone_API_36.1"
export SYSTEM_IMAGE="system-images;android-36.1;google_apis_playstore;x86_64"
IMAGE_DIR="$ANDROID_SDK_ROOT/system-images/android-34/google_apis/x86_64"
APK_PATH="./output/debug/app-debug.apk"

echo "=== Environment ==="
echo "ANDROID_SDK_ROOT: $ANDROID_SDK_ROOT"
echo "CMDLINE_TOOLS:    $CMDLINE_TOOLS"
echo "EMULATOR:         $EMULATOR"
echo "==================="

if [ ! -d "$ANDROID_SDK_ROOT" ]; then
    echo "ERROR: Android SDK root not found at $ANDROID_SDK_ROOT"
    exit 1
fi

if [ ! -x "$CMDLINE_TOOLS/sdkmanager" ]; then
    echo "ERROR: sdkmanager not found at $CMDLINE_TOOLS"
    exit 1
fi

if [ ! -x "$EMULATOR" ]; then
    echo "WARNING: emulator binary not found. Installing emulator..."
    yes | "$CMDLINE_TOOLS/sdkmanager" "emulator"
fi

if ! command -v adb >/dev/null 2>&1; then
    echo "WARNING: adb not found. Installing platform-tools..."
    yes | "$CMDLINE_TOOLS/sdkmanager" "platform-tools"
    export PATH="$ANDROID_SDK_ROOT/platform-tools:$PATH"
fi

echo "Accepting licenses..."
timeout 10s bash -c "yes | \"$CMDLINE_TOOLS/sdkmanager\" --licenses" || true

echo "Listing installed android 34 system images (with google apis)..."
"$CMDLINE_TOOLS/sdkmanager" --list | grep "system-images;android-34;google_apis" || echo "(none found)"

if [ ! -d "$IMAGE_DIR" ]; then
    echo "System image $SYSTEM_IMAGE not found. Installing..."
    yes | "$CMDLINE_TOOLS/sdkmanager" "$SYSTEM_IMAGE"
    echo "System image installed."
else
    echo "System image $SYSTEM_IMAGE already installed."
fi

echo "Checking AVDs..."
existing_avds=$("$EMULATOR" -list-avds || true)
echo "Existing AVDs: $existing_avds"

if ! echo "$existing_avds" | grep -q "^$AVD_NAME$"; then
    echo "Creating AVD '$AVD_NAME'..."
    echo "no" | "$CMDLINE_TOOLS/avdmanager" create avd \
        -n "$AVD_NAME" \
        -k "$SYSTEM_IMAGE" \
        --device "pixel" \
        --force
    echo "AVD '$AVD_NAME' created."
else
    echo "AVD '$AVD_NAME' already exists."
fi

echo "Starting emulator..."
"$EMULATOR" -avd "$AVD_NAME" -gpu host -memory 2048 -no-snapshot -no-boot-anim &

echo "Waiting for device to boot..."
set +e
adb wait-for-device
while [[ "$(adb shell getprop sys.boot_completed 2>/dev/null)" != "1" ]]; do
    echo -n "."
    sleep 2
done
set -e
echo ""
echo "Device booted successfully."

if [ -f "$APK_PATH" ]; then
    echo "Installing APK..."
    adb install -r "$APK_PATH"
else
    echo "No APK found at $APK_PATH"
fi
