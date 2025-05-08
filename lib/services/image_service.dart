import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:my_inner_flutter_module/pigeon/generated_pigeon.dart' as pigeon;

class ImageService implements pigeon.FlutterImageApi {
  static final ImageService _instance = ImageService._internal();

  // Store the current image info
  pigeon.ImageInfo? currentImage;

  factory ImageService() {
    return _instance;
  }

  ImageService._internal();

  void initialize() {
    // Register this instance to handle Flutter API calls from the host
    pigeon.FlutterImageApi.setup(this);
  }

  // Method to set image info programmatically (e.g., from native Android code via Pigeon)
  void setImageInfo(pigeon.ImageInfo info) {
    currentImage = info;
    if (kDebugMode) {
      debugPrint('Received image info: ${info.uri}, ${info.fileName}');
    }
  }

  Future<File?> getImageFile() async {
    if (currentImage == null || currentImage!.uri == null) {
      return null;
    }

    try {
      // If the URI is a file path, we can create a File object directly
      final uri = Uri.parse(currentImage!.uri!);
      if (uri.scheme == 'file') {
        return File(uri.toFilePath());
      }

      // For content URIs, we would need to copy the file to our app's directory
      // This would require using a platform channel or method channel in a real app
      return null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting image file: $e');
      }
      return null;
    }
  }

  @override
  void onImageDisplayed(bool success) {
    // This method is called by the host platform when the image is displayed
    // We can add any callback handling here if needed
    if (kDebugMode) {
      debugPrint('Image displayed: $success');
    }
  }
}