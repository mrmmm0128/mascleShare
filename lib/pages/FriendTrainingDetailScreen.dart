import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FriendTrainingDetailScreen extends StatelessWidget {
  final Map<String, dynamic> training;
  final String friendDeviceId;

  const FriendTrainingDetailScreen({
    Key? key,
    required this.training,
    required this.friendDeviceId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String templateName = training['templateName'] ?? 'Unknown Template';
    final String totalVolume = training['totalVolume'] ?? '0.0';
    final Map<String, dynamic> exercises =
        Map<String, dynamic>.from(training['training'] ?? {});

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "Friend's Training Details",
          style: TextStyle(color: Colors.yellowAccent),
        ),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.yellowAccent),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<Map<String, dynamic>>(
          future: fetchOtherInfo(friendDeviceId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text("エラーが発生しました"));
            }

            final friendData = snapshot.data;

            return ListView(
              children: [
                // プロフィール
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        backgroundImage: friendData?['url'] != ""
                            ? NetworkImage(friendData?['url'])
                            : null,
                        child: friendData?['url'] == null
                            ? Icon(Icons.person, color: Colors.black)
                            : null,
                        backgroundColor: Colors.yellowAccent,
                        radius: 50,
                      ),
                      SizedBox(height: 16),
                      Text(
                        friendData?['name'] ?? "Unknown",
                        style: TextStyle(
                            color: Colors.yellowAccent,
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Start Day: ${friendData?['startDay'] ?? 'Not Available'}",
                        style: TextStyle(color: Colors.white70),
                      ),
                      Text(
                        "Height: ${friendData?['height']} cm",
                        style: TextStyle(color: Colors.white70),
                      ),
                      Text(
                        "Weight: ${friendData?['weight']} kg",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                Divider(color: Colors.yellowAccent),
                SizedBox(height: 16),

                // トレーニング概要
                Text(
                  "Training Template: $templateName",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                SizedBox(height: 8),
                Text(
                  "Total Volume: $totalVolume kg·回",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                Divider(color: Colors.yellowAccent),
                SizedBox(height: 12),

                // 種目ごとの詳細
                ...exercises.entries.map((entry) {
                  final exerciseName = entry.key;
                  final sets = List<Map<String, dynamic>>.from(entry.value);

                  return Card(
                    color: Colors.grey[900],
                    margin: EdgeInsets.only(bottom: 20),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exerciseName,
                            style: TextStyle(
                              color: Colors.yellowAccent,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          ...sets.asMap().entries.map((setEntry) {
                            final index = setEntry.key;
                            final set = setEntry.value;
                            final weight = set["weight"] ?? 0;
                            final reps = set["reps"] ?? 0;

                            return Container(
                              margin: EdgeInsets.only(bottom: 10),
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[800],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "${index + 1}セット目: ${weight}kg × ${reps}回",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            );
          },
        ),
      ),
    );
  }

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
            "url": data["photo"]?.toString() ?? "",
            "name": data["name"]?.toString() ?? "",
            "startDay": data["startDay"]?.toString() ?? "",
            "height": data["height"] ?? 0,
            "weight": data["weight"] ?? 0,
            "requested": data["requested"] ?? [""],
          };
        }
      } else {
        return {"url": "", "name": "", "startDay": ""};
      }
    } catch (e) {
      print("❌ Firestore のデータ取得中に例外が発生しました: $e");
    }

    return infoList;
  }
}
