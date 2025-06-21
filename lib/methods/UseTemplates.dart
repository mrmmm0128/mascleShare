import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class UseTemplates {
  static Future<void> saveTemplate(
      String deviceId, String nameTemplate, List<String> template) async {
    await FirebaseFirestore.instance
        .collection(deviceId)
        .doc(nameTemplate)
        .set({"template": List<String>.from(template)});
  }

  static Future<List<Map<String, dynamic>>> fetchTemplate(
      String deviceId) async {
    final templateDocs =
        await FirebaseFirestore.instance.collection(deviceId).get();

    List<Map<String, dynamic>> templates = [];

    for (final doc in templateDocs.docs) {
      if (doc.id == 'profile' || doc.id == 'info' || doc.id == 'history')
        continue;

      final data = doc.data();
      final exercises = List<String>.from(data['template'] ?? []);

      templates.add({
        "name": doc.id,
        "exercises": exercises,
      });
    }

    return templates;
  }

  static Future<void> deleteTemplate(
      String deviceId, String templateName) async {
    final templateRef = FirebaseFirestore.instance
        .collection(deviceId) // Firestoreの適切なコレクション名に置き換えてください
        .doc(templateName);

    await templateRef.delete();
  }

  static Future<void> saveTraining(String deviceId, String nameTemplate,
      Map<String, List<Map<String, int>>> template) async {
    String dateKey = DateFormat('yyyy-MM-dd').format(DateTime.now());

    await FirebaseFirestore.instance
        .collection(deviceId)
        .doc(nameTemplate)
        .set({"$dateKey $nameTemplate": template}, SetOptions(merge: true));

    await FirebaseFirestore.instance
        .collection(deviceId)
        .doc("history")
        .set({"$dateKey $nameTemplate": template}, SetOptions(merge: true));

    await FirebaseFirestore.instance.collection(deviceId).doc("history").set({
      dateKey: {"name": nameTemplate}
    }, SetOptions(merge: true));

    await FirebaseFirestore.instance
        .collection("date$dateKey")
        .doc("recording")
        .set({
      "$deviceId$nameTemplate": {
        "deviceId": deviceId,
        "name": nameTemplate,
        "training": template
      }
    }, SetOptions(merge: true));
  }

  static Future<Map<String, dynamic>> fetchHistory(String deviceId) async {
    final doc = await FirebaseFirestore.instance
        .collection(deviceId)
        .doc("history")
        .get();

    if (!doc.exists) return {}; // データが存在しない場合は空のマップを返す

    Map<String, dynamic> historyData = doc.data() ?? {};

    // 各日付のデータを整理し、総ボリュームを計算する
    historyData.forEach((date, data) {
      double totalVolume = 0.0;
      String templateName = "";

      if (data is Map<String, dynamic>) {
        // テンプレート名を取得
        templateName = data["name"] ?? "";

        // 各種目に対してボリュームを計算
        data.forEach((key, value) {
          if (key != "name" && value is List<dynamic>) {
            value.forEach((set) {
              final weight = set['weight'] ?? 0;
              final reps = set['reps'] ?? 0;
              totalVolume += weight * reps; // 総ボリュームを加算
            });
          }
        });
      }

      // 日付ごとにテンプレート名と総ボリュームを追加
      historyData[date] = {
        "name": templateName,
        "totalVolume": totalVolume,
        "data": data, // 元のデータも保持しておく
      };
    });

    return historyData;
  }

  // static Future<void> fetchTraining(
  //     String deviceId, String nameTemplate) async {
  //   String dateKey = DateFormat('yyyy-MM-dd').format(DateTime.now());

  //   final docRef = await FirebaseFirestore.instance
  //       .collection(deviceId)
  //       .doc(nameTemplate)
  //       .get();
  // }

  static Future<List<Map<String, dynamic>>> fetchFriendsTrainingRecords(
      String dateKey, String myDeviceId) async {
    try {
      // 友達リストを取得
      DocumentSnapshot profileSnapshot = await FirebaseFirestore.instance
          .collection(myDeviceId)
          .doc("profile")
          .get();

      if (profileSnapshot.exists) {
        var profileData = profileSnapshot.data() as Map<String, dynamic>;

        List<String> friendDeviceIds =
            List<String>.from(profileData['friendDeviceId'] ?? []);

        // 今日のトレーニングデータを取得
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection("date$dateKey")
            .doc("recording")
            .get();

        if (snapshot.exists) {
          var data = snapshot.data() as Map<String, dynamic>;
          var allTrainings = data['training'] ?? [];

          // 友達のトレーニングデータをフィルタリング
          List<Map<String, dynamic>> friendsTrainings = [];

          for (var training in allTrainings) {
            String deviceId = training['deviceId'];

            // 友達のデータのみ追加
            if (friendDeviceIds.contains(deviceId)) {
              friendsTrainings.add(training);
            }
          }

          // 友達のトレーニングデータ
          print('友達のトレーニングデータ: $friendsTrainings');

          return friendsTrainings;
        } else {
          print("その日のトレーニングデータが存在しません");
          List<Map<String, dynamic>> friendsTrainings = [
            {"name": ""}
          ];
          return friendsTrainings;
        }
      } else {
        print("プロフィールが見つかりません");
        List<Map<String, dynamic>> friendsTrainings = [
          {"name": ""}
        ];
        return friendsTrainings;
      }
    } catch (e) {
      print("エラー: $e");
      List<Map<String, dynamic>> friendsTrainings = [
        {"name": ""}
      ];
      return friendsTrainings;
    }
  }
}
