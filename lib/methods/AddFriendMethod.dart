import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> addFriend(String friendDeviceId, String myDeviceId) async {
  List<String> myFriendLists = [];
  List<String> yourFriendLists = [];
  List<String> sentFriendRequests = [];
  List<String> receivedFriendRequests = [];

  try {
    // 友達のプロフィール取得
    final friendProfileSnapshot = await FirebaseFirestore.instance
        .collection(friendDeviceId)
        .doc("profile")
        .get();

    if (friendProfileSnapshot.exists) {
      final data = friendProfileSnapshot.data() as Map<String, dynamic>;

      if (data["friendDeviceId"] != null && data["friendDeviceId"] is List) {
        yourFriendLists = List<String>.from(data["friendDeviceId"]);
      }

      if (data["request"] != null && data["request"] is List) {
        sentFriendRequests = List<String>.from(data["request"]);
      }
    }

    // 自分のプロフィール取得
    final myProfileSnapshot = await FirebaseFirestore.instance
        .collection(myDeviceId)
        .doc("profile")
        .get();

    if (myProfileSnapshot.exists) {
      final data = myProfileSnapshot.data() as Map<String, dynamic>;

      if (data["friendDeviceId"] != null && data["friendDeviceId"] is List) {
        myFriendLists = List<String>.from(data["friendDeviceId"]);
      }

      if (data["requested"] != null && data["requested"] is List) {
        receivedFriendRequests = List<String>.from(data["requested"]);
      }
    }

    // リクエストのクリーンアップ処理
    if (sentFriendRequests.contains(myDeviceId)) {
      sentFriendRequests.remove(myDeviceId);
      await FirebaseFirestore.instance
          .collection(friendDeviceId)
          .doc("profile")
          .set({"request": sentFriendRequests}, SetOptions(merge: true));
    }

    if (receivedFriendRequests.contains(friendDeviceId)) {
      receivedFriendRequests.remove(friendDeviceId);
      await FirebaseFirestore.instance
          .collection(myDeviceId)
          .doc("profile")
          .set({"requested": receivedFriendRequests}, SetOptions(merge: true));
    }

    // 友達リストへの追加
    if (!myFriendLists.contains(friendDeviceId)) {
      myFriendLists.add(friendDeviceId);
      await FirebaseFirestore.instance
          .collection(myDeviceId)
          .doc("profile")
          .set({"friendDeviceId": myFriendLists}, SetOptions(merge: true));
      print("✅ 自分の友達リストに追加しました: $friendDeviceId");
    }

    if (!yourFriendLists.contains(myDeviceId)) {
      yourFriendLists.add(myDeviceId);
      await FirebaseFirestore.instance
          .collection(friendDeviceId)
          .doc("profile")
          .set({"friendDeviceId": yourFriendLists}, SetOptions(merge: true));
      print("✅ 相手側の友達リストに追加しました: $myDeviceId");
    }
  } catch (e) {
    print("❌ 友達追加中にエラーが発生しました: $e");
  }
}

Future<void> requestFrend(String friendDeviceId, String myDeviceId) async {
  List<String> friendRequested = [];
  List<String> friendRequest = [];

  DocumentSnapshot snapshot = await FirebaseFirestore.instance
      .collection(friendDeviceId)
      .doc("profile")
      .get();

  DocumentSnapshot snapshotRequest = await FirebaseFirestore.instance
      .collection(myDeviceId)
      .doc("profile")
      .get();

  if (snapshot.exists) {
    // フィールド "friendDeviceId" が存在するか確認
    if (snapshot.data() != null &&
        (snapshot.data() as Map<String, dynamic>).containsKey('requested')) {
      // フィールドが存在する場合はリストとして取得
      friendRequested = List<String>.from(snapshot['requested']);
    }
  } else {
    print("ドキュメントが存在しません");
    // 初回なら空の配列 friendDeviceIds を使えばOK
  }

  if (snapshotRequest.exists) {
    // フィールド "friendDeviceId" が存在するか確認
    if (snapshotRequest.data() != null &&
        (snapshotRequest.data() as Map<String, dynamic>)
            .containsKey('request')) {
      // フィールドが存在する場合はリストとして取得
      friendRequest = List<String>.from(snapshotRequest['request']);
    }
  } else {
    print("ドキュメントが存在しません");
    // 初回なら空の配列 friendDeviceIds を使えばOK
  }

  // 重複追加を避けたい場合はチェック
  if (!friendRequested.contains(myDeviceId)) {
    friendRequested.add(myDeviceId);
  }

  // 重複追加を避けたい場合はチェック
  if (!friendRequest.contains(friendDeviceId)) {
    friendRequest.add(friendDeviceId);
  }

  await FirebaseFirestore.instance
      .collection(myDeviceId)
      .doc("profile")
      .set({"request": friendRequest}, SetOptions(merge: true));

  await FirebaseFirestore.instance
      .collection(friendDeviceId)
      .doc("profile")
      .set({"requested": friendRequested}, SetOptions(merge: true));
}

Future<void> cancelFriend(String friendDeviceId, String myDeviceId) async {
  List<String> friendRequested = [];
  List<String> friendRequest = [];

  try {
    // 相手側の requested リストを取得
    DocumentSnapshot friendSnapshot = await FirebaseFirestore.instance
        .collection(friendDeviceId)
        .doc("profile")
        .get();

    if (friendSnapshot.exists) {
      final data = friendSnapshot.data() as Map<String, dynamic>?;
      if (data != null && data.containsKey('requested')) {
        friendRequested = List<String>.from(data['requested']);
        friendRequested.remove(myDeviceId);
      }
    }

    // 自分側の request リストを取得
    DocumentSnapshot mySnapshot = await FirebaseFirestore.instance
        .collection(myDeviceId)
        .doc("profile")
        .get();

    if (mySnapshot.exists) {
      final data = mySnapshot.data() as Map<String, dynamic>?;
      if (data != null && data.containsKey('request')) {
        friendRequest = List<String>.from(data['request']);
        friendRequest.remove(friendDeviceId);
      }
    }

    // 更新処理
    await FirebaseFirestore.instance
        .collection(myDeviceId)
        .doc("profile")
        .set({"request": friendRequest}, SetOptions(merge: true));

    await FirebaseFirestore.instance
        .collection(friendDeviceId)
        .doc("profile")
        .set({"requested": friendRequested}, SetOptions(merge: true));

    print("✅ 申請キャンセルが完了しました");
  } catch (e) {
    print("❌ cancelFriend エラー: $e");
  }
}

Future<void> deleteFriend(String targetId, String myId) async {
  try {
    final myRef = FirebaseFirestore.instance.collection(myId).doc("profile");
    final targetRef =
        FirebaseFirestore.instance.collection(targetId).doc("profile");

    // 自分のfriendListから相手を削除
    final mySnapshot = await myRef.get();
    if (mySnapshot.exists && mySnapshot.data() != null) {
      final data = mySnapshot.data() as Map<String, dynamic>;
      if (data.containsKey("friendDeviceId")) {
        List<String> myList = List<String>.from(data["friendDeviceId"]);
        myList.remove(targetId);
        await myRef.set({"friendDeviceId": myList}, SetOptions(merge: true));
      }
    }

    // 相手のfriendListから自分を削除
    final targetSnapshot = await targetRef.get();
    if (targetSnapshot.exists && targetSnapshot.data() != null) {
      final data = targetSnapshot.data() as Map<String, dynamic>;
      if (data.containsKey("friendDeviceId")) {
        List<String> targetList = List<String>.from(data["friendDeviceId"]);
        targetList.remove(myId);
        await targetRef
            .set({"friendDeviceId": targetList}, SetOptions(merge: true));
      }
    }

    print("✅ 友達を削除しました");
  } catch (e) {
    print("❌ deleteFriend エラー: $e");
  }
}
