import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:muscle_share/methods/UseTemplates.dart';
import 'package:muscle_share/methods/getDeviceId.dart';
import 'package:muscle_share/pages/Header.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecordTrainingScreen extends StatefulWidget {
  final List<String> exercises;
  final String name;

  const RecordTrainingScreen({
    super.key,
    required this.exercises,
    required this.name,
  });

  @override
  _RecordTrainingScreenState createState() => _RecordTrainingScreenState();
}

class _RecordTrainingScreenState extends State<RecordTrainingScreen> {
  final Map<String, int> setCounts = {};
  final Map<String, dynamic> exerciseData = {};
  final TextEditingController _commentController = TextEditingController();
  String deviceId = "";
  late List<String> localExercises;
  bool isPublic = true;
  final List<int> _RepOptions = List.generate(61, (index) => index);
  final List<double> _weightOptions =
      List.generate(300, (index) => index * 0.5);
  List<double> _weightOptionsBodyWeight = [];
  double myBodyWeight = 0.0;

  @override
  void initState() {
    super.initState();
    initialize();
    localExercises = List.from(widget.exercises);
    for (String exercise in localExercises) {
      setCounts[exercise] = 1;
      exerciseData[exercise] = [
        {"weight": 0.0, "reps": 0}
      ];
    }
    loadDraft();
  }

  Future<void> initialize() async {
    deviceId = await getDeviceUUID();

    final profileDoc = await FirebaseFirestore.instance
        .collection(deviceId)
        .doc("profile")
        .get();
    _weightOptionsBodyWeight =
        List.generate(300, (index) => index * 0.5 + myBodyWeight);

    setState(() {
      myBodyWeight = (profileDoc.data()?["weight"] ?? 0.0).toDouble();
      _weightOptionsBodyWeight =
          List.generate(300, (index) => index * 0.5 + myBodyWeight);
    });
  }

  void loadDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final draftString = prefs.getString('draft_${widget.name}');
    if (draftString != null) {
      final Map<String, dynamic> saved = jsonDecode(draftString);
      setState(() {
        saved.forEach((key, value) {
          exerciseData[key] = List<Map<String, dynamic>>.from(
              value.map((e) => Map<String, dynamic>.from(e)));
        });
      });
    }
  }

  void saveDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final draftJson = exerciseData.map((key, value) => MapEntry(
        key,
        value
            .map((set) => {
                  "weight": set["weight"],
                  "reps": set["reps"],
                })
            .toList()));
    await prefs.setString('draft_${widget.name}', jsonEncode(draftJson));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(
        title: '記録する',
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: Row(
              children: [
                Icon(Icons.lock_open, color: Colors.yellowAccent),
                SizedBox(width: 8),
                Text("公開設定：",
                    style: TextStyle(color: Colors.yellowAccent, fontSize: 16)),
                SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<bool>(
                    value: isPublic, // ← bool型の変数を定義してください
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
                  color: Colors.black, // プレースホルダー背景色を黒に
                  elevation: 6,
                  child: child,
                );
              },
              children: List.generate(localExercises.length, (index) {
                final exercise = localExercises[index];
                final data = exerciseData[exercise]!;
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
                                  color: Colors.yellowAccent,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        ...List.generate(data.length, (i) {
                          return Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("${i + 1}セット目",
                                          style:
                                              TextStyle(color: Colors.white70)),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Expanded(
                                            child:
                                                DropdownButtonFormField<double>(
                                              value: exercise != "ディップス" &&
                                                      exercise != "チンニング"
                                                  ? data[i]["weight"]
                                                          ?.toDouble() ??
                                                      0.0
                                                  : myBodyWeight,
                                              decoration: InputDecoration(
                                                labelText: "重量(kg)",
                                                labelStyle: TextStyle(
                                                    color: Colors.white54),
                                                filled: true,
                                                fillColor: Colors.grey[800],
                                                border: OutlineInputBorder(),
                                              ),
                                              dropdownColor: Colors.grey[900],
                                              style: TextStyle(
                                                  color: Colors.white),
                                              items: exercise != "ディップス" &&
                                                      exercise != "チンニング"
                                                  ? _weightOptions
                                                      .map((weight) {
                                                      return DropdownMenuItem<
                                                          double>(
                                                        value: weight,
                                                        child: Text(
                                                            '${weight.toStringAsFixed(1)} kg'),
                                                      );
                                                    }).toList()
                                                  : _weightOptionsBodyWeight
                                                      .map((weight) {
                                                      return DropdownMenuItem<
                                                          double>(
                                                        value: weight,
                                                        child: Text(
                                                            '${weight.toStringAsFixed(1)} kg'),
                                                      );
                                                    }).toList(),
                                              onChanged: (val) {
                                                setState(() {
                                                  if (exercise != "ディップス" &&
                                                      exercise != "チンニング") {
                                                    data[i]["weight"] =
                                                        val ?? 0.0;
                                                  } else {
                                                    data[i]["weight"] =
                                                        val ?? myBodyWeight;
                                                  }

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
                                                labelStyle: TextStyle(
                                                    color: Colors.white54),
                                                filled: true,
                                                fillColor: Colors.grey[800],
                                                border: OutlineInputBorder(),
                                              ),
                                              dropdownColor: Colors.grey[900],
                                              style: TextStyle(
                                                  color: Colors.white),
                                              items: _RepOptions.map((rep) {
                                                return DropdownMenuItem<int>(
                                                  value: rep,
                                                  child: Text('$rep 回'),
                                                );
                                              }).toList(),
                                              onChanged: (val) {
                                                setState(() {
                                                  data[i]["reps"] = val!;
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
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              if (data.isNotEmpty) {
                                final Map<String, dynamic> last =
                                    Map<String, dynamic>.from(data.last);
                                data.add({
                                  "weight": (last["weight"] ?? 0.0) as double,
                                  "reps": (last["reps"] ?? 0) as int,
                                });
                              } else {
                                data.add({"weight": 0.0, "reps": 0});
                              }
                            });
                            saveDraft();
                          },
                          icon: Icon(Icons.add, color: Colors.yellowAccent),
                          label: Text("セットを追加",
                              style: TextStyle(color: Colors.yellowAccent)),
                        )
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('記録が保存されました。')),
                );
                exerciseData["myComment"] = _commentController.text;
                exerciseData["isPublic"] = isPublic;
                await UseTemplates.saveTraining(
                    deviceId, widget.name, exerciseData);

                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('draft_${widget.name}'); // 🔸ドラフト削除

                setState(() {
                  for (String exercise in localExercises) {
                    exerciseData[exercise] = [
                      {"weight": 0, "reps": 0}
                    ];
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellowAccent,
                foregroundColor: Colors.black,
                minimumSize: Size(MediaQuery.of(context).size.width / 6, 48),
              ),
              child: Text(
                "本日のトレーニングを終了する",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
