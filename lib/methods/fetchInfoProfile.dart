import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:muscle_share/methods/getDeviceId.dart';

Future<Map<String, String>> fetchInfo() async {
  String deviceId = getDeviceIDweb();
  Map<String, String> infoList = {};

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
          "bench": data["bench"]?.toString() ?? "",
          "dead": data["dead"]?.toString() ?? "",
          "squat": data["squat"]?.toString() ?? "",
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

Future<Map<String, String>> fetchOtherInfo(String deviceId) async {
  Map<String, String> infoList = {};

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
          "bench": data["bench"]?.toString() ?? "",
          "dead": data["dead"]?.toString() ?? "",
          "squat": data["squat"]?.toString() ?? "",
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
