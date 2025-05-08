# Flutter Photo Viewer Module

A Flutter module that displays photos shared from native Android and iOS applications.

## Features

- Receive and display images shared from Android and iOS host apps
- Communication between host and Flutter using Pigeon
- Clean, modern UI for photo viewing
- File-based image loading

## Integration Instructions

This Flutter module can be integrated into native Android and iOS applications.

For detailed integration instructions:

- [Android Integration Guide](android_outer.md)
- [iOS Integration Guide](ios_outer.md)

## Development

### Prerequisites

- Flutter SDK (channel stable)
- Android Studio / Xcode for native development
- Pigeon for code generation

### Getting Started

1. Clone this repository
2. Run `flutter pub get` to install dependencies
3. Build the module using `flutter build aar` for Android or `flutter build ios-framework` for iOS

## Communication Protocol

This module uses Pigeon to establish a communication protocol between Flutter and native platforms. The API includes:

- `ImageDisplayApi`: Native → Flutter communication for sending image information
- `FlutterImageApi`: Flutter → Native communication to notify when images are displayed

For more information on Flutter modules, see the [add-to-app documentation](https://flutter.dev/to/add-to-app).