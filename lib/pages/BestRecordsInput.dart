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
      appBar: Header(
        title: '最高記録を入力しましょう',
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12),
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
                        icon:
                            Icon(Icons.add_circle_outline, color: Colors.white),
                        onPressed: () => _addExercise(part),
                      ),
                    ],
                  ),
                  ...bestRecords[part]!.asMap().entries.map((entry) {
                    int index = entry.key;
                    Map<String, dynamic> record = entry.value;

                    return Card(
                      color: Color.fromARGB(255, 30, 30, 30),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      margin: EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 12),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                initialValue: record['name'] ?? '',
                                decoration: _inputDecoration("種目名"),
                                style: TextStyle(color: Colors.black),
                                onChanged: (value) {
                                  bestRecords[part]![index]['name'] = value;
                                },
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                value: record['weight'] ?? 0,
                                decoration: _inputDecoration("kg"),
                                items: List.generate(41, (i) {
                                  int kg = i * 5;
                                  return DropdownMenuItem(
                                      value: kg, child: Text("$kg kg"));
                                }),
                                onChanged: (value) {
                                  bestRecords[part]![index]['weight'] =
                                      value ?? 0;
                                },
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                value: record['reps'] ?? 1,
                                decoration: _inputDecoration("回数"),
                                items: List.generate(30, (i) {
                                  int reps = i + 1;
                                  return DropdownMenuItem(
                                      value: reps, child: Text("$reps 回"));
                                }),
                                onChanged: (value) {
                                  bestRecords[part]![index]['reps'] =
                                      value ?? 1;
                                },
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () => _removeExercise(part, index),
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
