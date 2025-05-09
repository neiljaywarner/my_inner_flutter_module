# Android App Integration Prompt

Please modify the Android outer application to work correctly with the Flutter photo viewer module:

1. Make sure the app's manifest has the following:
    - Package name set to `com.neiljaywarner.mykotlinouterapplication`
    - Export attribute set to `true` for the activity receiving image shares
    - Intent filter for ACTION_SEND with MIME type "image/*"

2. Implement a PhotoViewerFragment that:
    - Correctly binds to layout file using ViewBinding
    - Sets up ImageView to display shared images
    - Shows the content:// URI text at the bottom
    - Uses a TextView with id `textview_filename` to display the URI text

3. Configure the Flutter Engine:
    - Initialize Flutter in your Application class
    - Cache the FlutterEngine with id "photo_viewer_engine_id"
    - Register the Pigeon-generated API for communication

4. Implement the share handling in an Activity:
    - Parse incoming intent with ACTION_SEND
    - Extract the URI from Intent.EXTRA_STREAM
    - Use URI.toString() to get the string representation
    - Pass the URI string to the FlutterActivity or Fragment

5. Make sure the app appears as "NJWImageTestMay7" in the share sheet:
    - Set the app name in strings.xml
    - Configure android:label in the manifest

6. Ensure proper permissions are requested:
    - READ_EXTERNAL_STORAGE
    - WRITE_EXTERNAL_STORAGE (for older Android versions)

The Flutter module is already set up to:

- Receive image URIs via Pigeon API
- Display images from content:// URIs
- Show the file path at the bottom of the screen
- Notify the Android app when an image is successfully displayed

The integration test will verify that the app appears in the share sheet as "NJWImageTestMay7" when sharing from Google
Photos, and that the shared image is displayed correctly with the content:// URI shown at the bottom.