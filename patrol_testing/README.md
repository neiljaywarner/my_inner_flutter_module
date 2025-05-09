# Patrol Integration Tests

This directory contains automated tests for the Photo Sharing feature of the Flutter module.

## Overview

The tests verify that:

1. The Google Photos app can be launched
2. A photo can be selected and shared
3. The "NJWImageTestMay7" app appears in the share sheet
4. The photo is properly displayed in the app
5. The content:// URI is shown at the bottom of the app

## Prerequisites

- Android SDK with platform-tools in PATH
- Flutter SDK with integration_test package
- At least one Android device or emulator
- Google Photos app installed on the test device
- NJWImageTestMay7 app installed on the test device
- At least one image in Google Photos (script will attempt to push a test image)

## Running Tests

You can run the tests using the provided script:

```bash
./patrol_testing/run_tests.sh
```

The script will:

1. Check for connected Android devices
2. Start an emulator if no devices are found
3. Ensure Google Photos is installed
4. Push a test image to the device if needed
5. Run the Patrol integration test

## Manual Test Execution

If you prefer to run tests manually:

```bash
flutter test patrol_testing/integration_test/photo_sharing_test.dart --dart-define=PATROL_AUTOMATOR_TARGET=android
```

## Test Results

Screenshot artifacts from test runs are stored in:

- Android: `/sdcard/Pictures/patrol`
- iOS: `~/Documents/patrol`

## Troubleshooting

If tests fail, check:

1. Google Photos app is installed and accessible
2. NJWImageTestMay7 app is installed and appears in the share sheet
3. Storage permissions are granted to both apps
4. There is at least one image in Google Photos
5. The emulator or device has a stable connection