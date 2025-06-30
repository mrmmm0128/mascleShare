import 'package:flutter/material.dart';
import 'package:muscle_share/methods/UseTemplates.dart';
import 'package:muscle_share/methods/getDeviceId.dart';
import 'package:muscle_share/pages/TrainingDetailScreen.dart';

class HistoryRecording extends StatefulWidget {
  const HistoryRecording({super.key});

  @override
  State<HistoryRecording> createState() => _HistoryRecording();
}

class _HistoryRecording extends State<HistoryRecording> {
  late String deviceId;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    deviceId = await getDeviceUUID();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // ← 背景色を明示的に黒に設定
      appBar: AppBar(
        title: Text(
          "トレーニング記録",
          style: TextStyle(
            color: Color.fromARGB(255, 209, 209, 0),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Color.fromARGB(255, 209, 209, 0)),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: FutureBuilder<Map<String, dynamic>>(
              future: UseTemplates.fetchHistory(deviceId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final history = snapshot.data!;
                if (history.isEmpty) {
                  return Center(
                    child: Text("記録がありません",
                        style: TextStyle(
                            color: Color.fromARGB(255, 209, 209, 0),
                            fontSize: 18)),
                  );
                }

                return ListView(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  children: history.entries.map((entry) {
                    final date = entry.key;
                    final data = entry.value as Map<String, dynamic>;

                    final templateName = data["name"] ?? "";
                    final totalVolume = data["totalVolume"] ?? 0.0;
                    final trainingData = data["data"] ?? {};

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TrainingDetailScreen(
                              date: date,
                              templateName: templateName,
                              totalVolume: totalVolume,
                              trainingData: trainingData,
                            ),
                          ),
                        );
                      },
                      child: Card(
                        color: Colors.grey[900],
                        margin: EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                        child: Column(
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              title: Text(
                                date,
                                style: TextStyle(
                                  color: Colors.yellowAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text(
                                "総ボリューム: ${totalVolume.toStringAsFixed(2)} kg·回",
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 12),
                              ),
                              trailing: Icon(Icons.fitness_center,
                                  color: Colors.white, size: 24),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
