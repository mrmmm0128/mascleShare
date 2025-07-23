import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:muscle_share/methods/AddCommentLike.dart';
import 'package:muscle_share/methods/getDeviceId.dart';
import 'package:muscle_share/pages/CommentSheet.dart';
import 'package:muscle_share/pages/FriendTrainingDetailScreen.dart';

class FriendTrainingCard extends StatefulWidget {
  final Map<String, dynamic> training;
  final String friendDeviceId;

  const FriendTrainingCard({
    Key? key,
    required this.training,
    required this.friendDeviceId,
  }) : super(key: key);

  @override
  State<FriendTrainingCard> createState() => _FriendTrainingCardState();
}

class _FriendTrainingCardState extends State<FriendTrainingCard> {
  Map<String, dynamic> friendData = {};
  bool isLoading = true;
  late String name;
  late String photoUrl;
  late String date;
  late List<Map<String, String>> commentList = [];
  int numComment = 0;
  List<String> likeDeviceId = [];
  int numLike = 0;
  bool isLiked = false;
  String mydeviceId = "";

  @override
  void initState() {
    super.initState();

    fetchOtherInfo(widget.friendDeviceId);
  }

  Future<void> fetchOtherInfo(String deviceId) async {
    mydeviceId = await getDeviceIDweb();
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection(deviceId)
          .doc("profile")
          .get();

      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>? ?? {};
        setState(() {
          friendData = {
            "url": data["photo"]?.toString() ?? "",
            "name": data["name"]?.toString() ?? "Unknown",
          };
        });

        name = friendData['name'] ?? "Unknown";
        photoUrl = friendData['url'] ?? "";
        date = widget.training["date"] ?? "";

        commentList =
            await AddCommentLike.fetchComment(widget.friendDeviceId, date);

        likeDeviceId =
            await AddCommentLike.fetchLike(widget.friendDeviceId, date);

        if (likeDeviceId.contains(mydeviceId)) {
          isLiked = true;
        } else {
          isLiked = false;
        }
        print(isLiked);

        numComment = commentList.length;
        numLike = likeDeviceId.length;

        setState(() {
          isLoading = false;
        });
      } else {
        setState(() {
          friendData = {"url": "", "name": "Unknown"};
          isLoading = false;
        });
      }
    } catch (e) {
      print("❌ Firestore のデータ取得中に例外が発生しました: $e");
      setState(() {
        friendData = {"url": "", "name": "Unknown"};
        isLoading = false;
      });
    }
  }

  void _showCommentSheet(BuildContext context, String deviceId, String date) {
    try {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.black,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => CommentSheet(
          deviceId: deviceId,
          date: date,
        ),
      );
    } catch (e, stackTrace) {
      print("❌ コメントシート表示中にエラー発生: $e");
      print(stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
          child: CircularProgressIndicator(color: Colors.yellowAccent));
    }

    double totalVolume = 0.0;
    Map<String, dynamic> exerciseMap = widget.training["data"] ?? {};
    exerciseMap.forEach((exerciseName, sets) {
      for (var set in sets) {
        if (exerciseName != "like") {
          final weight = (set["weight"] ?? 0).toDouble();
          final reps = (set["reps"] ?? 0).toDouble();
          totalVolume += weight * reps;
        }
      }
    });

    return Padding(
      padding: EdgeInsets.all(4),
      child: InkWell(
        onTap: () {
          Map<String, dynamic> enrichedTraining =
              Map<String, dynamic>.from(widget.training)
                ..["totalVolume"] = totalVolume.toStringAsFixed(2);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FriendTrainingDetailScreen(
                training: enrichedTraining,
                friendDeviceId: widget.friendDeviceId,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        splashColor: Colors.yellowAccent.withOpacity(0.3),
        child: Card(
          color: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
          child: Column(
            children: [
              ListTile(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                leading: CircleAvatar(
                  backgroundImage:
                      photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                  child: photoUrl.isEmpty
                      ? Icon(Icons.person, color: Colors.black)
                      : null,
                  backgroundColor: Colors.yellowAccent,
                  radius: 20,
                ),
                title: Text(
                  name,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                subtitle: Text(
                  date,
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        icon: Icon(
                          Icons.favorite,
                          color: isLiked ? Colors.red : Colors.white70,
                        ),
                        onPressed: () {
                          setState(() {
                            AddCommentLike.editLike(mydeviceId, likeDeviceId,
                                date, widget.friendDeviceId);
                            print(likeDeviceId);

                            if (isLiked) {
                              isLiked = false;
                              likeDeviceId.remove(mydeviceId);
                              print(likeDeviceId);
                            } else {
                              isLiked = true;
                              likeDeviceId.add(mydeviceId);
                              print(likeDeviceId);
                            }
                          });
                        }),
                    Text(
                      '${likeDeviceId.length}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.comment, color: Colors.white, size: 22),
                      onPressed: () {
                        _showCommentSheet(context, widget.friendDeviceId, date);
                      },
                    ),
                    Text(
                      numComment.toString(),
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Divider(color: Colors.yellowAccent, height: 1),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                child: Text(
                  "総ボリューム: ${totalVolume.toStringAsFixed(2)} kg·回",
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
