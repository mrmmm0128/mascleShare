import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:muscle_share/methods/FetchInfoProfile.dart';
import 'package:muscle_share/methods/getDeviceId.dart';

class AddCommentLike {
  static void editLike(String mydeviceId, List<String> likeDeviceIds,
      String date, String friendDeviceId) async {
    final docRef =
        FirebaseFirestore.instance.collection(friendDeviceId).doc('history');

    if (likeDeviceIds.contains(mydeviceId)) {
      // すでに含まれていれば「いいね解除」
      await docRef.update({
        '$date.like': FieldValue.arrayRemove([mydeviceId])
      });
    } else {
      // 含まれていなければ「いいね追加」
      await docRef.update({
        '$date.like': FieldValue.arrayUnion([mydeviceId])
      });
    }
  }

  static Future<void> addComment(
    String deviceId,
    String date,
    String comment,
  ) async {
    String mydeviceId = await getDeviceUUID();
    try {
      Map<String, dynamic> infoList = await fetchInfo();
      String url = infoList["url"];
      String name = infoList["name"];

      final docRef =
          FirebaseFirestore.instance.collection(deviceId).doc('history');

      await docRef.update({
        '$date.comment': FieldValue.arrayUnion([
          {"name": name, "url": url, "comment": comment, "deviceId": mydeviceId}
        ])
      });
    } catch (e, stackTrace) {
      print("❌ コメント追加時にエラーが発生しました: $e");
      print(stackTrace);
      rethrow; // 呼び出し元でもハンドリングできるように再スロー
    }
  }

  static Future<List<Map<String, String>>> fetchComment(
      String deviceId, String date) async {
    final docRef =
        FirebaseFirestore.instance.collection(deviceId).doc('history');

    List<Map<String, String>> commentList = [];

    try {
      final docSnapshot = await docRef.get();
      final data = docSnapshot.data();

      final entry = data?[date];

      if (entry is Map<String, dynamic> &&
          entry['comment'] is List &&
          entry["comment"] != null) {
        List<dynamic> rawComments = entry['comment'];

        for (var comment in rawComments) {
          if (comment is Map<String, dynamic>) {
            commentList.add({
              'name': comment['name'] ?? '',
              'url': comment['url'] ?? '',
              'comment': comment['comment'] ?? '',
            });
          }
        }
      } else {}
    } catch (e) {
      print("❌ コメント取得失敗: $e");
    }

    return commentList;
  }

  static Future<List<String>> fetchLike(String deviceId, String date) async {
    final docRef =
        FirebaseFirestore.instance.collection(deviceId).doc('history');

    List<String> rawLikes = [];

    try {
      final docSnapshot = await docRef.get();
      final data = docSnapshot.data();

      final entry = data?[date];

      if (entry is Map<String, dynamic> && entry['like'] is List) {
        // 明示的に String 型として cast
        rawLikes = List<String>.from(entry['like']);
      }
    } catch (e) {
      print("❌ いいね取得失敗: $e");
    }

    return rawLikes;
  }
}
