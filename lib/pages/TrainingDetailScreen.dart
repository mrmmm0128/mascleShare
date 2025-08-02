import 'package:flutter/material.dart';
import 'package:muscle_share/pages/EditTrainingScreen.dart';
import 'package:muscle_share/pages/Header.dart';

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
    final visibleExercises = exercises.keys
        .where((key) =>
            key != "like" &&
            key != "comment" &&
            key != "isPublic" &&
            key != "myComment")
        .toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: Header(
        title: 'トレーニング詳細',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date,
                  style: TextStyle(color: Colors.yellowAccent, fontSize: 18),
                ),
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.yellowAccent),
                  onPressed: () {
                    List<String> parts = date.split(' ');

                    String school = parts.length > 1 ? parts[0] : '';
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EditTrainingScreen(
                                name: templateName,
                                trainingData: exercises,
                                date: school,
                              )),
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 8),
            Text("Total Volume: ${totalVolume.toStringAsFixed(2)} kg·回",
                style: TextStyle(color: Colors.yellowAccent, fontSize: 18)),
            Divider(color: Colors.yellowAccent),
            SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: visibleExercises.length,
                itemBuilder: (context, index) {
                  final exerciseName = visibleExercises[index];
                  final sets = exercises[exerciseName] as List<dynamic>;

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

                            final rm = weight * (1 + 0.0333 * reps);

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
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Text("${i + 1}セット目",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14)),
                                          SizedBox(width: 10),
                                          Text(
                                            "${weight}kg × ${reps}回",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 15),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (rm == maxEstimatedRm)
                                      Text(
                                        "🌟 Max RM",
                                        style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 209, 209, 0),
                                            fontWeight: FontWeight.bold),
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
