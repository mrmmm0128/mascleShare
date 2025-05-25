import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:muscle_share/methods/getDeviceId.dart';

Future<void> saveInfoWeb(String name, String startDay, String deviceId,
    Uint8List photoBytes, int height, int weight) async {
  try {
    String imageUrl = "";
    String dateKey = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final memoryRef =
        FirebaseFirestore.instance.collection(dateKey).doc("memory");

    final memorySnapshot = await memoryRef.get();
    Map<String, dynamic> memoryData = memorySnapshot.data() ?? {};

    if (photoBytes.isNotEmpty) {
      imageUrl = await uploadProfileImageToStorageWeb(deviceId, photoBytes);
      await FirebaseFirestore.instance.collection(deviceId).doc("profile").set({
        "photo": imageUrl,
        "startDay": startDay,
        "height": height,
        "weight": weight,
        "name": name,
      }, SetOptions(merge: true));

      memoryData.forEach((key, value) {
        if (value is Map<String, dynamic> && value["deviceId"] == deviceId) {
          // deviceId が一致するフィールドの "icon" と "name" を更新
          String uniqueKey = key;
          print(key);
          Map<String, dynamic> updatedEntry = Map<String, dynamic>.from(value);
          updatedEntry["icon"] = imageUrl;
          updatedEntry["name"] = name;

          memoryRef.set({uniqueKey: updatedEntry}, SetOptions(merge: true));
        }
      });
    } else {
      final docRef =
          FirebaseFirestore.instance.collection(deviceId).doc("profile");

      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        // ドキュメントが存在する場合はupdate
        await docRef.update({
          "startDay": startDay,
          "name": name,
          "height": height,
          "weight": weight,
        });
      } else {
        // ドキュメントが存在しない場合はset
        await docRef.set({
          "startDay": startDay,
          "name": name,
          "height": height,
          "weight": weight,
        }, SetOptions(merge: true));
      }
      memoryData.forEach((key, value) {
        if (value is Map<String, dynamic> && value["deviceId"] == deviceId) {
          String uniqueKey = key;
          print(key);
          Map<String, dynamic> updatedEntry = Map<String, dynamic>.from(value);
          updatedEntry["name"] = name;
          memoryRef.set({uniqueKey: updatedEntry}, SetOptions(merge: true));
        }
      });
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

Future<void> saveBestRecords(
    Map<String, List<Map<String, dynamic>>> bestRecords) async {
  String deviceId = await getDeviceUUID();
  final docRef = FirebaseFirestore.instance.collection(deviceId).doc("profile");

  final docSnapshot = await docRef.get();

  if (docSnapshot.exists) {
    await docRef.update({"bestRecords": bestRecords});
  } else {
    await docRef.set({"bestRecords": bestRecords});
  }
}
