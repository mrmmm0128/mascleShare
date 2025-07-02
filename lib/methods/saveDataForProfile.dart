import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:muscle_share/methods/GetDeviceId.dart';

Future<int> saveInfoWeb(
    String id,
    String name,
    String startDay,
    String deviceId,
    Uint8List photoBytes,
    int height,
    int weight,
    String originId) async {
  try {
    String imageUrl = "";
    String dateKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
    WriteBatch batch = FirebaseFirestore.instance.batch(); // バッチの作成

    final memoryRef =
        FirebaseFirestore.instance.collection(dateKey).doc("memory");
    final memorySnapshot = await memoryRef.get();
    Map<String, dynamic> memoryData = memorySnapshot.data() ?? {};

    // もし ID が既に存在していたら処理を中止してロールバック
    final idDocRef = FirebaseFirestore.instance.collection("id_list").doc(id);
    final idDocSnapshot = await idDocRef.get();

    if (originId != id) {
      if (idDocSnapshot.exists) {
        // ID が既に存在する場合はロールバックしてエラーメッセージを表示
        return 0; // 処理を中断
      }
    }

    if (photoBytes.isNotEmpty) {
      // 写真がある場合の処理
      imageUrl = await uploadProfileImageToStorageWeb(deviceId, photoBytes);

      // バッチに写真を保存する操作を追加
      batch.set(
          FirebaseFirestore.instance.collection(deviceId).doc("profile"),
          {
            "photo": imageUrl,
            "startDay": startDay,
            "height": height,
            "weight": weight,
            "name": name,
            "id": id
          },
          SetOptions(merge: true));

      batch.set(
          FirebaseFirestore.instance.collection("user_list").doc(deviceId), {
        "name": name,
      });

      memoryData.forEach((key, value) {
        if (value is Map<String, dynamic> && value["deviceId"] == deviceId) {
          String uniqueKey = key;
          Map<String, dynamic> updatedEntry = Map<String, dynamic>.from(value);
          updatedEntry["icon"] = imageUrl;
          updatedEntry["name"] = name;
          batch.set(
              memoryRef, {uniqueKey: updatedEntry}, SetOptions(merge: true));
        }
      });
    } else {
      // 写真がない場合の処理
      final docRef =
          FirebaseFirestore.instance.collection(deviceId).doc("profile");
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        batch.update(docRef, {
          "startDay": startDay,
          "name": name,
          "height": height,
          "weight": weight,
          "id": id
        });
      } else {
        batch.set(
            docRef,
            {
              "startDay": startDay,
              "name": name,
              "height": height,
              "weight": weight,
              "id": id
            },
            SetOptions(merge: true));
      }

      memoryData.forEach((key, value) {
        if (value is Map<String, dynamic> && value["deviceId"] == deviceId) {
          String uniqueKey = key;
          Map<String, dynamic> updatedEntry = Map<String, dynamic>.from(value);
          updatedEntry["name"] = name;
          batch.set(
              memoryRef, {uniqueKey: updatedEntry}, SetOptions(merge: true));
        }
      });

      batch.set(
          FirebaseFirestore.instance.collection("user_list").doc(deviceId), {
        "name": name,
      });
    }

    // IDが空でない場合、IDリストにデバイスIDを追加
    if (id.isNotEmpty) {
      batch.set(idDocRef, {"deviceId": deviceId}, SetOptions(merge: true));
    }

    // バッチ書き込みを実行
    await batch.commit();

    print("✅ Web: 画像を Firestore に保存しました！");
    return 2;
  } catch (e) {
    print("❌ Web: Firestore への保存に失敗しました: $e");
    // エラー時の処理を追加（必要に応じてエラーメッセージを表示するなど）
    return 3;
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
  String deviceId = await getDeviceIDweb();
  final docRef = FirebaseFirestore.instance.collection(deviceId).doc("profile");

  final docSnapshot = await docRef.get();

  if (docSnapshot.exists) {
    await docRef.update({"bestRecords": bestRecords});
  } else {
    await docRef.set({"bestRecords": bestRecords});
  }
}
