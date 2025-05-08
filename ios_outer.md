# iOS Integration Guide

This guide explains how to integrate the Flutter Photo Viewer module into an existing iOS application.

## Prerequisites

- macOS development machine
- Xcode 13.0 or newer
- iOS 11.0+ target
- CocoaPods 1.10.0 or newer
- Flutter SDK (stable channel)

## Setup

### 1. Add Flutter Module to Your iOS Project

First, make sure your Flutter module is ready for iOS integration:

```bash
cd my_inner_flutter_module
flutter build ios-framework --output=build/ios/frameworks
```

In your iOS project, create or edit a `Podfile` to include Flutter:

```ruby
platform :ios, '11.0'

# The Flutter module framework path
flutter_application_path = '../my_inner_flutter_module'
load File.join(flutter_application_path, '.ios', 'Flutter', 'podhelper.rb')

target 'YourAppName' do
  # Your other pods...
  
  install_all_flutter_pods(flutter_application_path)
end

post_install do |installer|
  flutter_post_install(installer) if defined?(flutter_post_install)
  
  # Your other post-install hooks...
end
```

Then run:

```bash
pod install
```

### 2. Initialize Flutter Engine

In your AppDelegate, set up the Flutter engine:

```swift
import UIKit
import Flutter
import FlutterPluginRegistrant

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    lazy var flutterEngine = FlutterEngine(name: "photo_viewer_engine")
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Initialize Flutter engine
        flutterEngine.run()
        GeneratedPluginRegistrant.register(with: self.flutterEngine)
        
        return true
    }
}
```

### 3. Implement Pigeon Communication

Copy the generated Swift code from Pigeon to your iOS app.

Create a class to manage the Flutter communication:

```swift
class PhotoViewerManager: NSObject, FlutterImageApi {
    private let imageDisplayApi: ImageDisplayApi
    
    init(withEngine engine: FlutterEngine) {
        self.imageDisplayApi = ImageDisplayApi(binaryMessenger: engine.binaryMessenger)
        super.init()
        
        // Register this instance for receiving callbacks from Flutter
        FlutterImageApiSetup(engine.binaryMessenger, self)
    }
    
    func displayImage(uri: String, fileName: String) {
        // Create image info object
        let imageInfo = ImageInfo()
        imageInfo.uri = uri
        imageInfo.fileName = fileName
        
        // Send to Flutter
        imageDisplayApi.setImageInfo(info: imageInfo) { error in
            if let error = error {
                print("Error sending image info to Flutter: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - FlutterImageApi
    
    func onImageDisplayed(success: Bool, completion: @escaping (FlutterError?) -> Void) {
        print("Image displayed in Flutter: \(success)")
        completion(nil)
    }
}
```

### 4. Create a View Controller to Display Flutter UI

```swift
class PhotoViewerViewController: FlutterViewController {
    private let imageUri: String
    private let fileName: String
    
    init(withEngine engine: FlutterEngine, imageUri: String, fileName: String) {
        self.imageUri = imageUri
        self.fileName = fileName
        super.init(engine: engine, nibName: nil, bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create image info
        let imageInfo = ImageInfo()
        imageInfo.uri = imageUri
        imageInfo.fileName = fileName
        
        // Send to Flutter
        let imageDisplayApi = ImageDisplayApi(binaryMessenger: self.engine.binaryMessenger)
        imageDisplayApi.setImageInfo(info: imageInfo) { error in
            if let error = error {
                print("Error sending image info to Flutter: \(error.localizedDescription)")
            }
        }
    }
}
```

### 5. Example: Present the Flutter View Controller

From anywhere in your app:

```swift
func showPhotoViewer(imageUri: String, fileName: String) {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
        return
    }
    
    let flutterViewController = PhotoViewerViewController(
        withEngine: appDelegate.flutterEngine,
        imageUri: imageUri,
        fileName: fileName
    )
    
    // Present the Flutter view controller
    if let rootVC = UIApplication.shared.windows.first?.rootViewController {
        rootVC.present(flutterViewController, animated: true)
    }
}
```

### 6. Example: Handle Image Sharing from Other Apps

Add a Share Extension to your app to receive shared images. In your extension's `ShareViewController.swift`:

```swift
import UIKit
import Social
import MobileCoreServices

class ShareViewController: SLComposeServiceViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the extension UI
        self.title = "Photo Viewer"
        self.placeholder = "View this photo in Photo Viewer app"
    }
    
    override func didSelectPost() {
        // Get the image from the extension context
        if let extensionItems = extensionContext?.inputItems as? [NSExtensionItem] {
            for extensionItem in extensionItems {
                if let itemProviders = extensionItem.attachments {
                    for itemProvider in itemProviders {
                        if itemProvider.hasItemConformingToTypeIdentifier(kUTTypeImage as String) {
                            // Load the shared item
                            itemProvider.loadItem(forTypeIdentifier: kUTTypeImage as String, options: nil) { (item, error) in
                                if let url = item as? URL {
                                    // Save or process the image URL
                                    DispatchQueue.main.async {
                                        // Use UserDefaults shared through App Groups to pass the URL to main app
                                        let sharedDefaults = UserDefaults(suiteName: "group.com.yourcompany.photoviewer")
                                        sharedDefaults?.set(url.absoluteString, forKey: "shared_image_uri")
                                        sharedDefaults?.set(url.lastPathComponent, forKey: "shared_image_filename")
                                        sharedDefaults?.synchronize()
                                        
                                        // Open the main app
                                        self.openMainApp()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    override func configurationItems() -> [Any]! {
        // Return any configuration settings for your extension here
        return []
    }
    
    private func openMainApp() {
        // Complete the sharing operation
        self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
        
        // Open the main app using a custom URL scheme
        let url = URL(string: "photoviewer://shared-image")!
        self.extensionContext?.open(url, completionHandler: nil)
    }
}
```

In your main app, handle the URL scheme:

```swift
func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    if url.scheme == "photoviewer" && url.host == "shared-image" {
        // Retrieve the shared image from UserDefaults (App Groups)
        let sharedDefaults = UserDefaults(suiteName: "group.com.yourcompany.photoviewer")
        if let imageUri = sharedDefaults?.string(forKey: "shared_image_uri"),
           let fileName = sharedDefaults?.string(forKey: "shared_image_filename") {
            
            // Show the Flutter photo viewer
            showPhotoViewer(imageUri: imageUri, fileName: fileName)
            
            return true
        }
    }
    
    return false
}
```

## Troubleshooting

### Common Issues

1. **Pod install fails**
    - Make sure Flutter module is built properly with `flutter build ios-framework`
    - Check that the path to the Flutter module is correct in your Podfile

2. **Flutter engine initialization fails**
    - Ensure the Flutter engine is initialized in your AppDelegate
    - Check that all Flutter plugins are registered properly

3. **Image doesn't display**
    - Verify the image URI is valid and accessible from your app
    - Check for file permissions issues if accessing files from disk
    - Verify you have the appropriate entitlements for accessing shared content

4. **Pigeon API communication issues**
    - Make sure the generated Pigeon code is correctly included in your project
    - Verify the binary messenger is provided correctly to the APIs
    - Check that method signatures match the Pigeon API definition

### Debugging

Enable verbose Flutter logging by setting the environment variable:

```
export VERBOSE_SCRIPT_LOGGING=true
```

## Memory Management

Flutter uses a significant amount of memory, especially when displaying high-resolution images. Consider releasing the
Flutter engine when not in use:

```swift
func releaseFlutterEngine() {
    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
        GeneratedPluginRegistrant.unregister(from: appDelegate.flutterEngine)
        appDelegate.flutterEngine.shutDownEngine()
    }
}
```

## Example Project

For a complete implementation example, refer to the sample iOS project at:
https://github.com/neiljaywarner/receive_images_flutter_demo