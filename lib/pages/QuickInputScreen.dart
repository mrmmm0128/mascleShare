import 'package:flutter/material.dart';
import 'package:muscle_share/methods/UseTemplates.dart';
import 'package:muscle_share/methods/getDeviceId.dart';
import 'package:muscle_share/pages/Header.dart';
import 'package:muscle_share/pages/HistoryRecording.dart';
import 'package:muscle_share/pages/RecordTrainingScreen.dart';

class QuickInputScreen extends StatefulWidget {
  const QuickInputScreen({super.key});

  @override
  State<QuickInputScreen> createState() => _QuickInputScreenState();
}

class _QuickInputScreenState extends State<QuickInputScreen> {
  List<Map<String, dynamic>> templates = [];
  final customExerciseController = TextEditingController();

  final Map<String, List<String>> exerciseGroups = {
    "胸": [
      "ベンチプレス",
      "インクラインベンチプレス",
      "チェストプレス",
      "インクラインダンベルプレス",
      "ケーブルクロス",
      "ディップス",
      "ダンベルプレス"
    ],
    "背中": ["ラットプルダウン", "ワンハンドロウ", "プーリーロー", "チンニング", "ベントオーバーローイング"],
    "脚": ["スクワット", "レッグプレス"],
    "肩": ["ショルダープレス", "サイドレイズ", "スミスマシンバーベルスクワット"],
    "腕": ["アームカール", "トライセプスエクステンション", "ケーブルプレスダウン", "スカルクラッシャー"],
    "腹筋": ["プランク", "上体起こし"],
  };

  final List<String> templateNames = [
    'All',
    'Chest',
    'Back',
    'Legs',
    'Arms',
    "Shoulder",
    "hip",
    "Aerobic exercise",
    "Upper body",
    "Lower body",
    "push",
    "pull"
  ];
  String? selectedTemplateName;

  List<String> selectedExercises = [];
  TextEditingController templateNameController = TextEditingController();
  String deviceId = "";

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    deviceId = await getDeviceUUID();
    loadTemplates();
  }

  void _deleteTemplate(int index) async {
    final template = templates[index];
    final templateName = template["name"];

    // Firestoreからテンプレート削除
    await UseTemplates.deleteTemplate(deviceId, templateName);

    setState(() {
      // テンプレートリストから削除
      templates.removeAt(index);
    });

    print("テンプレート '$templateName' を削除しました");
  }

  void _confirmDeleteTemplate(int index) {
    final template = templates[index];
    final templateName = template["name"];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text("テンプレート削除", style: TextStyle(color: Colors.white)),
          content: Text(
            "本当に '$templateName' を削除しますか？",
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("キャンセル", style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                _deleteTemplate(index); // 削除実行
                Navigator.of(context).pop();
              },
              child: Text("削除", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showTemplateDialog() {
    List<String> tempSelectedExercises = [];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text("テンプレート作成", style: TextStyle(color: Colors.white)),
          content: StatefulBuilder(
            builder: (context, setState) {
              final customExerciseController = TextEditingController();

              // デフォルト種目の集合（重複排除）
              final defaultExercises =
                  exerciseGroups.values.expand((e) => e).toSet();

              // カスタム種目（選択中だがデフォルトに含まれないもの）
              final customExercises = tempSelectedExercises
                  .where((e) => !defaultExercises.contains(e))
                  .toList();

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ▼ テンプレート名選択
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[850],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.yellowAccent,
                          width: 2,
                        ),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButton<String>(
                        value: selectedTemplateName,
                        hint: Text(
                          "テンプレート名を選択",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 16,
                          ),
                        ),
                        items: templateNames.map((name) {
                          return DropdownMenuItem<String>(
                            value: name,
                            child: Text(name,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedTemplateName = value;
                          });
                        },
                        isExpanded: true,
                        style: TextStyle(color: Colors.black, fontSize: 16),
                        dropdownColor: Colors.black,
                        icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text("種目を選択",
                        style:
                            TextStyle(color: Color.fromARGB(255, 209, 209, 0))),

                    SizedBox(height: 20),

                    // ▼ カスタム種目追加フィールド
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: customExerciseController,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "カスタム種目名を入力",
                              hintStyle: TextStyle(color: Colors.white54),
                              filled: true,
                              fillColor: Colors.grey[800],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            final newExercise =
                                customExerciseController.text.trim();
                            if (newExercise.isNotEmpty &&
                                !tempSelectedExercises.contains(newExercise)) {
                              setState(() {
                                tempSelectedExercises.insert(
                                    0, newExercise); // 先頭に追加
                                customExerciseController.clear();
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.yellowAccent,
                            foregroundColor: Colors.black,
                          ),
                          child: Text("追加"),
                        ),
                      ],
                    ),

                    SizedBox(height: 16),

                    // ▼ カスタム種目（チェックリスト上部）
                    if (customExercises.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("カスタム種目",
                              style: TextStyle(
                                  color: Colors.yellowAccent,
                                  fontWeight: FontWeight.bold)),
                          ...customExercises.map((exercise) {
                            return CheckboxListTile(
                              value: tempSelectedExercises.contains(exercise),
                              title: Text(exercise,
                                  style: TextStyle(color: Colors.white)),
                              activeColor: Colors.yellow,
                              checkColor: Colors.black,
                              onChanged: (value) {
                                setState(() {
                                  if (value == true) {
                                    tempSelectedExercises.add(exercise);
                                  } else {
                                    tempSelectedExercises.remove(exercise);
                                  }
                                });
                              },
                            );
                          }).toList(),
                          SizedBox(height: 16),
                        ],
                      ),

                    // ▼ デフォルト種目（部位別）
                    ...exerciseGroups.entries.map((group) {
                      final part = group.key;
                      final exercises = group.value;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              part,
                              style: TextStyle(
                                  color: Colors.yellowAccent,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          ...exercises.map((exercise) {
                            return CheckboxListTile(
                              value: tempSelectedExercises.contains(exercise),
                              title: Text(exercise,
                                  style: TextStyle(color: Colors.white)),
                              activeColor: Colors.yellow,
                              checkColor: Colors.black,
                              onChanged: (value) {
                                setState(() {
                                  if (value == true) {
                                    tempSelectedExercises.add(exercise);
                                  } else {
                                    tempSelectedExercises.remove(exercise);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              child: Text("キャンセル", style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedTemplateName != null &&
                    tempSelectedExercises.isNotEmpty) {
                  setState(() {
                    templates.add({
                      "name": selectedTemplateName,
                      "exercises": List<String>.from(tempSelectedExercises),
                    });
                  });

                  UseTemplates.saveTemplate(
                    deviceId,
                    selectedTemplateName!,
                    List<String>.from(tempSelectedExercises),
                  );

                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellowAccent,
                foregroundColor: Colors.black,
              ),
              child: Text("作成"),
            ),
          ],
        );
      },
    );
  }

  void _editTemplateDialog(int index) {
    final template = templates[index];
    selectedTemplateName = template["name"];
    List<String> tempSelectedExercises =
        List<String>.from(template["exercises"]);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text("テンプレート編集", style: TextStyle(color: Colors.white)),
          content: StatefulBuilder(
            builder: (context, setState) {
              final customExerciseController = TextEditingController();

              final defaultExercises =
                  exerciseGroups.values.expand((e) => e).toSet();

              final customExercises = tempSelectedExercises
                  .where((e) => !defaultExercises.contains(e))
                  .toList();

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ▼ テンプレート名選択
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[850],
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: Colors.yellowAccent, width: 2),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButton<String>(
                        value: selectedTemplateName,
                        hint: Text(
                          "テンプレート名を選択",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 16,
                          ),
                        ),
                        items: templateNames.map((name) {
                          return DropdownMenuItem<String>(
                            value: name,
                            child: Text(
                              name,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedTemplateName = value;
                          });
                        },
                        isExpanded: true,
                        style: TextStyle(color: Colors.black, fontSize: 16),
                        dropdownColor: Colors.black,
                        icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                      ),
                    ),

                    SizedBox(height: 20),
                    Text("カスタム種目を追加", style: TextStyle(color: Colors.white)),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: customExerciseController,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "カスタム種目名を入力",
                              hintStyle: TextStyle(color: Colors.white54),
                              filled: true,
                              fillColor: Colors.grey[800],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            final newExercise =
                                customExerciseController.text.trim();
                            if (newExercise.isNotEmpty &&
                                !tempSelectedExercises.contains(newExercise)) {
                              setState(() {
                                tempSelectedExercises.insert(0, newExercise);
                                customExerciseController.clear();
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.yellowAccent,
                            foregroundColor: Colors.black,
                          ),
                          child: Text("追加"),
                        ),
                      ],
                    ),

                    SizedBox(height: 20),
                    Text("種目を選択",
                        style:
                            TextStyle(color: Color.fromARGB(255, 209, 209, 0))),

                    SizedBox(height: 20),
                    // ▼ カスタム種目（上に表示）
                    if (customExercises.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("カスタム種目",
                              style: TextStyle(
                                  color: Colors.yellowAccent,
                                  fontWeight: FontWeight.bold)),
                          ...customExercises.map((exercise) {
                            return CheckboxListTile(
                              value: tempSelectedExercises.contains(exercise),
                              title: Text(exercise,
                                  style: TextStyle(color: Colors.white)),
                              activeColor: Colors.yellow,
                              checkColor: Colors.black,
                              onChanged: (value) {
                                setState(() {
                                  if (value == true) {
                                    tempSelectedExercises.add(exercise);
                                  } else {
                                    tempSelectedExercises.remove(exercise);
                                  }
                                });
                              },
                            );
                          }).toList(),
                          SizedBox(height: 16),
                        ],
                      ),

                    // ▼ デフォルト種目（部位別）
                    ...exerciseGroups.entries.map((group) {
                      final part = group.key;
                      final exercises = group.value;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              part,
                              style: TextStyle(
                                  color: Colors.yellowAccent,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          ...exercises.map((exercise) {
                            return CheckboxListTile(
                              value: tempSelectedExercises.contains(exercise),
                              title: Text(exercise,
                                  style: TextStyle(color: Colors.white)),
                              activeColor: Colors.yellow,
                              checkColor: Colors.black,
                              onChanged: (value) {
                                setState(() {
                                  if (value == true) {
                                    tempSelectedExercises.add(exercise);
                                  } else {
                                    tempSelectedExercises.remove(exercise);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ],
                      );
                    }).toList()
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              child: Text("キャンセル", style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              onPressed: () {
                final newName = selectedTemplateName;
                if (newName != null &&
                    newName.isNotEmpty &&
                    tempSelectedExercises.isNotEmpty) {
                  setState(() {
                    templates[index] = {
                      "name": newName,
                      "exercises": List<String>.from(tempSelectedExercises),
                    };
                  });

                  UseTemplates.saveTemplate(
                      deviceId, newName, tempSelectedExercises);

                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellowAccent,
                foregroundColor: Colors.black,
              ),
              child: Text("保存"),
            ),
          ],
        );
      },
    );
  }

  void loadTemplates() async {
    templates = await UseTemplates.fetchTemplate(deviceId);

    setState(() {
      templates;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(
        title: 'トレーニング記録',
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HistoryRecording()),
                          );
                        },
                        icon: Icon(Icons.fitness_center),
                        label: Text("トレーニング履歴"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[800],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16), // ✅ 丸み
                          ),
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    // SizedBox(width: 12),
                    // Expanded(
                    //   child: ElevatedButton.icon(
                    //     onPressed: () {
                    //       Navigator.push(
                    //         context,
                    //         MaterialPageRoute(
                    //             builder: (context) => ToolSelectionScreen()),
                    //       );
                    //     },
                    //     icon: Icon(Icons.people),
                    //     label: Text("テンプレート例"),
                    //     style: ElevatedButton.styleFrom(
                    //       backgroundColor: Colors.grey[800],
                    //       foregroundColor: Colors.white,
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(16), // ✅ 丸み
                    //       ),
                    //       padding: EdgeInsets.symmetric(vertical: 14),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
                SizedBox(height: 12),
              ],
            ),
          ),
          Text("テンプレートをタップしてトレーニングを記録しよう",
              style: TextStyle(
                  color: Colors.grey[800],
                  fontWeight: FontWeight.bold,
                  fontSize: 14)),
          Divider(color: Colors.grey[800]),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                  padding: EdgeInsets.all(8),
                  child: Text("テンプレート",
                      style: TextStyle(
                          color: Color.fromARGB(255, 209, 209, 0),
                          fontSize: 20,
                          fontWeight: FontWeight.bold))),
              Padding(
                padding: EdgeInsets.all(8),
                child: IconButton(
                    onPressed: () {
                      _showTemplateDialog();
                    },
                    icon: Icon(
                      Icons.add,
                      color: Color.fromARGB(255, 209, 209, 0),
                    )),
              ),
            ],
          ),
          templates.isNotEmpty
              ? Expanded(
                  flex: 1,
                  child: ListView.builder(
                    itemCount: templates.length,
                    itemBuilder: (context, index) {
                      final template = templates[index];
                      return Card(
                        color: Colors.grey[900],
                        margin: EdgeInsets.all(8),
                        child: ListTile(
                          title: Text(template["name"],
                              style: TextStyle(color: Colors.white)),
                          subtitle: Text(
                            (template["exercises"] as List<String>).join(", "),
                            style: TextStyle(color: Colors.white70),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.white),
                                onPressed: () => _editTemplateDialog(index),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () =>
                                    _confirmDeleteTemplate(index), // 削除ボタン
                              ),
                              Icon(Icons.chevron_right, color: Colors.white),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RecordTrainingScreen(
                                  exercises: template["exercises"],
                                  name: template["name"],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                )
              : Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("種目ごとのテンプレートを作成しましょう",
                          style: TextStyle(
                              color: Color.fromARGB(255, 209, 209, 0),
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                )
        ],
      ),
    );
  }
}
