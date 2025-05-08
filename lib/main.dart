import 'package:flutter/material.dart';
import 'package:my_inner_flutter_module/screens/photo_viewer_screen.dart';
import 'package:my_inner_flutter_module/services/image_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the image service
  final imageService = ImageService();
  imageService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Photo Viewer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ImageService _imageService = ImageService();

  @override
  Widget build(BuildContext context) {
    // Check if we already have an image to display
    if (_imageService.currentImage != null) {
      // If we have an image, show the photo viewer screen
      return PhotoViewerScreen(
        initialImageInfo: _imageService.currentImage,
      );
    }

    // Otherwise show a placeholder screen
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Photo Viewer'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.image,
              size: 64,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            Text(
              'Waiting for image from host app...',
              style: Theme
                  .of(context)
                  .textTheme
                  .titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            const Text(
              'Share an image with this app to view it.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}