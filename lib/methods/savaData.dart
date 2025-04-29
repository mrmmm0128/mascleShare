import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:muscle_share/main.dart';

// 🔹 Firestore に画像を保存 (Web 用)
Future<void> savePhotoWeb(
    BuildContext context, Uint8List photoBytes, String deviceId) async {
  try {
    // ローディングインジケーターを表示
    showDialog(
      context: navigatorKey.currentContext!,
      barrierDismissible: false, // ダイアログ外をタップしても閉じない
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(), // ローディングインジケーター
        );
      },
    );

    // 画像アップロードの処理
    String imageUrl = await uploadImageToStorageWeb(deviceId, photoBytes);

    // その他の処理
    String dateKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
    String uniqueKey = '${dateKey}_${DateTime.now().millisecondsSinceEpoch}';
    Map<String, String?>? userInput = await showMascleSelection(context);
    String icon = "";
    String name = "";
    String mascle = userInput!["mascle"]!;
    String caption = userInput["caption"]!;

    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection(deviceId)
        .doc("profile")
        .get();

    if (snapshot.exists) {
      Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
      if (data != null) {
        icon = data["photo"] ?? "";
        name = data["name"] ?? "";
      }
    }

    await FirebaseFirestore.instance.collection(deviceId).doc("info").set({
      uniqueKey: {
        "photo": imageUrl,
        "caption": caption,
        "comment": "",
        "icon": icon,
        "deviceId": deviceId,
        "day": dateKey,
        "name": name,
        "mascle": mascle,
      }
    }, SetOptions(merge: true));

    await FirebaseFirestore.instance.collection(dateKey).doc("memory").set({
      uniqueKey: {
        "photo": imageUrl,
        "caption": caption,
        "comment": "",
        "icon": icon,
        "deviceId": deviceId,
        "name": name,
        "mascle": mascle,
      }
    }, SetOptions(merge: true));

    print("✅ Web: 画像を Firestore に保存しました！");
  } catch (e) {
    print("❌ Web: Firestore への保存に失敗しました: $e");
  } finally {
    // ローディングインジケーターを閉じる
    Navigator.of(navigatorKey.currentContext!).pop();
  }
}

// 🔹 Firestore に画像を保存 (iOS / Android 用)
Future<void> savePhotoMobile(
    BuildContext context, XFile photoFile, String deviceId) async {
  try {
    // ローディングインジケーターを表示
    showDialog(
      context: navigatorKey.currentContext!,
      barrierDismissible: false, // ダイアログ外をタップしても閉じない
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(), // ローディングインジケーター
        );
      },
    );
    String imageUrl = await uploadImageToStorageMobile(deviceId, photoFile);
    String dateKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
    Map<String, String?>? userInput = await showMascleSelection(context);
    String uniqueKey = '${dateKey}_${DateTime.now().millisecondsSinceEpoch}';
    String mascle = userInput!["mascle"]!;
    String caption = userInput["caption"]!;

    String icon = "";
    String name = "";

    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection(deviceId)
        .doc("profile")
        .get();

    if (snapshot.exists) {
      Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
      if (data != null) {
        icon = data["photo"] ?? "";
        name = data["name"] ?? "";
      }
    }

    await FirebaseFirestore.instance.collection(deviceId).doc("info").set({
      uniqueKey: {
        "photo": imageUrl,
        "caption": caption,
        "comment": "",
        "icon": icon,
        "deviceId": deviceId,
        "day": dateKey,
        "name": name,
        "mascle": mascle
      }
    }, SetOptions(merge: true));

    await FirebaseFirestore.instance.collection(dateKey).doc("memory").set({
      uniqueKey: {
        "photo": imageUrl,
        "caption": caption,
        "comment": "",
        "icon": icon,
        "deviceId": deviceId,
        "name": name,
        "mascle": mascle
      }
    }, SetOptions(merge: true));

    print("✅ Web: 画像を Firestore に保存しました！");
  } catch (e) {
    print("❌ Web: Firestore への保存に失敗しました: $e");
  } finally {
    // ローディングインジケーターを閉じる
    Navigator.of(navigatorKey.currentContext!).pop();
  }
}

Future<String> uploadImageToStorageWeb(
    String deviceId, Uint8List fileBytes) async {
  try {
    String filePath =
        "images/$deviceId/${DateTime.now().millisecondsSinceEpoch}.jpg";
    Reference ref = FirebaseStorage.instance.ref().child(filePath);

    // 🛠 MIME タイプを指定
    SettableMetadata metadata = SettableMetadata(contentType: "image/jpeg");

    UploadTask uploadTask = ref.putData(fileBytes, metadata);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  } catch (e) {
    print("❌ Web: Firebase Storage へのアップロードに失敗しました: $e");
    throw e;
  }
}

// 🔹 Firebase Storage に画像をアップロード (iOS / Android 用)
Future<String> uploadImageToStorageMobile(String deviceId, XFile file) async {
  try {
    String filePath =
        "images/$deviceId/${DateTime.now().millisecondsSinceEpoch}.jpg";
    Reference ref = FirebaseStorage.instance.ref().child(filePath);
    SettableMetadata metadata = SettableMetadata(contentType: "image/jpeg");
    UploadTask uploadTask = ref.putFile(File(file.path), metadata);
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  } catch (e) {
    print("❌ Mobile: Firebase Storage へのアップロードに失敗しました: $e");
    throw e;
  }
}

// 入力ダイアログを表示する関数
Future<Map<String, String?>?> showMascleSelection(BuildContext context) async {
  String? selectedMascle;
  String? caption;
  List<String> mascleOptions = ["Chest", "Back", "Legs", "Arms"];

  return await showModalBottomSheet<Map<String, String?>>(
    context: context,
    isScrollControlled: true, // キーボード対策
    backgroundColor: Colors.grey[900],
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "筋トレ情報を入力",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.yellow,
              ),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedMascle,
              decoration: InputDecoration(
                labelText: "部位を選択",
                labelStyle: TextStyle(color: Colors.yellow),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.yellow),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.yellow, width: 2),
                ),
              ),
              dropdownColor: Colors.grey[850],
              style: TextStyle(color: Colors.white),
              items: mascleOptions.map((String mascle) {
                return DropdownMenuItem<String>(
                  value: mascle,
                  child: Text(mascle, style: TextStyle(color: Colors.white)),
                );
              }).toList(),
              onChanged: (String? newValue) {
                selectedMascle = newValue;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "キャプションを入力",
                labelStyle: TextStyle(color: Colors.yellow),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.yellow),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.yellow, width: 2),
                ),
              ),
              onChanged: (value) {
                caption = value;
              },
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  child: Text("キャンセル", style: TextStyle(color: Colors.grey)),
                  onPressed: () => Navigator.pop(context, null),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                  ),
                  onPressed: () {
                    Navigator.pop(context, {
                      "mascle": selectedMascle,
                      "caption": caption,
                    });
                  },
                  child: Text("保存", style: TextStyle(color: Colors.black)),
                ),
              ],
            )
          ],
        ),
      );
    },
  );
}
