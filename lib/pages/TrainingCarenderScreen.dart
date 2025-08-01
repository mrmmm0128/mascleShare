import 'package:flutter/material.dart';
import 'package:muscle_share/pages/ExcersizeVolumeChart.dart';
import 'package:muscle_share/pages/FriendTrainingDetailScreen.dart';
import 'package:muscle_share/pages/Header.dart';
import 'package:muscle_share/pages/HistoryRecording.dart';
import 'package:muscle_share/pages/TrainingDetailScreen.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:muscle_share/methods/getDeviceId.dart';

class TrainingCalendarScreen extends StatefulWidget {
  const TrainingCalendarScreen({Key? key}) : super(key: key);

  @override
  State<TrainingCalendarScreen> createState() => _TrainingCalendarScreenState();
}

class _TrainingCalendarScreenState extends State<TrainingCalendarScreen> {
  //Set<DateTime> _trainingDates = {};
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<String, Map<String, int>> _trainingDateUserMap = {};
  String myId = "";

  @override
  void initState() {
    super.initState();
    _loadTrainingDates();
  }

  Future<void> _loadTrainingDates() async {
    myId = await getDeviceUUID();

    // 自分と友人一覧を取得（例: friends コレクションを使う）
    final friendsSnapshot = await FirebaseFirestore.instance
        .collection("friends_of_$myId") // 例: "friends_of_abc123"
        .get();

    List<String> allUserIds = [myId];
    allUserIds.addAll(friendsSnapshot.docs.map((doc) => doc.id));

    // 🔥 Map<Date, Map<userId, count>>
    Map<String, Map<String, int>> trainingMap = {};

    for (String userId in allUserIds) {
      final doc = await FirebaseFirestore.instance
          .collection(userId)
          .doc('history')
          .get();

      if (doc.exists && doc.data() != null) {
        doc.data()!.forEach((key, value) {
          final dateStr = key.split(' ').first;
          trainingMap.putIfAbsent(dateStr, () => {});
          trainingMap[dateStr]![userId] =
              (trainingMap[dateStr]![userId] ?? 0) + 1;
        });
      }
    }

    setState(() {
      _trainingDateUserMap = trainingMap;
    });
  }

  void _showTrainingDetailPopup(
      BuildContext context, String date, Map<String, int> userMap) async {
    Map<String, String> nameMap = {};
    Map<String, List<String>> exerciseMap = {};
    Map<String, Map<String, dynamic>> trainingDetailMap = {}; // 🔸← データ渡す用
    Map<String, String> linkMap = {}; // ← 追加

    for (String uid in userMap.keys) {
      // プロフィール
      final profileDoc =
          await FirebaseFirestore.instance.collection(uid).doc('profile').get();
      final name = profileDoc.data()?['name'] ?? 'Unknown';
      final link = profileDoc.data()?['photo'] ?? 'Unknown';
      nameMap[uid] = name;
      linkMap[uid] = link;

      // 履歴ドキュメント取得
      final historyDoc =
          await FirebaseFirestore.instance.collection(uid).doc('history').get();

      if (historyDoc.exists && historyDoc.data() != null) {
        final data = historyDoc.data()!;
        List<String> exercises = [];
        Map<String, dynamic> combinedExerciseData = {};
        double totalVolume = 0.0;

        // date（例: "2025-07-27"）で始まるエントリだけ取得
        final matchingEntries =
            data.entries.where((e) => e.key.startsWith(date)).toList();

        for (var entry in matchingEntries) {
          final key = entry.key; // 例: "2025-07-27 Back"
          final value = Map<String, dynamic>.from(entry.value);

          for (var exName in value.keys) {
            if (exName == "isPublic") continue;

            final sets = value[exName];
            if (sets is List) {
              exercises.add(exName);
              combinedExerciseData[exName] = sets;

              for (var set in sets) {
                if (set is Map) {
                  final reps = (set["reps"] ?? 0).toDouble();
                  final weight = (set["weight"] ?? 0).toDouble();
                  totalVolume += weight * reps;
                }
              }
            }
          }

          trainingDetailMap["$uid|$key"] = {
            "rawTraining": {
              "totalVolume": totalVolume.toStringAsFixed(1),
              "data": combinedExerciseData.map((key, value) {
                return MapEntry(key.toString(), value); // 🔸 key を String に変換
              }),
            }
          };
        }

        exerciseMap[uid] = exercises;
      } else {
        exerciseMap[uid] = [];
      }
    }
    print(trainingDetailMap);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.black,
        title:
            Text("$date のトレーニング", style: TextStyle(color: Colors.yellowAccent)),
        content: Container(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: trainingDetailMap.entries.map((entry) {
                final key = entry.key;
                final parts = key.split('|');
                final uid = parts[0];
                final dateWithPart = parts[1];
                final name = nameMap[uid] ?? uid;
                final imageUrl = linkMap[uid] ?? '';
                final part = dateWithPart.split(' ').length > 1
                    ? dateWithPart.split(' ')[1]
                    : '部位';

                final detail = entry.value;

                return Card(
                  color: Colors.grey[900],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  margin: EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.pop(context);
                      if (uid != myId) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FriendTrainingDetailScreen(
                              training: detail["rawTraining"],
                              friendDeviceId: uid,
                            ),
                          ),
                        );
                      } else {
                        print(part);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TrainingDetailScreen(
                              date: dateWithPart,
                              templateName: part,
                              totalVolume: double.tryParse(detail["rawTraining"]
                                          ["totalVolume"]
                                      .toString()) ??
                                  0.0,
                              trainingData: detail["rawTraining"]["data"],
                            ),
                          ),
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: ListTile(
                          leading: CircleAvatar(
                            radius: 20,
                            backgroundImage: imageUrl.isNotEmpty
                                ? NetworkImage(imageUrl)
                                : AssetImage('assets/default_icon.png')
                                    as ImageProvider,
                          ),
                          title: uid != myId
                              ? Text(
                                  "$name が $part のトレーニングをしました",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 15,
                                  ),
                                )
                              : Text(
                                  "あなた が $part のトレーニングをしました",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 15,
                                  ),
                                )),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("閉じる", style: TextStyle(color: Colors.yellowAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: Header(
        title: 'トレーニングレポート',
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 15),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8, // ✅ 横幅80%
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HistoryRecording()),
                  );
                },
                icon: Icon(Icons.fitness_center),
                label: Text("自分のトレーニング履歴"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Text("友人とトレーニングの頻度を比較しよう",
                style: TextStyle(
                    color: Colors.grey[800],
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
            Divider(color: Colors.grey[800]),
            Padding(
              padding: EdgeInsets.all(10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "トレーニングカレンダー",
                  style: TextStyle(
                    color: Color.fromARGB(255, 209, 209, 0),
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TableCalendar(
                focusedDay: _focusedDay,
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                calendarStyle: const CalendarStyle(
                  weekendTextStyle: TextStyle(color: Colors.redAccent),
                  defaultTextStyle: TextStyle(color: Colors.white),
                  outsideTextStyle: TextStyle(color: Colors.grey),
                  todayDecoration: BoxDecoration(
                    color: Colors.yellow,
                    shape: BoxShape.circle,
                  ),
                ),
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekendStyle: TextStyle(color: Colors.redAccent),
                  weekdayStyle: TextStyle(color: Colors.white),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle:
                      TextStyle(color: Colors.yellowAccent, fontSize: 18),
                  leftChevronIcon:
                      Icon(Icons.chevron_left, color: Colors.white),
                  rightChevronIcon:
                      Icon(Icons.chevron_right, color: Colors.white),
                ),
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, day, events) {
                    final dateKey = day.toIso8601String().split('T').first;
                    final userMap = _trainingDateUserMap[dateKey];
                    if (userMap != null && userMap.isNotEmpty) {
                      return GestureDetector(
                        onTap: () =>
                            _showTrainingDetailPopup(context, dateKey, userMap),
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orangeAccent.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.withOpacity(0.6),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('🔥',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(width: 4),
                              Text('${userMap.length}',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black)),
                            ],
                          ),
                        ),
                      );
                    }
                    return null;
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text("種目ごとのMaxRMの成長を確認しましょう",
                style: TextStyle(
                    color: Colors.grey[800],
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
            Divider(color: Colors.grey[800]),
            Padding(
              padding: EdgeInsets.all(10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "MaxRM推移",
                  style: TextStyle(
                    color: Color.fromARGB(255, 209, 209, 0),
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            ExerciseVolumeChart(),
          ],
        ),
      ),
    );
  }
}
