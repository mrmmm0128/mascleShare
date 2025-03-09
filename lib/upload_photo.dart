// upload_screen.dart
import 'package:flutter/material.dart';

class UploadScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upload Photo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image, size: 100, color: Colors.grey),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Implement photo upload logic
              },
              child: Text('Choose Photo'),
            ),
          ],
        ),
      ),
    );
  }
}
