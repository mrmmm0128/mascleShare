import 'package:flutter/material.dart';
import 'package:muscle_share/methods/fetchInfoProfile.dart';
import 'package:muscle_share/methods/getDeviceId.dart';
import 'package:muscle_share/methods/saveDataForProfile.dart';

class BestRecordsInputScreen extends StatefulWidget {
  @override
  _BestRecordsInputScreenState createState() => _BestRecordsInputScreenState();
}

class _BestRecordsInputScreenState extends State<BestRecordsInputScreen> {
  final List<String> bodyParts = ['胸', '背中', '脚', '上腕二頭筋', '上腕三頭筋', '腹筋'];
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
      bestRecords[part]!.add({'name': '', 'weight': ''});
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
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () => _addExercise(part),
                      )
                    ],
                  ),
                  ...bestRecords[part]!.asMap().entries.map((entry) {
                    int index = entry.key;
                    Map<String, dynamic> record = entry.value;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              initialValue: record['name'] ?? '',
                              decoration: InputDecoration(
                                hintText: '種目名',
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              onChanged: (value) {
                                bestRecords[part]![index]['name'] = value;
                              },
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              initialValue: record['weight']?.toString() ?? '',
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: 'kg',
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              onChanged: (value) {
                                bestRecords[part]![index]['weight'] =
                                    int.tryParse(value) ?? 0;
                              },
                            ),
                          ),
                          Expanded(
                            child: TextFormField(
                              initialValue: record['reps']?.toString() ?? '',
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: '回数',
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              onChanged: (value) {
                                bestRecords[part]![index]['reps'] =
                                    int.tryParse(value) ?? 0;
                              },
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeExercise(part, index),
                          )
                        ],
                      ),
                    );
                  }),
                  Divider(color: Colors.grey.shade600)
                ],
              ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  saveBestRecords(bestRecords);
                },
                child: Text("保存する"),
              ),
            )
          ],
        ),
      ),
      backgroundColor: Colors.black,
    );
  }
}
