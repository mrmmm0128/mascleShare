import 'dart:typed_data';
import 'package:flutter/material.dart';

class PhotoCropView extends StatefulWidget {
  final Uint8List imageBytes;

  const PhotoCropView({required this.imageBytes});

  @override
  _PhotoCropViewState createState() => _PhotoCropViewState();
}

class _PhotoCropViewState extends State<PhotoCropView> {
  TransformationController _controller = TransformationController();

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: AspectRatio(
        aspectRatio: 3 / 2, // 横長（例：16:9や3:2など好みに応じて）
        child: InteractiveViewer(
          transformationController: _controller,
          panEnabled: true,
          scaleEnabled: true,
          minScale: 1.0,
          maxScale: 4.0,
          child: Image.memory(
            widget.imageBytes,
            fit: BoxFit.cover, // 表示枠に合わせて大きく表示
          ),
        ),
      ),
    );
  }
}
