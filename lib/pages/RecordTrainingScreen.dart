import 'package:flutter/material.dart';
import 'package:muscle_share/methods/UseTemplates.dart';
import 'package:muscle_share/methods/GetDeviceId.dart';

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
  final Map<String, List<Map<String, int>>> exerciseData = {};
  String deviceId = "";
  late List<String> localExercises;

  final List<int> _RepOptions = List.generate(61, (index) => index);
  final List<int> _weightOptions = List.generate(300, (index) => index);

  @override
  void initState() {
    super.initState();
    deviceId = getDeviceIDweb();
    localExercises = List.from(widget.exercises);
    for (String exercise in localExercises) {
      setCounts[exercise] = 1;
      exerciseData[exercise] = [
        {"weight": 0, "reps": 0}
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        backgroundColor: Colors.yellowAccent,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
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
                                            child: DropdownButtonFormField<int>(
                                              value: data[i]["weight"],
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
                                              items:
                                                  _weightOptions.map((weight) {
                                                return DropdownMenuItem<int>(
                                                  value: weight,
                                                  child: Text('$weight kg'),
                                                );
                                              }).toList(),
                                              onChanged: (val) {
                                                setState(() {
                                                  data[i]["weight"] = val!;
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
                              data.add({"weight": 0, "reps": 0});
                            });
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
                print(exerciseData);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('your recording has been saved')),
                );
                UseTemplates.saveTraining(deviceId, widget.name, exerciseData);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellowAccent,
                foregroundColor: Colors.black,
                minimumSize: Size(MediaQuery.of(context).size.width / 6, 48),
              ),
              child: Text(
                "save",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
