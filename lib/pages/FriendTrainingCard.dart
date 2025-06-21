import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:muscle_share/pages/FriendTrainingDetailScreen.dart';

class FriendTrainingCard extends StatelessWidget {
  final Map<String, dynamic> training;
  final String friendDeviceId;

  const FriendTrainingCard({
    Key? key,
    required this.training,
    required this.friendDeviceId,
  }) : super(key: key);

  // 友達の情報を非同期に取得する関数
  Future<Map<String, dynamic>> fetchOtherInfo(String deviceId) async {
    Map<String, dynamic> infoList = {};

    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection(deviceId)
          .doc("profile")
          .get();

      if (snapshot.exists) {
        Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
        if (data != null) {
          infoList = {
            "url": data["photo"]?.toString() ?? "", // デフォルト空文字にする
            "name": data["name"]?.toString() ?? "Unknown", // 名前が無ければ "Unknown"
            "startDay": data["startDay"]?.toString() ?? "", // startDay がない場合空文字
            "height": data["height"] ?? 0, // 身長がない場合 0
            "weight": data["weight"] ?? 0, // 体重がない場合 0
            "requested": data["requested"] ?? [""], // requested がない場合空リスト
          };
        }
      } else {
        return {
          "url": "",
          "name": "Unknown",
          "startDay": ""
        }; // プロフィールが存在しない場合のデフォルト値
      }
    } catch (e) {
      print("❌ Firestore のデータ取得中に例外が発生しました: $e");
      return {"url": "", "name": "Unknown", "startDay": ""}; // エラー時もデフォルト値を返す
    }

    return infoList;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: fetchOtherInfo(friendDeviceId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: CircularProgressIndicator(color: Colors.yellowAccent));
        }

        if (snapshot.hasError) {
          return Center(
              child: Text('エラーが発生しました', style: TextStyle(color: Colors.white)));
        }

        final friendData = snapshot.data ?? {"url": "", "name": "Unknown"};

        print(training);

        // friendDataがnullの場合やnameが空の場合の処理
        String name = friendData['name'] ?? "Unknown";
        String photoUrl = friendData['url'] ?? "";
        String templateName = training["name"] ?? "Unknown Template";
        double totalVolume = 0.0;

        Map<String, dynamic> exerciseMap = training["training"] ?? {};
        exerciseMap.forEach((exerciseName, sets) {
          for (var set in sets) {
            final weight = (set["weight"] ?? 0).toDouble();
            final reps = (set["reps"] ?? 0).toDouble();
            totalVolume += weight * reps;
          }
        });

        return Padding(
          padding: EdgeInsets.all(16),
          child: InkWell(
            onTap: () {
              // training Map に必要な情報を追加して画面遷移
              Map<String, dynamic> enrichedTraining =
                  Map<String, dynamic>.from(training)
                    ..["templateName"] = templateName
                    ..["totalVolume"] =
                        totalVolume.toStringAsFixed(2); // 画面側で文字列扱いに

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FriendTrainingDetailScreen(
                    training: enrichedTraining,
                    friendDeviceId: friendDeviceId,
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            splashColor: Colors.yellowAccent.withOpacity(0.3),
            child: Card(
              color: Colors.grey[900],
              margin: EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 5,
              child: Column(
                children: [
                  ListTile(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundImage:
                          photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                      child: photoUrl.isEmpty
                          ? Icon(Icons.person, color: Colors.black)
                          : null,
                      backgroundColor: Colors.yellowAccent,
                      radius: 24,
                    ),
                    title: Text(
                      name,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      "トレーニング種目: $templateName",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    trailing: Icon(Icons.fitness_center,
                        color: Colors.white, size: 24),
                  ),
                  Divider(color: Colors.yellowAccent),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Text(
                      "総ボリューム: ${totalVolume.toStringAsFixed(2)} kg·回",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
