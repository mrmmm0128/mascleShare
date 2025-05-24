import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> addFrend(String friendDeviceId, String myDeviceId) async {
  List<String> friendDeviceIds = [];

  DocumentSnapshot snapshot = await FirebaseFirestore.instance
      .collection(myDeviceId)
      .doc("profile")
      .get();

  if (snapshot.exists) {
    // フィールド "friendDeviceId" が存在するか確認
    if (snapshot.data() != null &&
        (snapshot.data() as Map<String, dynamic>)
            .containsKey('friendDeviceId')) {
      // フィールドが存在する場合はリストとして取得
      friendDeviceIds = List<String>.from(snapshot['friendDeviceId']);
    }
  } else {
    print("ドキュメントが存在しません");
    // 初回なら空の配列 friendDeviceIds を使えばOK
  }

  // 重複追加を避けたい場合はチェック
  if (!friendDeviceIds.contains(friendDeviceId)) {
    friendDeviceIds.add(friendDeviceId);
  }

  await FirebaseFirestore.instance
      .collection(myDeviceId)
      .doc("profile")
      .set({"friendDeviceId": friendDeviceIds}, SetOptions(merge: true));
}
