# Android Integration Guide

This guide explains how to integrate the Flutter Photo Viewer module into an existing Android application.

## Prerequisites

- Android Studio Arctic Fox (2020.3.1) or newer
- Gradle version 7.0 or newer
- Android SDK 21+ (Android 5.0 or higher)
- Flutter SDK (stable channel)

## Setup

### 1. Add Flutter Module Dependency

In your Android project's `settings.gradle` file, add:

```gradle
dependencyResolutionManagement {
    repositories {
        google()
        mavenCentral()
        // Add the Flutter SDK path repository
        maven {
            url '../my_inner_flutter_module/build/host/outputs/repo'
        }
        // Or if using a different path to your Flutter module:
        // maven {
        //     url '/path/to/my_inner_flutter_module/build/host/outputs/repo'
        // }
    }
}
```

In your app's `build.gradle` file, add the Flutter module as a dependency:

```gradle
dependencies {
    // Other dependencies...
    
    // Flutter module
    implementation project(':flutter')
    // Or use the AAR directly:
    // implementation 'com.example.my_inner_flutter_module:flutter_release:1.0'
    
    // Debug mode (optional, only for development)
    // debugImplementation 'com.example.my_inner_flutter_module:flutter_debug:1.0'
}
```

### 2. Configure Flutter Engine in Your Application

Create a FlutterEngine instance in your application class:

```kotlin
class MyApplication : Application() {
    lateinit var flutterEngine: FlutterEngine

    override fun onCreate() {
        super.onCreate()
        
        // Initialize Flutter Engine
        flutterEngine = FlutterEngine(this)
        flutterEngine.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint.createDefault()
        )
        
        // Keep the Flutter engine warm and ready to use
        FlutterEngineCache.getInstance().put("photo_viewer_engine_id", flutterEngine)
    }
}
```

### 3. Implement Pigeon Communication

Add the generated Kotlin code from Pigeon to your Android app (should be located at
`android/src/main/kotlin/com/example/my_inner_flutter_module/GeneratedPigeon.kt`).

Create a class to handle the Flutter communication:

```kotlin
class PhotoViewerManager(private val context: Context) : FlutterImageApi {
    private val imageDisplayApi: ImageDisplayApi
    private val flutterEngine: FlutterEngine = FlutterEngineCache.getInstance().get("photo_viewer_engine_id")
        ?: throw IllegalStateException("Flutter Engine not found in cache")

    init {
        // Set up the Flutter image API
        imageDisplayApi = ImageDisplayApi(flutterEngine.dartExecutor.binaryMessenger)
        FlutterImageApi.setup(flutterEngine.dartExecutor.binaryMessenger, this)
    }
    
    fun displayImage(uri: String, fileName: String) {
        val imageInfo = ImageInfo().apply {
            this.uri = uri
            this.fileName = fileName
        }
        
        // Send image information to Flutter
        imageDisplayApi.setImageInfoAsync(imageInfo) { /* Optional callback */ }
    }
    
    override fun onImageDisplayed(success: Boolean) {
        // Handle notification that the image was displayed
        Log.d("PhotoViewerManager", "Image displayed: $success")
    }
}
```

### 4. Launch the Flutter Activity with an Image

Create an Activity to display the Flutter UI:

```kotlin
class PhotoViewerActivity : FlutterActivity() {
    companion object {
        private const val IMAGE_URI = "image_uri"
        private const val IMAGE_FILENAME = "image_filename"

        fun createIntent(context: Context, imageUri: String, fileName: String): Intent {
            return IntentBuilder(context, PhotoViewerActivity::class.java)
                .putExtra(IMAGE_URI, imageUri)
                .putExtra(IMAGE_FILENAME, fileName)
                .build()
        }
    }
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Get image information from intent
        val imageUri = intent.getStringExtra(IMAGE_URI) ?: return
        val fileName = intent.getStringExtra(IMAGE_FILENAME) ?: ""
        
        // Create image info object
        val imageInfo = ImageInfo().apply {
            uri = imageUri
            this.fileName = fileName
        }
        
        // Send to Flutter
        val imageDisplayApi = ImageDisplayApi(flutterEngine.dartExecutor.binaryMessenger)
        imageDisplayApi.setImageInfoAsync(imageInfo) { /* Optional callback */ }
    }
    
    override fun getCachedEngineId(): String = "photo_viewer_engine_id"
}
```

### 5. Example: Handle Image Sharing Intent

To receive images shared from other apps, add this to your manifest:

```xml
<activity
    android:name=".ShareReceiverActivity"
    android:exported="true">
    <intent-filter>
        <action android:name="android.intent.action.SEND" />
        <category android:name="android.intent.category.DEFAULT" />
        <data android:mimeType="image/*" />
    </intent-filter>
</activity>
```

And create the handling activity:

```kotlin
class ShareReceiverActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        if (intent?.action == Intent.ACTION_SEND && intent.type?.startsWith("image/") == true) {
            // Get the URI of the image
            val imageUri = intent.getParcelableExtra<Uri>(Intent.EXTRA_STREAM)
            
            if (imageUri != null) {
                // Optional: Get image file name
                val fileName = getFileNameFromUri(imageUri)
                
                // Launch the Flutter photo viewer
                startActivity(PhotoViewerActivity.createIntent(
                    this, 
                    imageUri.toString(), 
                    fileName
                ))
                
                // Close this activity
                finish()
            }
        }
    }
    
    private fun getFileNameFromUri(uri: Uri): String {
        // Code to extract file name from URI...
        // This will vary based on URI type (content:// vs file://)
        return "image.jpg" // Replace with actual implementation
    }
}
```

## Troubleshooting

### Common Issues

1. **Flutter engine not initialized**
    - Ensure you're initializing the Flutter engine in your Application class
    - Verify the engine ID matches between caching and retrieval

2. **Image doesn't display**
    - Check that the URI format is correct and accessible
    - Verify you have storage permissions if needed
    - Look for errors in logcat related to file access

3. **Pigeon communication issues**
    - Make sure the generated Pigeon code is included in your project
    - Check that the binary messenger is correctly passed to the API setup
    - Verify that the method names match the Pigeon API definition

4. **"Unable to find cached engine" error**
    - Ensure the Flutter engine is initialized before trying to use it
    - Verify the engine ID is consistent across your code

### Debugging

Enable verbose Flutter logging by adding this before engine initialization:

```kotlin
FlutterInjector.instance().flutterLoader().startInitialization(this)
GeneratedPluginRegistrant.registerWith(flutterEngine)
```

## Example Project

For a complete implementation example, see the reference project at:
https://github.com/neiljaywarner/MyKotlinOuterApplication