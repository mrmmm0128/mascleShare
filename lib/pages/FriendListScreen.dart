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

  @override
  void initState() {
    super.initState();
    fetchFriendList();
  }

  Future<void> fetchFriendList() async {
    try {
      String deviceId = getDeviceIDweb();
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
          : ListView.separated(
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
                    friend['name']!,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  trailing: Icon(Icons.chevron_right, color: Colors.white),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => otherProfileScreen(
                              deviceId: friend['deviceId']!)),
                    );
                  },
                );
              },
            ),
    );
  }
}
