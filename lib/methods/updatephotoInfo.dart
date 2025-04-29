import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:muscle_share/methods/getDeviceId.dart';

Future<void> updatePhotoInfo(BuildContext context, String uniqueKey) async {
  try {
    Map<String, String?>? userInput = await showMascleSelection(context);
    if (userInput == null) return; // ユーザーがキャンセルしたとき

    String mascle = userInput["mascle"] ?? "";
    String caption = userInput["caption"] ?? "";
    String isPrivate = userInput["isPrivate"] ?? "";
    String deviceId = getDeviceIDweb();
    String dateKey = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // 🔁 まず現在の info ドキュメントを取得
    final docRef = FirebaseFirestore.instance.collection(deviceId).doc("info");
    final snapshot = await docRef.get();

    Map<String, dynamic> currentData = snapshot.data() ?? {};

    // 📦 該当 uniqueKey の中身を更新 or 新規作成
    Map<String, dynamic> updatedEntry =
        Map<String, dynamic>.from(currentData[uniqueKey] ?? {});
    updatedEntry["caption"] = caption;
    updatedEntry["mascle"] = mascle;
    updatedEntry["isPrivate"] = isPrivate;

    // ⬆️ 更新した内容を info ドキュメントに保存
    await docRef.set({uniqueKey: updatedEntry}, SetOptions(merge: true));

    // 📅 同じく dateKey 側も更新
    final memoryRef =
        FirebaseFirestore.instance.collection(dateKey).doc("memory");
    final memorySnapshot = await memoryRef.get();
    Map<String, dynamic> memoryData = memorySnapshot.data() ?? {};

    Map<String, dynamic> updatedMemoryEntry =
        Map<String, dynamic>.from(memoryData[uniqueKey] ?? {});
    updatedMemoryEntry["caption"] = caption;
    updatedMemoryEntry["mascle"] = mascle;
    updatedMemoryEntry["stringisPrivate"] = isPrivate;

    await memoryRef
        .set({uniqueKey: updatedMemoryEntry}, SetOptions(merge: true));
  } catch (e) {
    print("⚠️ エラー発生: $e");
    // 必要に応じてエラーダイアログやトーストを表示
  }
}

Future<void> deletePhoto(String uniqueKey) async {
  String deviceId = getDeviceIDweb();
  String dateKey = DateFormat('yyyy-MM-dd').format(DateTime.now());

  final docRef = FirebaseFirestore.instance.collection(deviceId).doc("info");
  final memoryRef =
      FirebaseFirestore.instance.collection(dateKey).doc("memory");

  try {
    // 両方のドキュメントから該当フィールドを削除
    await Future.wait([
      docRef.update({uniqueKey: FieldValue.delete()}),
      memoryRef.update({uniqueKey: FieldValue.delete()}),
    ]);

    print("✅ $uniqueKey を info と memory から削除しました");
  } catch (e) {
    print("❌ 削除に失敗しました: $e");
  }
}

Future<Map<String, String?>?> showMascleSelection(BuildContext context) async {
  List<String> mascleOptions = ["Chest", "Back", "Legs", "Arms"];

  return await await showModalBottomSheet<Map<String, String?>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.grey[900],
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      String? selectedMascle;
      String? caption;
      bool isPublic = true;

      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              left: 20,
              right: 20,
              top: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "筋トレ情報を入力",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.yellow,
                  ),
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedMascle,
                  decoration: InputDecoration(
                    labelText: "部位を選択",
                    labelStyle: TextStyle(color: Colors.yellow),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.yellow),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.yellow, width: 2),
                    ),
                  ),
                  dropdownColor: Colors.grey[850],
                  style: TextStyle(color: Colors.white),
                  items: mascleOptions.map((String mascle) {
                    return DropdownMenuItem<String>(
                      value: mascle,
                      child:
                          Text(mascle, style: TextStyle(color: Colors.white)),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedMascle = newValue;
                    });
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "キャプションを入力",
                    labelStyle: TextStyle(color: Colors.yellow),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.yellow),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.yellow, width: 2),
                    ),
                  ),
                  onChanged: (value) {
                    caption = value;
                  },
                ),
                SizedBox(height: 16),
                CheckboxListTile(
                  title: Text(
                    "private",
                    style: TextStyle(color: Colors.yellow),
                  ),
                  value: isPublic,
                  activeColor: Colors.yellow,
                  checkColor: Colors.black,
                  onChanged: (bool? value) {
                    setState(() {
                      isPublic = value ?? true;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      child:
                          Text("キャンセル", style: TextStyle(color: Colors.grey)),
                      onPressed: () => Navigator.pop(context, null),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow,
                      ),
                      onPressed: () {
                        Navigator.pop(context, {
                          "mascle": selectedMascle,
                          "caption": caption,
                          "isPrivate": isPublic.toString(),
                        });
                      },
                      child: Text("保存", style: TextStyle(color: Colors.black)),
                    ),
                  ],
                )
              ],
            ),
          );
        },
      );
    },
  );
}
