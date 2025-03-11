import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // File クラスを使用

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? _image; // 画像を格納する変数

  // カメラを起動して画像を取得する
  Future<void> _takePhoto() async {
    final picker = ImagePicker();

    // カメラから画像を選択
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path); // 画像を _image に保存
      });
    } else {
      print("No image selected.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 209, 209, 0),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          'Upload Photo',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image, size: 100, color: Colors.grey),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // 画像選択ロジック（ファイルから選択）をここに追加
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 209, 209, 0), // 背景色を黄色に
                foregroundColor: Colors.black, // テキスト色
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15), // 角を丸める
                ),
                padding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 8), // 余白調整
                elevation: 2, // 立体感を少し追加
              ),
              child: Text(
                'Choose Photo',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold), // フォントサイズと太字設定
              ),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: _takePhoto, // ここでカメラを起動
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 209, 209, 0), // 背景色を黄色に
                foregroundColor: Colors.black, // テキスト色
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15), // 角を丸める
                ),
                padding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 8), // 余白調整
                elevation: 2, // 立体感を少し追加
              ),
              child: Text(
                'Take a Photo',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold), // フォントサイズと太字設定
              ),
            ),
            SizedBox(height: 20),
            // 画像が選ばれたら画像を表示
            _image != null
                ? Image.file(_image!) // 画像表示
                : Text('No image selected.',
                    style: TextStyle(color: Colors.white)), // 画像がない場合の表示
          ],
        ),
      ),
    );
  }
}
