import 'package:flutter/material.dart';

class TrainingDetailScreen extends StatelessWidget {
  final String date;
  final String templateName;
  final double totalVolume;
  final Map<String, dynamic> trainingData;

  const TrainingDetailScreen({
    Key? key,
    required this.date,
    required this.templateName,
    required this.totalVolume,
    required this.trainingData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 'name'キー以外をフィルタして表示用のMapを作る
    Map<String, dynamic> exercises = Map.from(trainingData)..remove('name');

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "Training Details",
          style: TextStyle(color: Colors.yellowAccent),
        ),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.yellowAccent),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(date,
                style: TextStyle(color: Colors.yellowAccent, fontSize: 18)),
            SizedBox(height: 8),
            SizedBox(height: 8),
            Text("Total Volume: ${totalVolume.toStringAsFixed(2)} kg·回",
                style: TextStyle(color: Colors.yellowAccent, fontSize: 18)),
            Divider(color: Colors.yellowAccent),
            SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: exercises.keys.length,
                itemBuilder: (context, index) {
                  final exerciseName = exercises.keys.elementAt(index);
                  final sets = exercises[exerciseName] as List<dynamic>;

// ▼ 最大推定1RMの計算（Epley式）
                  final maxEstimatedRm = sets.map((set) {
                    final weight = set['weight'] ?? 0;
                    final reps = set['reps'] ?? 0;
                    return weight * (1 + 0.0333 * reps);
                  }).fold<double>(0.0, (prev, rm) => rm > prev ? rm : prev);

                  return Card(
                    key: ValueKey(exerciseName),
                    color: Colors.grey[900],
                    margin: const EdgeInsets.only(bottom: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  exerciseName,
                                  style: TextStyle(
                                    color: Colors.yellowAccent,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Icon(Icons.fitness_center, color: Colors.white54),
                            ],
                          ),
                          SizedBox(height: 6),
                          Text(
                            "推定MaxRM: ${maxEstimatedRm.toStringAsFixed(1)} kg",
                            style:
                                TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          SizedBox(height: 12),
                          ...sets.asMap().entries.map((entry) {
                            final i = entry.key;
                            final set = entry.value;
                            final weight = set['weight'] ?? 0;
                            final reps = set['reps'] ?? 0;

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[800],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("${i + 1}セット目",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 14)),
                                    SizedBox(width: 10),
                                    Text(
                                      "${weight}kg × ${reps}回",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 15),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
