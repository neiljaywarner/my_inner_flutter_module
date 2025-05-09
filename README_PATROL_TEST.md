# Photo Viewer Patrol Tests

This README provides instructions for running the Patrol integration tests to verify the image sharing functionality
between Google Photos and your "NJWImageTestMay7" app.

## Prerequisites

Before running the tests, make sure you have:

1. **Required tools:**
    - Flutter SDK installed and on PATH
    - Android SDK with platform-tools on PATH
    - Android emulator available or a connected device

2. **Required apps installed on test device:**
    - Google Photos app
    - Your "NJWImageTestMay7" Android app (properly configured)

3. **Android app configuration requirements:**
    - App must appear as "NJWImageTestMay7" in the share sheet
    - PhotoViewerFragment must display the content:// URI in a TextView
    - The TextView ID must be `textview_filename`
    - The app should respond to intents with ACTION_SEND and image/* MIME type

## Setup Verification

To make sure your Android app is properly set up, check the following:

1. **App Name:** In `strings.xml`, verify `<string name="app_name">NJWImageTestMay7</string>`

2. **Manifest:** Check your ShareReceiverActivity has:
   ```xml
   <activity android:name=".ShareReceiverActivity"
       android:exported="true"
       android:label="@string/app_name">
       <intent-filter>
           <action android:name="android.intent.action.SEND" />
           <category android:name="android.intent.category.DEFAULT" />
           <data android:mimeType="image/*" />
       </intent-filter>
   </activity>
   ```

3. **PhotoViewerFragment:** Verify your fragment displays the image URI in a TextView with ID `textview_filename`

## Running Tests

1. **Install dependencies:**
   ```bash
   flutter pub get
   ```

2. **Connect a device or start an emulator**
   Our script will attempt to start an emulator if none is connected.

3. **Ensure test data is available:**
   The script will try to push a test image to the device, but you might want to have some images in Google Photos
   already.

4. **Run the test script:**
   ```bash
   chmod +x patrol_testing/run_tests.sh
   ./patrol_testing/run_tests.sh
   ```

5. **Monitoring the test:**
   The test will:
    - Launch Google Photos
    - Select and share an image
    - Look for "NJWImageTestMay7" in the share sheet
    - Verify the image and content:// URI display

## Troubleshooting

If tests fail, check:

1. **Share target not found:** Make sure your app name is exactly "NJWImageTestMay7"

2. **Image not displaying:** Verify your app has proper permissions and can handle content:// URIs

3. **URI text not found:** Ensure the TextView with ID `textview_filename` is showing the content:// URI

4. **Looking at test screenshots:**
   Screenshots are saved in `/sdcard/Pictures/patrol` on the device

## Running Tests Manually

If you prefer to run tests manually without the script:

```bash
flutter test patrol_testing/integration_test/photo_sharing_test.dart --dart-define=PATROL_AUTOMATOR_TARGET=android
```

## Reference Files

Check these example files for proper implementation:

- `android_manifest_example.xml`
- `android_app_application_example.kt`
- `android_app_share_receiver_example.kt`
- `android_app_strings_example.xml`