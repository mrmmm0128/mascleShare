import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:muscle_share/methods/getDeviceId.dart';

enum ChartRange { week, month, year }

class ExerciseVolumeChart extends StatefulWidget {
  final String? initialExercise;

  const ExerciseVolumeChart({super.key, this.initialExercise});

  @override
  State<ExerciseVolumeChart> createState() => _ExerciseVolumeChartState();
}

class _ExerciseVolumeChartState extends State<ExerciseVolumeChart> {
  String? selectedExercise;
  List<String> allExercises = [];
  Map<DateTime, double> volumeByDate = {};
  ChartRange _selectedRange = ChartRange.month;

  @override
  void initState() {
    super.initState();
    selectedExercise = widget.initialExercise;
    _loadExerciseNames();
  }

  Future<void> _loadExerciseNames() async {
    String deviceId = await getDeviceIDweb();
    final doc = await FirebaseFirestore.instance
        .collection(deviceId)
        .doc("history")
        .get();

    if (!doc.exists) return;

    final data = doc.data();
    final Set<String> exerciseSet = {};

    data?.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        value.forEach((exercise, sets) {
          if (sets is List && exercise != "like" && exercise != "comment") {
            exerciseSet.add(exercise);
          }
        });
      }
    });

    setState(() {
      allExercises = exerciseSet.toList();
    });

    if (selectedExercise != null && allExercises.contains(selectedExercise)) {
      _loadMaxRMData(selectedExercise!);
    }
  }

  Future<void> _loadMaxRMData(String exerciseName) async {
    String deviceId = await getDeviceIDweb();
    final doc = await FirebaseFirestore.instance
        .collection(deviceId)
        .doc("history")
        .get();

    final Map<DateTime, double> tempMaxRMByDate = {};

    if (doc.exists) {
      final data = doc.data();

      data?.forEach((key, value) {
        if (value is Map<String, dynamic> && value.containsKey(exerciseName)) {
          final dateStr = key.split(" ").first;
          final rawDate = DateTime.tryParse(dateStr);
          final date = rawDate != null
              ? DateTime(rawDate.year, rawDate.month, rawDate.day)
              : null;

          final sets = value[exerciseName];

          if (date != null && sets is List) {
            int maxRM = 0;

            for (var set in sets) {
              final double weight = (set['weight'] ?? 0).toDouble();
              final double reps = (set['reps'] ?? 0).toDouble();

              if (weight > 0 && reps > 0) {
                final rm = weight * (1 + reps / 30); // Epley式
                if (rm > maxRM) {
                  maxRM = rm.toInt();
                }
              }
            }

            tempMaxRMByDate[date] = maxRM.toDouble();
          }
        }
      });
    }

    print(tempMaxRMByDate);

    setState(() {
      volumeByDate = tempMaxRMByDate;
    });
  }

  List<DateTime> _generateDateRange() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    int days;
    switch (_selectedRange) {
      case ChartRange.week:
        days = 7;
        break;
      case ChartRange.month:
        days = 30;
        break;
      case ChartRange.year:
        days = 365;
        break;
    }
    return List.generate(
        days, (i) => today.subtract(Duration(days: days - i - 1)));
  }

  List<FlSpot> _buildSpots(List<DateTime> range) {
    return range.asMap().entries.map((entry) {
      final index = entry.key;
      final date = entry.value;
      final volume = volumeByDate[date] ?? 0;
      return FlSpot(index.toDouble(), volume);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final dateRange = _generateDateRange();
    final spots = _buildSpots(dateRange);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              DropdownButton<String>(
                dropdownColor: Colors.grey[900],
                value: selectedExercise,
                hint: Text("種目を選択",
                    style: TextStyle(color: Color.fromARGB(255, 209, 209, 0))),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedExercise = value;
                    });
                    _loadMaxRMData(value);
                  }
                },
                items: allExercises.map((exercise) {
                  return DropdownMenuItem<String>(
                    value: exercise,
                    child: Text(exercise,
                        style:
                            TextStyle(color: Color.fromARGB(255, 209, 209, 0))),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              DropdownButton<ChartRange>(
                dropdownColor: Colors.grey[900],
                value: _selectedRange,
                items: ChartRange.values.map((range) {
                  return DropdownMenuItem<ChartRange>(
                    value: range,
                    child: Text(
                      range.toString().split('.').last,
                      style: TextStyle(color: Color.fromARGB(255, 209, 209, 0)),
                    ),
                  );
                }).toList(),
                onChanged: (range) {
                  if (range != null) {
                    setState(() {
                      _selectedRange = range;
                    });
                  }
                },
              ),
            ],
          ),
        ),
        SizedBox(
          height: 300,
          child: spots.isEmpty
              ? Center(
                  child: Text("データがありません",
                      style:
                          TextStyle(color: Color.fromARGB(255, 209, 209, 0))))
              : Padding(
                  padding: const EdgeInsets.all(25),
                  child: LineChart(
                    LineChartData(
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles:
                              SideTitles(showTitles: false), // ← ここで縦軸の値を非表示にする
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: (_selectedRange == ChartRange.week)
                                ? 1
                                : (_selectedRange == ChartRange.month)
                                    ? 5
                                    : 30,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index >= 0 && index < dateRange.length) {
                                return Text(
                                  DateFormat('MM/dd').format(dateRange[index]),
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 209, 209, 0),
                                      fontSize: 10),
                                );
                              }
                              return Text('');
                            },
                          ),
                        ),
                        topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(show: true),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: Colors.white70, width: 1),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          isCurved: false, // ← 点を直線で結ぶ
                          spots: spots,
                          dotData: FlDotData(show: true),
                          color: Colors.yellowAccent,
                        )
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
