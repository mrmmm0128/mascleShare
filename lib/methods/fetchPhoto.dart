import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

Future<List<Map<String, String>>> fetchTodayphoto() async {
  List<Map<String, String>> photoList = [];
  String dateKey = DateFormat('yyyy-MM-dd').format(DateTime.now());

  try {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection(dateKey)
        .doc("memory")
        .get();

    if (snapshot.exists) {
      Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;

      if (data != null) {
        for (var entry in data.entries) {
          if (entry.value is Map<String, dynamic> &&
              entry.value.containsKey("photo")) {
            photoList.add({
              "url": entry.value["photo"],
              "caption": entry.value["caption"],
              "mascle": entry.value["mascle"] ?? "",
              "icon": entry.value["icon"] ?? "",
              "name": entry.value["name"] ?? "",
              "deviceId": entry.value["deviceId"],
            });
          }
          print(entry.value["photo"]);
        }
      }
    }
  } catch (e) {
    print("❌ Firestore のデータ取得に失敗しました: $e");
  }

  return photoList;
}
