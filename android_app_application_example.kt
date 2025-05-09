/**
 * Example Application class with Flutter initialization
 * This ensures the Flutter engine is ready when needed
 */

package com.neiljaywarner.mykotlinouterapplication

class MyApplication : Application() {

    companion object {
        private const val TAG = "MyApplication"
        
        // Engine ID must match what's expected in the tests
        const val FLUTTER_ENGINE_ID = "photo_viewer_engine_id"
    }

    // Flutter engine for the photo viewer module
    lateinit var flutterEngine: FlutterEngine

    override fun onCreate() {
        super.onCreate()

        // Initialize Flutter engine
        initFlutterEngine()
        
        // Other application initialization code...
    }

    private fun initFlutterEngine() {
        try {
            // Create and initialize the Flutter engine
            flutterEngine = FlutterEngine(this)
            
            // Start executing Dart code in the FlutterEngine
            flutterEngine.dartExecutor.executeDartEntrypoint(
                DartExecutor.DartEntrypoint.createDefault()
            )

            // Cache the engine using the required engine ID for later retrieval
            FlutterEngineCache.getInstance().put(FLUTTER_ENGINE_ID, flutterEngine)
            
            // Register the Pigeon API for communication
            setupPigeonApi()
            
            Log.d(TAG, "Flutter engine initialized and cached successfully")
        } catch (e: Exception) {
            Log.e(TAG, "Error initializing Flutter engine", e)
        }
    }

    private fun setupPigeonApi() {
        // This is where you would set up the Pigeon API for communication with Flutter
        // Example:
        // val api = GeneratedPigeon.ImageDisplayApi(flutterEngine.dartExecutor.binaryMessenger)
        // GeneratedPigeon.FlutterImageApi.setup(flutterEngine.dartExecutor.binaryMessenger, FlutterApiHandler())
    }

    override fun onTerminate() {
        super.onTerminate()
        
        // Clean up Flutter engine resources if needed
        if (::flutterEngine.isInitialized) {
            flutterEngine.destroy()
        }
    }
}