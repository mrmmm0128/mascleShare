import 'package:flutter/material.dart';
import 'package:muscle_share/methods/FetchInfoProfile.dart';

class OtherBestRecordsInput extends StatefulWidget {
  final String deviceId; // ← 受け取りたい変数

  const OtherBestRecordsInput(
      {super.key, required this.deviceId}); // ← コンストラクタで受け取る

  @override
  _OtherRecordsState createState() => _OtherRecordsState();
}

class _OtherRecordsState extends State<OtherBestRecordsInput> {
  final List<String> bodyParts = ['胸', '背中', '脚', '腕', '腹筋'];
  bool _isLoading = true;
  Map<String, List<Map<String, dynamic>>> bestRecords = {};

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    final data = await fetchBestRecords(widget.deviceId);
    // 各部位がなければ空リストで初期化

    setState(() {
      bestRecords = data;
      _isLoading = false;
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
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 209, 209, 0),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          'Best Records',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: Colors.black,
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: bodyParts.length,
        itemBuilder: (context, index) {
          String part = bodyParts[index];
          List<Map<String, dynamic>> records = bestRecords[part] ?? [];

          return Card(
            color: Color.fromARGB(255, 30, 30, 30),
            margin: EdgeInsets.only(bottom: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
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
                    ],
                  ),
                  SizedBox(height: 6),
                  for (var record in records)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              record['name'] ?? '',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ),
                          Text(
                            '${record['weight'] ?? 0}kg',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                          SizedBox(width: 10),
                          Text(
                            '${record['reps'] ?? 0}回',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
