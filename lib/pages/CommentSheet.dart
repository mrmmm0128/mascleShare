import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_mentions/flutter_mentions.dart';
//import 'package:intl/intl.dart';
import 'package:muscle_share/methods/AddCommentLike.dart';
import 'package:muscle_share/methods/getDeviceId.dart';
import 'package:muscle_share/pages/OtherProfile.dart';

class CommentSheet extends StatefulWidget {
  final String deviceId;
  final String date;

  const CommentSheet({super.key, required this.deviceId, required this.date});

  @override
  State<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet> {
  List<Map<String, String>> commentList = [];
  String myDeviceId = "";
  // ignore: unused_field

  final TextEditingController _controller = TextEditingController();
  final GlobalKey<FlutterMentionsState> _key =
      GlobalKey<FlutterMentionsState>();

  List<Map<String, String>> _mentionUsers = []; // id, display, photo用（後で使う）

  @override
  void initState() {
    super.initState();
    _loadMentionUsers();
  }

  Future<void> _loadMentionUsers() async {
    final myDeviceId = await getDeviceUUID();
    final friendDoc = await FirebaseFirestore.instance
        .collection(myDeviceId)
        .doc("profile")
        .get();

    if (friendDoc.exists) {
      final friends = friendDoc.data()!;
      _mentionUsers.clear();
      List<String> friendsList = List<String>.from(friends["friendDeviceId"]);

      for (String friendId in friendsList) {
        final profileDoc = await FirebaseFirestore.instance
            .collection(friendId)
            .doc("profile")
            .get();

        if (profileDoc.exists) {
          final name = profileDoc.data()?["name"] ?? "Unknown";
          final photo = profileDoc.data()?["photo"] ?? "";
          _mentionUsers.add({
            'id': friendId,
            'display': name,
            'photo': photo,
          });
        }
      }
      print(_mentionUsers);
      setState(() {});
    }
  }

  Future<void> initialize() async {
    myDeviceId = await getDeviceUUID();
  }

  List<String> extractMentionIds(String markupText) {
    final RegExp reg = RegExp(r'\@\[\_\_(.*?)\_\_\]');
    final matches = reg.allMatches(markupText);

    return matches.map((match) => match.group(1) ?? "").toList();
  }

  String convertMarkupToDisplayText(String markupText) {
    final RegExp reg = RegExp(r'\@\[\_\_.*?\_\_\]\(__([^\)]+)__\)');
    return markupText.replaceAllMapped(reg, (match) {
      final displayName = match.group(1);
      return '@$displayName';
    });
  }

  @override
  Widget build(BuildContext context) {
    final docRef =
        FirebaseFirestore.instance.collection(widget.deviceId).doc("history");

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 16,
        left: 16,
        right: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'コメント',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 12),
          StreamBuilder<DocumentSnapshot>(
            stream: docRef.snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const CircularProgressIndicator();

              final data = snapshot.data!.data() as Map<String, dynamic>;
              final comments = (data[widget.date]?['comment'] ?? []) as List;

              return SizedBox(
                height: 400,
                child: ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    return ListTile(
                      leading: comment["url"] != ""
                          ? GestureDetector(
                              onTap: () async {
                                final String deviceId = comment["deviceId"];

                                if (myDeviceId != deviceId) {
                                  // Firestore にコレクションが存在するかチェック（例: profile ドキュメントを見る）
                                  final profileSnapshot =
                                      await FirebaseFirestore.instance
                                          .collection(deviceId)
                                          .doc("profile")
                                          .get();

                                  if (profileSnapshot.exists) {
                                    // 存在する場合 → 遷移
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            otherProfileScreen(
                                          deviceId: deviceId,
                                        ),
                                      ),
                                    );
                                  } else {
                                    // 存在しない場合 → エラーメッセージ表示
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("すでに存在しないアカウントです"),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                              child: CircleAvatar(
                                backgroundImage:
                                    NetworkImage(comment['url'] ?? ''),
                              ))
                          : GestureDetector(
                              onTap: () async {
                                final String deviceId = comment["deviceId"];

                                if (myDeviceId != deviceId) {
                                  // Firestore にコレクションが存在するかチェック（例: profile ドキュメントを見る）
                                  final profileSnapshot =
                                      await FirebaseFirestore.instance
                                          .collection(deviceId)
                                          .doc("profile")
                                          .get();

                                  if (profileSnapshot.exists) {
                                    // 存在する場合 → 遷移
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            otherProfileScreen(
                                          deviceId: deviceId,
                                        ),
                                      ),
                                    );
                                  } else {
                                    // 存在しない場合 → エラーメッセージ表示
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("すでに存在しないアカウントです"),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                              child: CircleAvatar(
                                backgroundColor: Colors.grey,
                                child: Icon(Icons.person, color: Colors.white),
                              ),
                            ),
                      title: comment["name"] != ""
                          ? Text(comment['name'] ?? "Not defined",
                              style: const TextStyle(color: Colors.white))
                          : Text("Not defined",
                              style: const TextStyle(color: Colors.white)),
                      subtitle: Text(comment['comment'] ?? '',
                          style: const TextStyle(color: Colors.white70)),
                    );
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          FlutterMentions(
            key: _key,
            style: const TextStyle(color: Colors.white),
            suggestionPosition: SuggestionPosition.Bottom,
            decoration: const InputDecoration(
              hintText: 'コメントを入力...',
              hintStyle: TextStyle(color: Colors.white54),
              border: OutlineInputBorder(),
            ),
            mentions: [
              Mention(
                trigger: "@",
                style: const TextStyle(color: Colors.yellowAccent),
                data: _mentionUsers,
                suggestionBuilder: (data) {
                  return ListTile(
                    leading: data['photo'] != ""
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(data['photo']))
                        : const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(data['display'],
                        style: const TextStyle(color: Colors.black)),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 209, 209, 0),
              foregroundColor: Colors.black,
            ),
            onPressed: () async {
              final markupText =
                  _key.currentState?.controller?.markupText ?? "";
              final mentionedIds = extractMentionIds(markupText);

              final lowerText = convertMarkupToDisplayText(markupText);
              final List<String> prohibitedWords = [
                'ちんこ',
                'まんこ',
                'うんこ',
                '死ね',
                'しね',
                'fuck',
                'sex',
                'セックス',
                'ち○こ',
                'f○ck'
              ];

              if (prohibitedWords.any((word) => lowerText.contains(word))) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Colors.black,
                    title: const Text(
                      "不適切な内容",
                      style: TextStyle(color: Color.fromARGB(255, 209, 209, 0)),
                    ),
                    content: const Text(
                      "コメントに不適切な表現が含まれています。",
                      style: TextStyle(color: Colors.white),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text("OK",
                            style: TextStyle(
                                color: Color.fromARGB(255, 209, 209, 0))),
                      ),
                    ],
                  ),
                );
                return;
              }

              if (markupText.trim().isNotEmpty) {
                await AddCommentLike.addCommentWithMentions(
                  deviceId: widget.deviceId,
                  date: widget.date,
                  commentText: lowerText,
                  mentionedIds: mentionedIds,
                );
                _key.currentState?.controller?.clear(); // メンション付き入力クリア
              }
            },
            child: const Text(
              '送信',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
