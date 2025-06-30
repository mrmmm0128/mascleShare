import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:muscle_share/methods/FetchInfoProfile.dart';

class AddCommentLike {
  static void editLike(
      String deviceId, List<String> likeDeviceIds, String unique) async {
    String dateKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final docRef = FirebaseFirestore.instance
        .collection("date$dateKey") // or your collection like: "date2025-06-08"
        .doc('memory');

    if (likeDeviceIds.contains(deviceId)) {
      // すでに含まれていれば「いいね解除」
      await docRef.update({
        '$unique.like': FieldValue.arrayRemove([deviceId])
      });
    } else {
      // 含まれていなければ「いいね追加」
      await docRef.update({
        '$unique.like': FieldValue.arrayUnion([deviceId])
      });
    }
  }

  static Future<void> addComment(String unique, String comment) async {
    Map<String, dynamic> infoList = await fetchInfo();
    String url = infoList["url"];
    String name = infoList["name"];

    String dateKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final docRef = FirebaseFirestore.instance
        .collection("date$dateKey") // or your collection like: "date2025-06-08"
        .doc('memory');

    await docRef.update({
      '$unique.comment': FieldValue.arrayUnion([
        {"name": name, "url": url, "comment": comment}
      ])
    });
  }

  static Future<List<Map<String, String>>> fetchComment(String unique) async {
    String dateKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final docRef =
        FirebaseFirestore.instance.collection("date$dateKey").doc('memory');

    List<Map<String, String>> commentList = [];

    try {
      final docSnapshot = await docRef.get();
      final data = docSnapshot.data();

      if (data != null && data[unique]?['comment'] is List) {
        List<dynamic> rawComments = data[unique]['comment'];

        for (var comment in rawComments) {
          if (comment is Map<String, dynamic>) {
            commentList.add({
              'name': comment['name'] ?? '',
              'url': comment['url'] ?? '',
              'comment': comment['comment'] ?? '',
            });
          }
        }
      }
    } catch (e) {
      print("❌ コメント取得失敗: $e");
    }

    return commentList;
  }
}
