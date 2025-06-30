import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class CommunityPage extends StatefulWidget {
  final String userId; // ログイン中のユーザーID
  const CommunityPage({super.key, required this.userId});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  List<Map<String, dynamic>> communities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCommunities();
  }

  Future<void> fetchCommunities() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('communities').get();
    setState(() {
      communities = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          "id": doc.id,
          "name": data["name"] ?? "No Name",
          "description": data["description"] ?? "",
          "members": List<String>.from(data["members"] ?? []),
          "imageUrl": data["imageUrl"] ?? "",
        };
      }).toList();
      _isLoading = false;
    });
  }

  Future<void> joinCommunity(String communityId) async {
    final ref =
        FirebaseFirestore.instance.collection('communities').doc(communityId);
    await ref.update({
      'members': FieldValue.arrayUnion([widget.userId])
    });
    fetchCommunities(); // 更新
  }

  Future<void> createCommunity() async {
    String name = "";
    String description = "";
    File? imageFile;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text("コミュニティ作成"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(labelText: "名前"),
                  onChanged: (value) => name = value,
                ),
                TextField(
                  decoration: InputDecoration(labelText: "説明"),
                  onChanged: (value) => description = value,
                ),
                SizedBox(height: 12),
                imageFile != null
                    ? Image.file(imageFile!, height: 100)
                    : SizedBox.shrink(),
                TextButton.icon(
                  icon: Icon(Icons.image),
                  label: Text("画像を選択"),
                  onPressed: () async {
                    final picked = await ImagePicker()
                        .pickImage(source: ImageSource.gallery);
                    if (picked != null) {
                      setState(() {
                        imageFile = File(picked.path);
                      });
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                child: Text("キャンセル"),
                onPressed: () => Navigator.of(context).pop(),
              ),
              ElevatedButton(
                child: Text("作成"),
                onPressed: () async {
                  Navigator.of(context).pop(); // ダイアログを先に閉じる

                  String imageUrl = "";
                  if (imageFile != null) {
                    final storageRef = FirebaseStorage.instance.ref(
                        'community_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
                    await storageRef.putFile(imageFile!);
                    imageUrl = await storageRef.getDownloadURL();
                  }

                  await FirebaseFirestore.instance
                      .collection('communities')
                      .add({
                    'name': name,
                    'description': description,
                    'members': [widget.userId],
                    'imageUrl': imageUrl,
                  });

                  fetchCommunities(); // 更新
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("コミュニティ", style: TextStyle(color: Colors.black)),
        backgroundColor: Color.fromARGB(255, 209, 209, 0),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.black),
            onPressed: createCommunity,
          )
        ],
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.yellowAccent))
          : Padding(
              padding: const EdgeInsets.all(12),
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.7, // 縦長にする
                children: communities.map((community) {
                  final isJoined = community["members"].contains(widget.userId);
                  return GestureDetector(
                    onTap: () {
                      // 詳細ページなどに遷移予定
                    },
                    child: Card(
                      color: Colors.grey[900],
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                      shadowColor: Colors.black45,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ClipRRect(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(12)),
                            child: Image.network(
                              community['imageUrl'] ?? '',
                              height: 100,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(color: Colors.grey[800]),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  community["name"],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 6),
                                Text(
                                  community["description"],
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 12),
                                FilledButton(
                                  style: FilledButton.styleFrom(
                                    backgroundColor: isJoined
                                        ? Colors.grey[700]
                                        : Colors.yellowAccent,
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    minimumSize: Size(double.infinity, 40),
                                  ),
                                  onPressed: isJoined
                                      ? null
                                      : () => joinCommunity(community["id"]),
                                  child: Text(isJoined ? "参加済み" : "参加"),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
    );
  }
}
