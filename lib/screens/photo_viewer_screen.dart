import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_inner_flutter_module/pigeon/generated_pigeon.dart' as pigeon;
import 'package:my_inner_flutter_module/services/image_service.dart';

class PhotoViewerScreen extends StatefulWidget {
  final pigeon.ImageInfo? initialImageInfo;

  const PhotoViewerScreen({super.key, this.initialImageInfo});

  @override
  State<PhotoViewerScreen> createState() => _PhotoViewerScreenState();
}

class _PhotoViewerScreenState extends State<PhotoViewerScreen> {
  pigeon.ImageInfo? _imageInfo;
  File? _imageFile;
  final ImageService _imageService = ImageService();
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _imageInfo = widget.initialImageInfo ?? _imageService.currentImage;
    _loadImage();
  }

  Future<void> _loadImage() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    if (_imageInfo == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'No image information provided';
      });
      return;
    }

    try {
      final file = await _imageService.getImageFile();
      setState(() {
        _imageFile = file;
        _isLoading = false;
        _errorMessage = file == null ? 'Could not load image' : null;
      });

      // Notify the host platform that the image was displayed
      if (_imageFile != null) {
        _imageService.onImageDisplayed(true);
      } else {
        _imageService.onImageDisplayed(false);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading image: $e';
      });
      _imageService.onImageDisplayed(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo Viewer'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(_errorMessage!, style: Theme
                .of(context)
                .textTheme
                .titleMedium),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadImage,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_imageFile != null) {
      return Column(
        children: [
          Expanded(
            child: Center(
              child: Image.file(
                _imageFile!,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _imageInfo?.fileName ?? 'Unknown file',
              style: Theme
                  .of(context)
                  .textTheme
                  .bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No image available',
            style: Theme
                .of(context)
                .textTheme
                .titleMedium,
          ),
        ],
      ),
    );
  }
}