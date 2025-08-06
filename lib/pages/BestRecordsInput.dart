import 'package:flutter/material.dart';
import 'package:muscle_share/methods/FetchInfoProfile.dart';
import 'package:muscle_share/methods/getDeviceId.dart';
import 'package:muscle_share/methods/SaveDataForProfile.dart';
import 'package:muscle_share/pages/Header.dart';

class BestRecordsInputScreen extends StatefulWidget {
  @override
  _BestRecordsInputScreenState createState() => _BestRecordsInputScreenState();
}

class _BestRecordsInputScreenState extends State<BestRecordsInputScreen> {
  final List<String> bodyParts = ['胸', '背中', '脚', '腕', '腹筋'];
  bool _isLoading = true;
  Map<String, List<Map<String, dynamic>>> bestRecords = {};

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    String deviceId = await getDeviceUUID();
    final data = await fetchBestRecords(deviceId);
    // 各部位がなければ空リストで初期化

    setState(() {
      bestRecords = data;
      _isLoading = false;
    });
  }

  void _addExercise(String part) {
    setState(() {
      bestRecords[part]!.add({
        'name': '',
        'weight': 0, // int型
        'reps': 1, // int型（最低1回）
      });
    });
  }

  void _removeExercise(String part, int index) {
    setState(() {
      bestRecords[part]!.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            color: Color.fromARGB(255, 209, 209, 0),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: Header(title: '最高記録を入力しましょう'),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(12),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var part in bodyParts)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.fitness_center,
                                    color: Colors.yellowAccent, size: 18),
                                SizedBox(width: 6),
                                Text(
                                  part,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.yellowAccent,
                                  ),
                                ),
                                Spacer(),
                                IconButton(
                                  icon: Icon(Icons.add_circle_outline,
                                      color: Colors.white),
                                  onPressed: () => _addExercise(part),
                                ),
                              ],
                            ),
                            ...bestRecords[part]!.asMap().entries.map((entry) {
                              int index = entry.key;
                              Map<String, dynamic> record = entry.value;

                              final double weightValue =
                                  (record['weight'] is double &&
                                          record['weight'] >= 0)
                                      ? record['weight']
                                      : 0.0;
                              final int repsValue =
                                  (record['reps'] is int && record['reps'] > 0)
                                      ? record['reps']
                                      : 1;

                              return Card(
                                color: Color.fromARGB(255, 30, 30, 30),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                margin: EdgeInsets.only(bottom: 8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 8),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: TextFormField(
                                          initialValue: record['name'] ?? '',
                                          style: TextStyle(
                                              color: Colors
                                                  .yellowAccent), // 入力文字の色
                                          decoration:
                                              _inputDecoration("種目名").copyWith(
                                            filled: true,
                                            fillColor: Colors.grey[850], // 背景色
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.yellow),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.amber,
                                                  width: 2),
                                            ),
                                            hintStyle: TextStyle(
                                                color: Colors
                                                    .white54), // プレースホルダーの色
                                          ),
                                          onChanged: (value) {
                                            bestRecords[part]![index]['name'] =
                                                value;
                                          },
                                        ),
                                      ),
                                      SizedBox(width: 5),
                                      Expanded(
                                        child: DropdownButtonFormField<double>(
                                          value: weightValue,
                                          dropdownColor: Colors.grey[900],
                                          decoration:
                                              _inputDecoration("kg").copyWith(
                                            filled: true,
                                            fillColor: Colors.grey[850],
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.yellow),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.amber,
                                                  width: 2),
                                            ),
                                          ),
                                          style:
                                              TextStyle(color: Colors.yellow),
                                          iconEnabledColor: Colors.yellow,
                                          items: List.generate(601, (i) {
                                            double kg = i * 0.5;
                                            return DropdownMenuItem<double>(
                                              value: kg,
                                              child: Text(
                                                "${kg.toStringAsFixed(1)} kg",
                                                style: TextStyle(
                                                    color: Colors.yellowAccent),
                                              ),
                                            );
                                          }),
                                          onChanged: (value) {
                                            bestRecords[part]![index]
                                                ['weight'] = value ?? 0.0;
                                          },
                                        ),
                                      ),
                                      SizedBox(width: 5),
                                      Expanded(
                                        child: DropdownButtonFormField<int>(
                                          value: repsValue,
                                          dropdownColor: Colors.grey[900],
                                          decoration:
                                              _inputDecoration("回数").copyWith(
                                            filled: true,
                                            fillColor: Colors.grey[850],
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.yellow),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.amber,
                                                  width: 2),
                                            ),
                                          ),
                                          style:
                                              TextStyle(color: Colors.yellow),
                                          iconEnabledColor: Colors.yellow,
                                          items: List.generate(30, (i) {
                                            int reps = i + 1;
                                            return DropdownMenuItem(
                                              value: reps,
                                              child: Text(
                                                "$reps 回",
                                                style: TextStyle(
                                                    color: Colors.yellowAccent),
                                              ),
                                            );
                                          }),
                                          onChanged: (value) {
                                            bestRecords[part]![index]['reps'] =
                                                value ?? 1;
                                          },
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete,
                                            color: Colors.redAccent),
                                        onPressed: () =>
                                            _removeExercise(part, index),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      SizedBox(height: 20),
                      Center(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 209, 209, 0),
                            foregroundColor: Colors.black,
                          ),
                          onPressed: () {
                            saveBestRecords(bestRecords);
                          },
                          icon: Icon(Icons.save),
                          label: Text("保存する"),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[600]),
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
    );
  }
}
