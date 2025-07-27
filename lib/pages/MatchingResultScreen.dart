import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:muscle_share/methods/getDeviceId.dart';
import 'package:muscle_share/pages/Header.dart';
import 'package:muscle_share/pages/OtherProfile.dart';

class MatchingResultScreen extends StatefulWidget {
  final List<String>? selectedOptions;
  final String? selectedPrefecture;
  final String? selectedCity;

  final int? maxHeight;
  final int? minHeight;
  final int? maxWeight;
  final int? minWeight;
  final int? maxYear;
  final int? minYear;
  final String? searchDeviceId;

  MatchingResultScreen(
      {this.selectedOptions,
      this.selectedPrefecture,
      this.selectedCity,
      this.maxHeight,
      this.maxWeight,
      this.minHeight,
      this.minWeight,
      this.maxYear,
      this.minYear,
      this.searchDeviceId});

  @override
  _MatchingResultScreenState createState() => _MatchingResultScreenState();
}

class _MatchingResultScreenState extends State<MatchingResultScreen> {
  List<Map<String, dynamic>> userList = [];
  bool _isLoading = true;
  String myDeviceId = "";

  @override
  void initState() {
    super.initState();
    _fetchFilteredProfiles();
  }

  Future<void> _fetchFilteredProfiles() async {
    myDeviceId = await getDeviceUUID();

    try {
      final snapshot =
          await FirebaseFirestore.instance.collection("user_list").get();

      final filtered = snapshot.docs
          .where((doc) =>
              !doc.id.contains("date") && doc.id != "training_together")
          .take(4000)
          .toList();
      print(filtered);

      List<Map<String, dynamic>> results = [];

      if (widget.searchDeviceId?.isEmpty ?? true) {
        // widget.searchDeviceId が null または 空 の場合
        for (final doc in filtered) {
          final profileDoc = await FirebaseFirestore.instance
              .collection(doc.id)
              .doc("profile")
              .get();

          final data = profileDoc.data();
          if (data != null) {
            bool matches = true;

            // 身長・体重条件のチェック
            if (widget.selectedOptions!.contains("身長・体重が近い人")) {
              final height = data["height"];
              final weight = data["weight"];
              if (height == null ||
                  weight == null ||
                  height < widget.minHeight ||
                  height > widget.maxHeight ||
                  weight < widget.minWeight ||
                  weight > widget.maxWeight) {
                matches = false;
              }
            }

            // 筋トレ歴のチェック
            if (widget.selectedOptions!.contains("筋トレ歴が近い人")) {
              final startDay = data["startDay"];
              if (startDay != null && startDay is String) {
                try {
                  final startDate = DateTime.parse(startDay);
                  final now = DateTime.now();
                  final years = now.difference(startDate).inDays ~/ 365;

                  if (years < widget.minYear! || years > widget.maxYear!) {
                    matches = false;
                  }
                } catch (e) {
                  print("❌ startDayの解析に失敗しました: $e");
                  matches = false;
                }
              }
            }

            // 条件を満たしたら追加
            if (matches) {
              results.add({
                "deviceId": doc.id,
                "name": data["name"] ?? "",
                "photo": data["photo"] ?? "",
                "height": data["height"] ?? 0,
                "weight": data["weight"] ?? 0,
                "startDay": data["startDay"] ?? "",
              });
            }
          }
        }
      } else if (widget.searchDeviceId != null) {
        // widget.searchDeviceId が null でない場合
        final profileDoc = await FirebaseFirestore.instance
            .collection(widget.searchDeviceId!)
            .doc("profile")
            .get();

        final data = profileDoc.data();
        if (data != null) {
          results.add({
            "deviceId": widget.searchDeviceId!,
            "name": data["name"] ?? "",
            "photo": data["photo"] ?? "",
            "height": data["height"] ?? 0,
            "weight": data["weight"] ?? 0,
            "startDay": data["startDay"] ?? "",
          });
        }
      }

      setState(() {
        userList = results;
        _isLoading = false;
      });
    } catch (e) {
      print("❌ エラー: $e");
      setState(() => _isLoading = false);
    }
    print(userList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: Header(
        title: 'bro検索結果',
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.yellowAccent))
          : ListView.builder(
              itemCount: userList.length,
              itemBuilder: (context, index) {
                final user = userList[index];

                return myDeviceId != user["deviceId"]
                    ? Card(
                        color: Colors.grey[900],
                        margin:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: user["photo"] != ""
                              ? CircleAvatar(
                                  backgroundImage: NetworkImage(user["photo"]),
                                  radius: 28,
                                )
                              : CircleAvatar(
                                  child:
                                      Icon(Icons.person, color: Colors.black),
                                  backgroundColor: Colors.yellowAccent,
                                  radius: 28,
                                ),
                          title: Text(
                            user["name"] != "" ? user["name"] : "Not defined",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "身長: ${user["height"]} cm  体重: ${user["weight"]} kg",
                            style: TextStyle(color: Colors.white70),
                          ),
                          trailing:
                              Icon(Icons.chevron_right, color: Colors.white),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => otherProfileScreen(
                                    deviceId: user["deviceId"]),
                              ),
                            );
                          },
                        ),
                      )
                    : const SizedBox();
              },
            ),
    );
  }
}
