import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:muscle_share/methods/getDeviceId.dart';

Future<Map<String, dynamic>> fetchInfo() async {
  String deviceId = await getDeviceIDweb();
  Map<String, dynamic> infoList = {};

  try {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection(deviceId)
        .doc("profile")
        .get();

    if (snapshot.exists) {
      Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;

      if (data != null) {
        infoList = {
          "url": data["photo"]?.toString() ?? "",
          "name": data["name"]?.toString() ?? "",
          "startDay": data["startDay"]?.toString() ?? "",
          "height": data["height"] ?? 0,
          "weight": data["weight"] ?? 0,
          "id": data["id"] ?? "",
        };
      }

      print(data?["photo"]);
    } else {
      return {"url": "", "name": "", "startDay": ""};
    }
  } catch (e) {
    print("❌ Firestore のデータ取得中に例外が発生しました: $e");
  }

  return infoList;
}

Future<Map<String, dynamic>> fetchOtherInfo(String deviceId) async {
  Map<String, dynamic> infoList = {};

  try {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection(deviceId)
        .doc("profile")
        .get();

    if (snapshot.exists) {
      Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;

      if (data != null) {
        infoList = {
          "url": data["photo"]?.toString() ?? "",
          "name": data["name"]?.toString() ?? "",
          "startDay": data["startDay"]?.toString() ?? "",
          "height": data["height"] ?? 0,
          "weight": data["weight"] ?? 0,
          "requested": data["requested"] ?? [""],
        };
      }

      print(data?["photo"]);
    } else {
      return {"url": "", "name": "", "startDay": ""};
    }
  } catch (e) {
    print("❌ Firestore のデータ取得中に例外が発生しました: $e");
  }

  return infoList;
}

Future<Map<String, List<Map<String, dynamic>>>> fetchBestRecords(
    String deviceId) async {
  final docSnapshot = await FirebaseFirestore.instance
      .collection(deviceId)
      .doc("profile")
      .get();

  final data = docSnapshot.data();

  if (data == null || data['bestRecords'] == null) {
    // データがない場合、空の構造を返す
    return {
      '胸': [],
      '背中': [],
      '脚': [],
      '腕': [],
      '腹筋': [],
    };
  }

  final rawBestRecords = data['bestRecords'] as Map<String, dynamic>;

  final result = <String, List<Map<String, dynamic>>>{};

  for (final part in rawBestRecords.keys) {
    final partData = rawBestRecords[part];
    if (partData is Map) {
      // Map形式で保存されていた場合、リストに変換
      final list = partData.values.map<Map<String, dynamic>>((e) {
        return Map<String, dynamic>.from(e);
      }).toList();
      result[part] = list;
    } else if (partData is List) {
      // すでにList形式ならそのまま
      result[part] = List<Map<String, dynamic>>.from(partData);
    } else {
      result[part] = [];
    }
  }

  // 部位がなければ空配列にしておく（安全対策）
  for (var part in ['胸', '背中', '脚', '上腕二頭筋', '上腕三頭筋', '腹筋']) {
    result.putIfAbsent(part, () => []);
  }

  return result;
}
