import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:muscle_share/methods/getDeviceId.dart';

Future<List<Map<String, String>>> fetchHistory() async {
  String deviceId = getDeviceIDweb();
  List<Map<String, String>> historyList = [];

  try {
    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection(deviceId).doc("info").get();

    if (snapshot.exists) {
      Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
      if (data != null) {
        for (var entry in data.entries) {
          var value = entry.value;
          if (value is Map<String, dynamic> && value.containsKey("photo")) {
            historyList.add({
              "url": value["photo"],
              "mascle": value["mascle"]?.toString() ?? "",
              "day": value["day"]
            });
          }
        }
      }
    } else {
      return [
        {"url": "", "name": "", "startDay": ""}
      ];
    }
  } catch (e) {
    print("❌ Firestore のデータ取得中に例外が発生しました: $e");
  }

  return historyList;
}
