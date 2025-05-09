#!/bin/bash

# Script to run Patrol integration tests for photo sharing feature
# Automatically starts an emulator if no devices are available

# Check if any Android devices or emulators are connected
check_devices() {
  echo "Checking for connected Android devices..."
  DEVICES=$(adb devices | grep -v "List" | grep "device\|emulator" | wc -l)
  return $DEVICES
}

# Start an emulator if no devices are connected
start_emulator() {
  echo "No Android devices found. Attempting to start an emulator..."
  
  # Check if any emulators are available
  AVDS=$(emulator -list-avds)
  if [ -z "$AVDS" ]; then
    echo "No emulators available. Please create one using Android Studio."
    echo "Run: sdkmanager --install \"system-images;android-30;google_apis;x86_64\""
    echo "Then: avdmanager create avd -n test_avd -k \"system-images;android-30;google_apis;x86_64\""
    exit 1
  fi
  
  # Get the first AVD from the list
  FIRST_AVD=$(echo "$AVDS" | head -n 1)
  echo "Starting emulator: $FIRST_AVD"
  
  # Start the emulator in the background
  emulator -avd "$FIRST_AVD" -no-audio -no-boot-anim -no-window &
  EMULATOR_PID=$!
  
  # Wait for the emulator to fully boot
  echo "Waiting for emulator to boot..."
  adb wait-for-device
  
  # Further wait for the system to be ready
  BOOT_COMPLETE=false
  while [ "$BOOT_COMPLETE" = false ]; do
    if adb shell getprop sys.boot_completed | grep -q "1"; then
      BOOT_COMPLETE=true
    else
      echo "Still waiting for emulator to complete boot..."
      sleep 2
    fi
  done
  
  # Wait a bit more for stability
  echo "Emulator booted. Waiting for stability..."
  sleep 10
  
  return 0
}

# Make sure adb is in PATH
if ! command -v adb &> /dev/null; then
  echo "Error: adb not found in PATH. Please install Android SDK and add platform-tools to your PATH."
  exit 1
fi

# Check if emulator command is available
if ! command -v emulator &> /dev/null; then
  echo "Warning: emulator command not found in PATH. Auto-starting an emulator may not work."
  echo "Please add Android SDK's emulator directory to your PATH."
fi

# Check for connected devices
check_devices
DEVICES_CONNECTED=$?

# Start emulator if no devices are connected
if [ $DEVICES_CONNECTED -eq 0 ]; then
  start_emulator
  if [ $? -ne 0 ]; then
    echo "Failed to start an emulator. Exiting."
    exit 1
  fi
fi

# Verify device connection again
check_devices
DEVICES_CONNECTED=$?
if [ $DEVICES_CONNECTED -eq 0 ]; then
  echo "No devices available after attempting to start emulator. Exiting."
  exit 1
fi

# Install Google Photos if not installed
echo "Making sure Google Photos is installed..."
if ! adb shell pm list packages | grep -q "com.google.android.apps.photos"; then
  echo "Google Photos not found, attempting to install it..."
  adb install -r -g "https://github.com/neiljaywarner/receive_images_flutter_demo/raw/main/sample_files/GooglePhotosGo.apk" || {
    echo "Warning: Could not install Google Photos automatically."
    echo "Please make sure Google Photos is installed manually on your test device."
  }
  
  # Wait for the installation to complete
  sleep 5
fi

# Check if NJWImageTestMay7 app is installed (expected to be installed separately)
if ! adb shell pm list packages | grep -q "com.neiljaywarner.mykotlinouterapplication"; then
  echo "Warning: NJWImageTestMay7 app not found. Tests will fail unless it's installed."
  echo "Please install the app before running the tests."
  read -p "Do you want to continue anyway? (y/n) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
  fi
fi

# Push a test image to the device if needed
echo "Pushing test image to device..."
adb push "patrol_testing/test_data/test_image.jpg" "/sdcard/Pictures/" || {
  echo "Warning: Could not push test image to device."
  echo "Tests may fail if no images are available in Google Photos."
}

# Run Flutter clean and get dependencies
echo "Preparing Flutter project..."
flutter clean
flutter pub get

# Run the Patrol integration test
echo "Running Patrol integration tests..."
cd "$(dirname "$0")/.."  # Navigate to project root
flutter test patrol_testing/integration_test/photo_sharing_test.dart --dart-define=PATROL_AUTOMATOR_TARGET=android --timeout=5m

# Capture the test result
TEST_RESULT=$?

# Kill the emulator if we started one
if [ -n "$EMULATOR_PID" ]; then
  echo "Shutting down the emulator..."
  kill $EMULATOR_PID
fi

# Report final status
if [ $TEST_RESULT -eq 0 ]; then
  echo "Tests completed successfully."
else
  echo "Tests failed with exit code $TEST_RESULT."
fi

exit $TEST_RESULT