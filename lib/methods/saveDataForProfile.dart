import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

Future<void> saveInfoWeb(
    String name, String startDay, String deviceId, Uint8List photoBytes) async {
  try {
    String imageUrl = "";
    if (photoBytes.isNotEmpty) {
      imageUrl = await uploadProfileImageToStorageWeb(deviceId, photoBytes);
      await FirebaseFirestore.instance
          .collection(deviceId)
          .doc("profile")
          .set({"photo": imageUrl, "startDay": startDay, "name": name});
    } else {
      await FirebaseFirestore.instance
          .collection(deviceId)
          .doc("profile")
          .update({"startDay": startDay, "name": name});
    }
    print(imageUrl);

    print("✅ Web: 画像を Firestore に保存しました！");
  } catch (e) {
    print("❌ Web: Firestore への保存に失敗しました: $e");
  }
}

Future<String> uploadProfileImageToStorageWeb(
    String deviceId, Uint8List fileBytes) async {
  try {
    String filePath =
        "images/$deviceId/profile/${DateTime.now().millisecondsSinceEpoch}.jpg";
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
