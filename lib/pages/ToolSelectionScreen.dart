import 'package:flutter/material.dart';
import 'package:muscle_share/methods/getDeviceId.dart';
import 'package:muscle_share/pages/FriendTrainingCard.dart';
import 'package:muscle_share/pages/QuickInputScreen.dart';
import 'package:muscle_share/pages/RmCalculator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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

    // 友達のトレーニングデータを取得する
    String dateKey = DateFormat('yyyy-MM-dd').format(DateTime.now()); // 今日の日付
    myDeviceId = await getDeviceIDweb(); // 自分のデバイスIDを取得

    try {
      // 友達のトレーニングデータを取得
      await fetchFriendsTrainingRecords(dateKey, myDeviceId);
    } catch (e) {
      print("エラー: $e");
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> fetchFriendsTrainingRecords(
      String dateKey, String myDeviceId) async {
    try {
      // 友達リストを取得
      DocumentSnapshot profileSnapshot = await FirebaseFirestore.instance
          .collection(myDeviceId)
          .doc("profile")
          .get();

      if (profileSnapshot.exists) {
        var profileData = profileSnapshot.data() as Map<String, dynamic>;

        // 'friendDeviceId' が null でないことを確認し、nullの場合は空リストを使用
        friendDeviceIds =
            List<String>.from(profileData['friendDeviceId'] ?? []);
        print(friendDeviceIds);

        // 今日のトレーニングデータを取得
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection("date$dateKey")
            .doc("recording")
            .get();

        if (snapshot.exists) {
          var data = snapshot.data() as Map<String, dynamic>;

          // 新しい形式でのトレーニングデータを取得
          List<Map<String, dynamic>> allTrainings = [];

          // すべてのトレーニングデータを取り出し
          data.forEach((key, value) {
            if (value is Map<String, dynamic>) {
              allTrainings.add(value);
            }
          });
          print(allTrainings);

          // 友達のトレーニングデータをフィルタリング
          List<Map<String, dynamic>> filteredTrainings = [];

          for (var training in allTrainings) {
            String deviceId = training['deviceId'];
            print(deviceId);

            // 友達のデータのみ追加
            if (friendDeviceIds.contains(deviceId)) {
              filteredTrainings.add(training);
              friend.add(deviceId);
            }
          }
          print(filteredTrainings);

          // フィルタリングした友達のトレーニングデータをリストに保存
          setState(() {
            friendsTrainings = filteredTrainings;
          });
        } else {
          print("その日のトレーニングデータが存在しません");
        }
      } else {
        print("プロフィールが見つかりません");
      }
    } catch (e) {
      print("エラー: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // 背景を黒に
      appBar: AppBar(
        backgroundColor: Colors.black, // AppBarの背景も黒
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color.fromARGB(255, 209, 209, 0)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tool for recording',
          style: TextStyle(
              color: Color.fromARGB(255, 209, 209, 0),
              fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: ToolSelectionRow(), // ToolSelectionRowを表示
            ),
          ),

          Divider(color: Colors.yellowAccent),
          Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              "Trainig of your friend today",
              style: TextStyle(
                  color: Color.fromARGB(255, 209, 209, 0), fontSize: 20),
            ),
          ),

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
                            'Friend have not do training yet today',
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
                            training:
                                training, // トレーニングデータ（templateName, totalVolume など）
                            friendDeviceId: friend[index], // 友達のデバイスID
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class ToolSelectionRow extends StatelessWidget {
  const ToolSelectionRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ToolCard(
          icon: Icons.calculate,
          label: 'RM',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => RmCalculator()), // 作成済みWidget
            );
          },
        ),
        _ToolCard(
          icon: Icons.fitness_center,
          label: 'Quick recording',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => QuickInputScreen()), // あなたの記録画面Widget
            );
          },
        ),
      ],
    );
  }
}

class _ToolCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ToolCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.42,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: Color.fromARGB(255, 209, 209, 0), width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Color.fromARGB(255, 209, 209, 0), size: 36),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
