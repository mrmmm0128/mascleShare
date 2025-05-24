import 'package:flutter/material.dart';
import 'package:muscle_share/methods/fetchInfoProfile.dart';

class OtherBestRecordsInput extends StatefulWidget {
  final String deviceId; // ← 受け取りたい変数

  const OtherBestRecordsInput(
      {super.key, required this.deviceId}); // ← コンストラクタで受け取る

  @override
  _OtherRecordsState createState() => _OtherRecordsState();
}

class _OtherRecordsState extends State<OtherBestRecordsInput> {
  final List<String> bodyParts = ['胸', '背中', '脚', '上腕二頭筋', '上腕三頭筋', '腹筋'];
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
          'Best',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var part in bodyParts)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(part,
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 209, 209, 0))),
                    ],
                  ),
                  ...bestRecords[part]!.asMap().entries.map((entry) {
                    Map<String, dynamic> record = entry.value;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              record['name'] ?? '',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '${record['weight'] ?? 0} kg',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '${record['reps'] ?? 0} 回',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  Divider(color: Colors.grey.shade600)
                ],
              ),
            SizedBox(height: 20),
          ],
        ),
      ),
      backgroundColor: Colors.black,
    );
  }
}
