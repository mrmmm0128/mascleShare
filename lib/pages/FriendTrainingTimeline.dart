import 'package:flutter/material.dart';
import 'package:muscle_share/methods/getDeviceId.dart';
import 'package:muscle_share/pages/FriendTrainingCard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:muscle_share/pages/Header.dart';

class ToolSelectionScreen extends StatefulWidget {
  const ToolSelectionScreen({super.key});

  @override
  _ToolSelectionScreenState createState() => _ToolSelectionScreenState();
}

class _ToolSelectionScreenState extends State<ToolSelectionScreen> {
  List<Map<String, dynamic>> friendsTrainings = [];
  bool _isLoading = true;
  String myDeviceId = "";
  List<String> friendDeviceIds = [];
  List<String> friend = [];

  @override
  void initState() {
    super.initState();
    _fetchFriendsTrainingRecords();
  }

  Future<void> _fetchFriendsTrainingRecords() async {
    setState(() {
      _isLoading = true;
    });

    myDeviceId = await getDeviceIDweb(); // 自分のデバイスIDを取得

    try {
      // 友達のトレーニングデータを取得
      await fetchFriendsTrainingRecords(myDeviceId);
    } catch (e) {
      print("エラー: $e");
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> fetchFriendsTrainingRecords(String myDeviceId) async {
    try {
      // 1. 自分のfriendDeviceIdリストを取得
      DocumentSnapshot profileSnapshot = await FirebaseFirestore.instance
          .collection(myDeviceId)
          .doc("profile")
          .get();

      if (!profileSnapshot.exists) return;

      final profileData = profileSnapshot.data() as Map<String, dynamic>;
      final List<String> friendDeviceIds =
          List<String>.from(profileData['friendDeviceId'] ?? []);

      List<Map<String, dynamic>> allFriendsHistories = [];

      friendDeviceIds.add(myDeviceId);

      for (String friendId in friendDeviceIds) {
        DocumentSnapshot historyDoc = await FirebaseFirestore.instance
            .collection(friendId)
            .doc("history")
            .get();

        if (historyDoc.exists) {
          Map<String, dynamic> historyData =
              historyDoc.data() as Map<String, dynamic>;

          // 各日付に対してボリュームなど計算しながら保存
          historyData.forEach((date, data) {
            if (data is Map<String, dynamic>) {
              double totalVolume = 0.0;
              String name = data["name"] ?? "";
              bool isPublic = data["isPublic"] ?? false;
              if (isPublic) {
                data.forEach((key, value) {
                  if (key != "name" &&
                      value is List &&
                      key != "like" &&
                      key != "comment" &&
                      key != "isPublic") {
                    for (var set in value) {
                      totalVolume += (set["weight"] ?? 0) * (set["reps"] ?? 0);
                    }
                  }
                });

                allFriendsHistories.add({
                  "deviceId": friendId,
                  "date": date,
                  "name": name,
                  "totalVolume": totalVolume,
                  "data": data,
                });
              }
            }
            print(allFriendsHistories);
          });
        }
      }

      // 🔽 日付の降順でソート
      allFriendsHistories.sort((a, b) => b["date"].compareTo(a["date"]));

      // 保存して表示用に
      setState(() {
        friendsTrainings = allFriendsHistories;
      });
    } catch (e) {
      print("エラー: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // 背景を黒に
      appBar: Header(
        title: 'タイムライン',
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // 🔽 友達のトレーニング記録を表示するカードリスト
          Expanded(
            child: _isLoading
                ? Center(
                    child:
                        CircularProgressIndicator(color: Colors.yellowAccent))
                : friendsTrainings.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'あなたのbroはまだトレーニングしていません',
                            style: TextStyle(
                              color: Color.fromARGB(255, 209, 209, 0),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: friendsTrainings.length,
                        itemBuilder: (context, index) {
                          final training = friendsTrainings[index];
                          return FriendTrainingCard(
                            training: training,
                            friendDeviceId: training["deviceId"], // ✅ ここを修正
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
