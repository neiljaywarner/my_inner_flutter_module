/**
 * Example PhotoViewerFragment implementation for the Android outer application
 * This code should be added to your Android app to properly display shared images
 */

package com.neiljaywarner.mykotlinouterapplication

class PhotoViewerFragment : Fragment() {
    private var _binding: FragmentPhotoViewerBinding? = null
    private val binding get() = _binding!!

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View {
        _binding = FragmentPhotoViewerBinding.inflate(inflater, container, false)
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        // Get the fileName argument from arguments bundle
        // This should be the content:// URI of the shared image
        val imageUri = arguments?.getString("fileName") ?: ""
        
        // IMPORTANT: Display the URI as text - this is what the test looks for
        binding.textviewFilename.text = imageUri

        if (imageUri.isNotEmpty()) {
            try {
                // Try to load the image using standard ImageView methods
                val uri = Uri.parse(imageUri)
                binding.imageviewPhoto.setImageURI(uri)

                Log.d("PhotoViewerFragment", "Image URI loaded: $imageUri")
            } catch (e: Exception) {
                Log.e("PhotoViewerFragment", "Error loading image: ${e.message}")
                binding.imageviewPhoto.setImageResource(R.drawable.ic_launcher_background)
            }
        } else {
            binding.textviewFilename.text = "No image URI provided"
            binding.imageviewPhoto.setImageResource(R.drawable.ic_launcher_background)
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        _binding = null
    }

    companion object {
        /**
         * Use this factory method to create a new instance of PhotoViewerFragment
         * with the image URI as an argument
         */
        @JvmStatic
        fun newInstance(imageUri: String) =
            PhotoViewerFragment().apply {
                arguments = Bundle().apply {
                    putString("fileName", imageUri)
                }
            }
    }
}