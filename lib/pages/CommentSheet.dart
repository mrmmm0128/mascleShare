import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> commentList = [];
  String myDeviceId = "";

  @override
  void initState() {
    super.initState();
  }

  Future<void> initialize() async {
    myDeviceId = await getDeviceUUID();
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
          TextField(
            controller: _controller,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'コメントを入力...',
              hintStyle: TextStyle(color: Colors.white54),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 209, 209, 0),
              foregroundColor: Colors.black,
            ),
            onPressed: () async {
              final text = _controller.text.trim();

              // 不適切な単語リスト
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

              // NGワードを含んでいるかチェック（大文字小文字問わず）
              bool containsNG = prohibitedWords.any(
                (word) => text.toLowerCase().contains(word.toLowerCase()),
              );

              if (containsNG) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Colors.black,
                    title: Text(
                      "不適切な内容",
                      style: TextStyle(color: Color.fromARGB(255, 209, 209, 0)),
                    ),
                    content: Text(
                      "コメントに不適切な表現が含まれています。",
                      style: TextStyle(color: Colors.white),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text("OK",
                            style: TextStyle(
                                color: Color.fromARGB(255, 209, 209, 0))),
                      ),
                    ],
                  ),
                );
                return;
              }

              if (text.isNotEmpty) {
                await AddCommentLike.addComment(
                    widget.deviceId, widget.date, text);
                _controller.clear();
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
