import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muscle_share/methods/UseTemplates.dart';
import 'package:muscle_share/methods/getDeviceId.dart';
import 'package:muscle_share/pages/Header.dart';

class EditTrainingScreen extends StatefulWidget {
  final String name;
  final Map<String, dynamic> trainingData;

  const EditTrainingScreen({
    super.key,
    required this.name,
    required this.trainingData,
  });

  @override
  _EditTrainingScreenState createState() => _EditTrainingScreenState();
}

class _EditTrainingScreenState extends State<EditTrainingScreen> {
  final List<int> _RepOptions = List.generate(61, (index) => index);
  final List<double> _weightOptions =
      List.generate(300, (index) => index * 0.5);
  late Map<String, dynamic> exerciseData;
  late final TextEditingController _commentController;
  late List<String> localExercises;
  bool isPublic = true;
  String deviceId = "";
  String myComment = "";

  @override
  void initState() {
    super.initState();
    initialize();
    exerciseData = Map<String, dynamic>.from(widget.trainingData);
    print(exerciseData);
    localExercises = exerciseData.keys
        .where((e) =>
            e != "isPublic" &&
            e != "like" &&
            e != "comment" &&
            e != "myComment")
        .toList();
    isPublic = widget.trainingData["isPublic"] ?? true;
    myComment = widget.trainingData["myComment"] ?? "";
    _commentController = TextEditingController(text: myComment);
  }

  Future<void> initialize() async {
    deviceId = await getDeviceUUID();
  }

  void saveDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final draftJson = exerciseData.map((key, value) {
      if (value is List) {
        // 種目データ（List<Map<String, dynamic>>）の場合
        return MapEntry(
          key,
          value
              .map((set) => {
                    "weight": set["weight"],
                    "reps": set["reps"],
                  })
              .toList(),
        );
      } else {
        // コメント・公開設定などその他の単一データの場合
        return MapEntry(key, value);
      }
    });

    await prefs.setString('edit_draft_${widget.name}', jsonEncode(draftJson));
  }

  double _parseToDouble(dynamic val) {
    if (val is double) return val;
    if (val is int) return val.toDouble();
    if (val is String) {
      return double.tryParse(val) ?? 0.0;
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(title: '記録の編集'),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(Icons.lock_open, color: Colors.yellowAccent),
                SizedBox(width: 8),
                Text("公開設定：",
                    style: TextStyle(color: Colors.yellowAccent, fontSize: 16)),
                SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<bool>(
                    value: isPublic,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[850],
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.yellow),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.amber, width: 2),
                      ),
                    ),
                    dropdownColor: Colors.grey[900],
                    iconEnabledColor: Colors.yellow,
                    style: TextStyle(color: Colors.yellow),
                    items: [
                      DropdownMenuItem(
                        value: true,
                        child: Text("公開",
                            style: TextStyle(color: Colors.yellowAccent)),
                      ),
                      DropdownMenuItem(
                        value: false,
                        child: Text("非公開",
                            style: TextStyle(color: Colors.yellowAccent)),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        isPublic = value ?? true;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.comment, color: Colors.yellowAccent),
                    SizedBox(width: 8),
                    Text(
                      "コメント入力",
                      style:
                          TextStyle(color: Colors.yellowAccent, fontSize: 16),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller:
                      _commentController, // ← TextEditingControllerを定義してね
                  maxLines: null,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'コメントを入力...',
                    hintStyle: TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Colors.grey[850],
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.yellow),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.amber, width: 2),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ReorderableListView(
              padding: const EdgeInsets.all(16),
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex--;
                  final item = localExercises.removeAt(oldIndex);
                  localExercises.insert(newIndex, item);
                });
              },
              proxyDecorator: (child, index, animation) {
                return Material(
                  color: Colors.black,
                  elevation: 6,
                  child: child,
                );
              },
              children: List.generate(localExercises.length, (index) {
                final exercise = localExercises[index];
                final data = exerciseData[exercise];
                return Card(
                  key: ValueKey(exercise),
                  color: Colors.grey[900],
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                exercise,
                                style: TextStyle(
                                    color: Colors.yellowAccent, fontSize: 16),
                              ),
                            ),
                            ReorderableDragStartListener(
                              index: index,
                              child:
                                  Icon(Icons.drag_handle, color: Colors.white),
                            ),
                          ],
                        ),
                        ...List.generate(data.length, (i) {
                          return Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<double>(
                                    value: _parseToDouble(data[i]["weight"]),
                                    decoration: InputDecoration(
                                      labelText: "重量(kg)",
                                      labelStyle:
                                          TextStyle(color: Colors.white54),
                                      filled: true,
                                      fillColor: Colors.grey[800],
                                      border: OutlineInputBorder(),
                                    ),
                                    dropdownColor: Colors.grey[900],
                                    style: TextStyle(color: Colors.white),
                                    items: _weightOptions.map((weight) {
                                      return DropdownMenuItem<double>(
                                        value: weight,
                                        child: Text(
                                            '${weight.toStringAsFixed(1)} kg'),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      setState(() {
                                        data[i]["weight"] = val ?? 0.0;
                                        saveDraft();
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: DropdownButtonFormField<int>(
                                    value: data[i]["reps"],
                                    decoration: InputDecoration(
                                      labelText: "回数",
                                      labelStyle:
                                          TextStyle(color: Colors.white54),
                                      filled: true,
                                      fillColor: Colors.grey[800],
                                      border: OutlineInputBorder(),
                                    ),
                                    dropdownColor: Colors.grey[900],
                                    style: TextStyle(color: Colors.white),
                                    items: _RepOptions.map((rep) {
                                      return DropdownMenuItem<int>(
                                        value: rep,
                                        child: Text('$rep 回'),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      setState(() {
                                        data[i]["reps"] = val ?? 0;
                                        saveDraft();
                                      });
                                    },
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.clear,
                                      color: Colors.redAccent),
                                  onPressed: () {
                                    setState(() {
                                      data.removeAt(i);
                                      saveDraft();
                                    });
                                  },
                                ),
                              ],
                            ),
                          );
                        }),
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              if (data.isNotEmpty) {
                                final last = data.last;
                                data.add({
                                  "weight": last["weight"] ?? 0,
                                  "reps": last["reps"] ?? 0,
                                });
                              } else {
                                data.add({"weight": 0, "reps": 0});
                              }
                            });
                            saveDraft();
                          },
                          icon: Icon(Icons.add, color: Colors.yellowAccent),
                          label: Text("セットを追加",
                              style: TextStyle(color: Colors.yellowAccent)),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () async {
                exerciseData["isPublic"] = isPublic;
                await UseTemplates.saveTraining(
                    deviceId, widget.name, exerciseData);
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('edit_draft_${widget.name}');
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text("編集内容を保存しました")));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellowAccent,
                foregroundColor: Colors.black,
              ),
              child: Text("編集を保存", style: TextStyle(color: Colors.black)),
            ),
          )
        ],
      ),
    );
  }
}
