import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

Future<List<Map<String, Map<String, dynamic>>>> fetchTodayphoto() async {
  List<Map<String, Map<String, dynamic>>> photoList = [];
  String dateKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
  print(dateKey);
  try {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection("date$dateKey")
        .doc("memory")
        .get();

    if (snapshot.exists) {
      Map<String, dynamic>? data =
          await snapshot.data() as Map<String, dynamic>?;

      if (data != null) {
        for (var entry in data.entries) {
          if (entry.value is Map<String, dynamic> &&
              entry.value.containsKey("photo")) {
            photoList.add({
              entry.key: {
                "url": entry.value["photo"],
                "caption": entry.value["caption"],
                "mascle": entry.value["mascle"] ?? "",
                "icon": entry.value["icon"] ?? "",
                "name": entry.value["name"] ?? "",
                "deviceId": entry.value["deviceId"],
                "isPrivate": entry.value["stringisPrivate"],
                "like": entry.value["like"] ?? [],
                "comment": entry.value["comment"] ?? []
              }
            });
          }
        }
      }
    }
  } catch (e) {
    print("❌ Firestore のデータ取得に失敗しました: $e");
  }

  return photoList;
}
