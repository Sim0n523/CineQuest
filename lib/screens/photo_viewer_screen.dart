import 'dart:io';
import 'package:flutter/material.dart';

/// Full-screen, pinch-zoomable view of a locally-stored photo — reached
/// by tapping the photo thumbnail on Movie Details. Uses Flutter's
/// built-in InteractiveViewer rather than pulling in a package like
/// photo_view, since basic pinch-to-zoom is all this needs.
class PhotoViewerScreen extends StatelessWidget {
  final String photoPath;

  const PhotoViewerScreen({super.key, required this.photoPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 1.0,
          maxScale: 4.0,
          child: Image.file(
            File(photoPath),
            errorBuilder: (_, __, ___) => const Text(
              'Photo unavailable',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ),
      ),
    );
  }
}
