import 'package:pigeon/pigeon.dart';

// Data class for image information
class ImageInfo {
  String? uri;
  String? fileName;
}

// API to handle image display in Flutter from Android
@HostApi()
abstract class ImageDisplayApi {
  // Method to receive image information from Android
  void setImageInfo(ImageInfo info);
}

// API for Flutter to communicate back to Android
@FlutterApi()
abstract class FlutterImageApi {
  // Method to notify Android that image was displayed
  void onImageDisplayed(bool success);
}