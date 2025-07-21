import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:crop_your_image/crop_your_image.dart';

class CropPhaseScreen extends StatefulWidget {
  final Uint8List imageBytes;
  final Function(Uint8List) onCropped;

  const CropPhaseScreen({
    super.key,
    required this.imageBytes,
    required this.onCropped,
  });

  @override
  State<CropPhaseScreen> createState() => _CropPhaseScreenState();
}

class _CropPhaseScreenState extends State<CropPhaseScreen> {
  final CropController _controller = CropController();
  bool _isCropping = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "画像トリミング",
          style: TextStyle(color: Color.fromARGB(255, 209, 209, 0)),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 209, 209, 0)),
        elevation: 0,
      ),
      body: Stack(
        children: [
          Crop(
            controller: _controller,
            image: widget.imageBytes,
            aspectRatio: 3 / 2,
            baseColor: Colors.black,
            maskColor: Colors.black.withOpacity(0.6),
            cornerDotBuilder: (size, edgeAlignment) => const DotControl(),
            onCropped: (croppedData) {
              widget.onCropped(croppedData);
              Navigator.of(context).pop();
            },
          ),
          if (_isCropping)
            const Center(
                child: CircularProgressIndicator(color: Colors.yellowAccent)),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          onPressed: () {
            setState(() => _isCropping = true);
            _controller.crop();
          },
          icon: const Icon(Icons.check),
          label: const Text("完了"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: const Color.fromARGB(255, 209, 209, 0),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            textStyle:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 6,
          ),
        ),
      ),
    );
  }
}
