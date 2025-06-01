import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:muscle_share/methods/getDeviceId.dart';
import 'package:muscle_share/pages/otherProfile.dart';

class FriendListScreen extends StatefulWidget {
  @override
  _FriendListScreenState createState() => _FriendListScreenState();
}

class _FriendListScreenState extends State<FriendListScreen> {
  List<String> deviceIds = [];
  List<Map<String, String>> friendLists = [];
  bool _isLoading = true;
  List<Map<String, dynamic>> friendRequests = [];

  @override
  void initState() {
    super.initState();
    fetchFriendList();
  }

  Future<void> fetchFriendList() async {
    try {
      String deviceId = await getDeviceUUID();
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection(deviceId)
          .doc("profile")
          .get();

      if (snapshot.exists) {
        var data = snapshot.data() as Map<String, dynamic>;
        if (data.containsKey('friendDeviceId')) {
          deviceIds = List<String>.from(data['friendDeviceId']);
        }
      }

      List<Map<String, String>> fetchedFriends = [];

      for (String id in deviceIds) {
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection(id)
            .doc("profile")
            .get();

        if (snapshot.exists) {
          Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
          fetchedFriends.add({
            "name": data["name"] ?? "No Name",
            "url": data["photo"] ?? "", // 空文字で安全
            "deviceId": id,
          });
        }
      }

      setState(() {
        friendLists = fetchedFriends;
        _isLoading = false;
      });
    } catch (e) {
      print("エラー: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 209, 209, 0),
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          '友達リスト',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.yellowAccent,
              ),
            )
          : Column(
              children: [
                // 🔽 友達申請通知カード（申請がある場合のみ）
                if (friendRequests.isNotEmpty)
                  Card(
                    color: Colors.grey[900],
                    margin: EdgeInsets.all(12),
                    child: ListTile(
                      leading: Stack(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.yellowAccent,
                            child: Icon(Icons.person_add, color: Colors.black),
                          ),
                          // 🔽 バッジ表示
                          Positioned(
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                friendRequests.length.toString(),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                      title: Text(
                        '友達申請が${friendRequests.length}件あります',
                        style: TextStyle(color: Colors.white),
                      ),
                      trailing: Icon(Icons.chevron_right, color: Colors.white),
                      onTap: () {
                        // 🔽 申請一覧ページなどに遷移
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //       builder: (context) => FriendRequestScreen(
                        //           requests: friendRequests)),
                        // );
                      },
                    ),
                  ),

                // 🔽 友達リスト本体
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: friendLists.length,
                    separatorBuilder: (context, index) =>
                        Divider(color: Colors.grey[700]),
                    itemBuilder: (context, index) {
                      final friend = friendLists[index];
                      return ListTile(
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        leading: CircleAvatar(
                          backgroundImage: friend['url']!.isNotEmpty
                              ? NetworkImage(friend['url']!)
                              : null,
                          backgroundColor: Colors.grey,
                          radius: 24,
                          child: friend['url']!.isEmpty
                              ? Icon(Icons.person, color: Colors.white)
                              : null,
                        ),
                        title: Text(
                          friend['name']! != ""
                              ? friend["name"]!
                              : "Not defined",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        trailing:
                            Icon(Icons.chevron_right, color: Colors.white),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => otherProfileScreen(
                                  deviceId: friend['deviceId']!),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
