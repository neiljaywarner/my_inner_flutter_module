/**
 * Example ShareReceiverActivity implementation
 * This handles images shared from other apps (e.g. Google Photos)
 */

package com.neiljaywarner.mykotlinouterapplication

class ShareReceiverActivity : AppCompatActivity() {
    
    companion object {
        private const val TAG = "ShareReceiverActivity"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_share_receiver)

        // Handle the shared image
        if (intent?.action == Intent.ACTION_SEND && intent.type?.startsWith("image/") == true) {
            handleSharedImage()
        } else {
            Log.e(TAG, "Received intent is not for image sharing: ${intent?.action}")
            finish()
        }
    }

    private fun handleSharedImage() {
        try {
            // Get the image URI
            val imageUri = intent.getParcelableExtra<Uri>(Intent.EXTRA_STREAM)
            if (imageUri != null) {
                Log.d(TAG, "Received image URI: $imageUri")
                
                // Option 1: Show the image in a fragment
                showInFragment(imageUri)
                
                // Option 2: Show the image in Flutter (uncomment to use instead)
                // showInFlutter(imageUri)
            } else {
                Log.e(TAG, "No image URI provided in the intent")
                finish()
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error handling shared image", e)
            finish()
        }
    }
    
    private fun showInFragment(imageUri: Uri) {
        // Create and show a Fragment to display the image
        val fragment = PhotoViewerFragment.newInstance(imageUri.toString())
        supportFragmentManager.commit {
            replace(R.id.fragment_container, fragment)
        }
    }
    
    // Option for showing the image in Flutter using FlutterActivity
    private fun showInFlutter(imageUri: Uri) {
        // Create Flutter intent with the image URI
        val flutterIntent = androidx.core.content.IntentCompat
            .createChooserIntent(null, "")
            .apply {
                setClass(this@ShareReceiverActivity, io.flutter.embedding.android.FlutterActivity::class.java)
                putExtra("route", "/photo-viewer")
                putExtra("image_uri", imageUri.toString())
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK)
            }
            
        // Start Flutter activity
        startActivity(flutterIntent)
        finish()
    }
}