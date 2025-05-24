import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class CropPhaseScreen extends StatefulWidget {
  final Uint8List imageBytes;
  final Function(Uint8List) onCropped;

  const CropPhaseScreen({
    required this.imageBytes,
    required this.onCropped,
  });

  @override
  State<CropPhaseScreen> createState() => _CropPhaseScreenState();
}

class _CropPhaseScreenState extends State<CropPhaseScreen> {
  final GlobalKey _previewKey = GlobalKey();

  Future<void> _cropImage() async {
    RenderRepaintBoundary boundary =
        _previewKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List croppedBytes = byteData!.buffer.asUint8List();

    widget.onCropped(croppedBytes);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "画像トリミング",
          style: TextStyle(color: Color.fromARGB(255, 209, 209, 0)),
        ),
        iconTheme: IconThemeData(color: Color.fromARGB(255, 209, 209, 0)),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // トリミング枠（AspectRatio + RepaintBoundary）はそのまま
            AspectRatio(
              aspectRatio: 3 / 2,
              child: RepaintBoundary(
                key: _previewKey,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black45,
                        blurRadius: 10,
                        offset: Offset(0, 6),
                      )
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InteractiveViewer(
                    minScale: 1.0,
                    maxScale: 4.0,
                    child: Image.memory(
                      widget.imageBytes,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // トリミング実行ボタン
            ElevatedButton.icon(
              onPressed: _cropImage,
              icon: Icon(Icons.check),
              label: Text("この範囲でトリミング"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 209, 209, 0),
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
