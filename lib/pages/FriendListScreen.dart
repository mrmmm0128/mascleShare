import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:muscle_share/methods/AddFriendMethod.dart';
import 'package:muscle_share/methods/GetDeviceId.dart';
import 'package:muscle_share/pages/ConfirmOtherProfile.dart';
import 'package:muscle_share/pages/FIndBroScreen.dart';
import 'package:muscle_share/pages/otherProfile.dart';

class FriendListScreen extends StatefulWidget {
  @override
  _FriendListScreenState createState() => _FriendListScreenState();
}

class _FriendListScreenState extends State<FriendListScreen> {
  List<String> deviceIds = [];
  List<String> requestDeviceIds = [];
  List<Map<String, String>> friendLists = [];
  bool _isLoading = true;
  List<Map<String, dynamic>> friendRequests = [];
  String deviceId = "";

  @override
  void initState() {
    super.initState();
    fetchFriendList();
    fetchRequestList();
  }

  Future<void> fetchFriendList() async {
    try {
      deviceId = await getDeviceIDweb();
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
      });
    } catch (e) {
      print("エラー: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> fetchRequestList() async {
    try {
      String deviceId = await getDeviceIDweb();
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection(deviceId)
          .doc("profile")
          .get();

      if (snapshot.exists) {
        var data = snapshot.data() as Map<String, dynamic>;
        if (data.containsKey('requested')) {
          requestDeviceIds = List<String>.from(data['requested']);
        }
      }

      for (String id in requestDeviceIds) {
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection(id)
            .doc("profile")
            .get();

        if (snapshot.exists) {
          Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
          friendRequests.add({
            "name": data["name"] ?? "No Name",
            "url": data["photo"] ?? "", // 空文字で安全
            "deviceId": id,
          });
        }
      }
      print(friendRequests);

      setState(() {
        friendRequests;
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
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Color.fromARGB(255, 209, 209, 0)),
        title: Center(
          child: Text(
            '友達リスト',
            style: TextStyle(
                color: Color.fromARGB(255, 209, 209, 0),
                fontWeight: FontWeight.bold),
          ),
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
                // 例：_FriendListState の中
                if (friendRequests.isNotEmpty)
                  ...friendRequests.map((request) {
                    return Card(
                      key: ValueKey(request["deviceId"]),
                      color: Colors.grey[850],
                      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => confirmOtherProfileScreen(
                                deviceId: request["deviceId"],
                              ),
                            ),
                          );
                        },
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey,
                          backgroundImage: request['url'] != null &&
                                  request['url']!.isNotEmpty
                              ? NetworkImage(request['url']!)
                              : null,
                          child:
                              request['url'] == null || request['url']!.isEmpty
                                  ? Icon(Icons.person, color: Colors.white)
                                  : null,
                        ),
                        title: Text(
                          request['name'] ?? 'Unknown',
                          style: TextStyle(
                            color: Color.fromARGB(255, 209, 209, 0),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.check, color: Colors.green),
                              onPressed: () async {
                                await addFriend(request["deviceId"], deviceId);
                                setState(() {
                                  friendRequests.remove(request);
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('${request['name']} と友達になりました')),
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: Colors.red),
                              onPressed: () async {
                                await cancelFriend(
                                    request["deviceId"], deviceId);
                                setState(() {
                                  friendRequests.remove(request);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),

                // 友達リスト本体
                if (friendLists.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'broを探しましょう',
                        style: TextStyle(
                          color: Color.fromARGB(255, 209, 209, 0),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                if (friendLists.isNotEmpty)
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
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon:
                                    Icon(Icons.delete, color: Colors.redAccent),
                                tooltip: "友達を削除",
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      backgroundColor: Colors.grey[900],
                                      title: Text("友達を削除しますか？",
                                          style:
                                              TextStyle(color: Colors.white)),
                                      content: Text(
                                        "この操作は元に戻せません。",
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                      actions: [
                                        TextButton(
                                          child: Text("キャンセル",
                                              style: TextStyle(
                                                  color: Colors.grey)),
                                          onPressed: () =>
                                              Navigator.of(context).pop(false),
                                        ),
                                        TextButton(
                                          child: Text("削除",
                                              style: TextStyle(
                                                  color: Colors.redAccent)),
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true) {
                                    await deleteFriend(
                                        friend['deviceId']!, deviceId);

                                    setState(() {
                                      friendLists.removeAt(index); // UIから削除
                                    });

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text("${friend['name']} を削除しました"),
                                        backgroundColor: Colors.redAccent,
                                      ),
                                    );
                                  }
                                },
                              ),
                              Icon(Icons.chevron_right, color: Colors.white),
                            ],
                          ),
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
      floatingActionButton: TextButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FindBroScreen()),
          );
        },
        icon: Icon(Icons.person, color: Colors.yellowAccent),
        label: Text(
          'bro探索',
          style: TextStyle(
            color: Color.fromARGB(255, 209, 209, 0),
            fontWeight: FontWeight.bold,
          ),
        ),
        style: TextButton.styleFrom(
          side: BorderSide(
            color: Colors.yellowAccent, // ✅ 枠線の色
            width: 2, // ✅ 枠線の太さ（お好みで）
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // ✅ 角の丸み
          ),
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
      ),
    );
  }
}
