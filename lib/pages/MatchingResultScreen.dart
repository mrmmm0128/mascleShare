import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:muscle_share/pages/otherProfile.dart';

class MatchingResultScreen extends StatefulWidget {
  final String? selectedOption;
  final String? selectedPrefecture;
  final String? selectedCity;

  final int? maxHeight;
  final int? minHeight;
  final int? maxWeight;
  final int? minWeight;
  final int? maxYear;
  final int? minYear;

  MatchingResultScreen(
      {this.selectedOption,
      this.selectedPrefecture,
      this.selectedCity,
      this.maxHeight,
      this.maxWeight,
      this.minHeight,
      this.minWeight,
      this.maxYear,
      this.minYear});

  @override
  _MatchingResultScreenState createState() => _MatchingResultScreenState();
}

class _MatchingResultScreenState extends State<MatchingResultScreen> {
  List<Map<String, dynamic>> userList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFilteredProfiles();
  }

  Future<void> _fetchFilteredProfiles() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection("user_list").get();

      final filtered = snapshot.docs
          .where((doc) =>
              !doc.id.contains("date") && doc.id != "training_together")
          .take(10)
          .toList();

      List<Map<String, dynamic>> results = [];

      for (final doc in filtered) {
        final profileDoc = await FirebaseFirestore.instance
            .collection(doc.id)
            .doc("profile")
            .get();

        final data = profileDoc.data();
        if (data != null) {
          if (widget.selectedOption == "身長・体重が近い人") {
            if (data["height"] != null &&
                data["weight"] != null &&
                data["height"] >= widget.minHeight &&
                data["height"] <= widget.maxHeight &&
                data["weight"] >= widget.minWeight &&
                data["weight"] <= widget.maxWeight) {
              results.add({
                "deviceId": doc.id,
                "name": data["name"] ?? "",
                "photo": data["photo"] ?? "",
                "height": data["height"],
                "weight": data["weight"],
                "startDay": data["startDay"] ?? "",
              });
            }
          } else if (widget.selectedOption == "筋トレ歴が近い人") {
            if (data["startDay"] != null && data["startDay"] is String) {
              try {
                DateTime startDate = DateTime.parse(data["startDay"]);
                DateTime now = DateTime.now();
                int years = now.difference(startDate).inDays ~/ 365;

                if (years >= widget.minYear! && years <= widget.maxYear!) {
                  results.add({
                    "deviceId": doc.id,
                    "name": data["name"] ?? "",
                    "photo": data["photo"] ?? "",
                    "height": data["height"] ?? 0,
                    "weight": data["weight"] ?? 0,
                    "startDay": data["startDay"],
                  });
                }
              } catch (e) {
                print("❌ startDayの解析に失敗しました: $e");
              }
            }
          } else {
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

      setState(() {
        userList = results;
        _isLoading = false;
      });
    } catch (e) {
      print("❌ エラー: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 209, 209, 0),
        title: Text("Result research",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.yellowAccent))
          : ListView.builder(
              itemCount: userList.length,
              itemBuilder: (context, index) {
                final user = userList[index];
                return Card(
                  color: Colors.grey[900],
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: user["photo"] != ""
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(user["photo"]),
                            radius: 28,
                          )
                        : CircleAvatar(
                            child: Icon(Icons.person, color: Colors.black),
                            backgroundColor: Colors.yellowAccent,
                            radius: 28,
                          ),
                    title: Text(
                      user["name"] != "" ? user["name"] : "Not defined",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "身長: ${user["height"]} cm  体重: ${user["weight"]} kg",
                      style: TextStyle(color: Colors.white70),
                    ),
                    trailing: Icon(Icons.chevron_right, color: Colors.white),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => otherProfileScreen(
                                  deviceId: user["deviceId"])));
                    },
                  ),
                );
              },
            ),
    );
  }
}
