import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> deleteUserCollections(String deviceId) async {
  final firestore = FirebaseFirestore.instance;

  // Firestore内の該当コレクションを削除
  final snapshot = await firestore.collection(deviceId).get();
  for (var doc in snapshot.docs) {
    await doc.reference.delete();
  }

  // 必要であれば他の関連コレクションも削除
  // 例: await firestore.collection('users').doc(deviceId).delete();
}

Future<void> removeFromFriendLists(String myDeviceId) async {
  try {
    final myProfileRef =
        FirebaseFirestore.instance.collection(myDeviceId).doc("profile");

    final myProfileSnapshot = await myProfileRef.get();

    if (!myProfileSnapshot.exists) {
      print("⚠️ プロフィールが見つかりません: $myDeviceId");
      return;
    }

    final myData = myProfileSnapshot.data() as Map<String, dynamic>;
    List<String> myFriends = List<String>.from(myData["friendDeviceId"] ?? []);

    // 相手の友達リストから自分を削除
    for (String friendDeviceId in myFriends) {
      final friendProfileRef =
          FirebaseFirestore.instance.collection(friendDeviceId).doc("profile");

      final friendSnapshot = await friendProfileRef.get();

      if (friendSnapshot.exists) {
        final friendData = friendSnapshot.data() ?? {};
        List<String> theirFriends =
            List<String>.from(friendData["friendDeviceId"] ?? []);

        if (theirFriends.contains(myDeviceId)) {
          theirFriends.remove(myDeviceId);
          await friendProfileRef.set(
            {"friendDeviceId": theirFriends},
            SetOptions(merge: true),
          );
          print("✅ $friendDeviceId のリストから $myDeviceId を削除しました");
        }
      }
    }

    // 最後に自分のリストを空にする（またはプロフィール削除されるならこの処理は省略可）
    await myProfileRef.set({"friendDeviceId": []}, SetOptions(merge: true));
    print("✅ 自分の friendDeviceId リストを空にしました");
  } catch (e) {
    print("❌ removeFromFriendLists中にエラーが発生しました: $e");
  }
}
