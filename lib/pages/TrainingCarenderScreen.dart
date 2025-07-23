import 'package:flutter/material.dart';
import 'package:muscle_share/pages/ExcersizeVolumeChart.dart';
import 'package:muscle_share/pages/Header.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:muscle_share/methods/getDeviceId.dart';

class TrainingCalendarScreen extends StatefulWidget {
  const TrainingCalendarScreen({Key? key}) : super(key: key);

  @override
  State<TrainingCalendarScreen> createState() => _TrainingCalendarScreenState();
}

class _TrainingCalendarScreenState extends State<TrainingCalendarScreen> {
  Set<DateTime> _trainingDates = {};
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _loadTrainingDates();
  }

  Future<void> _loadTrainingDates() async {
    String deviceId = await getDeviceIDweb();
    final doc = await FirebaseFirestore.instance
        .collection(deviceId)
        .doc('history')
        .get();

    if (doc.exists) {
      final data = doc.data();
      if (data != null) {
        Set<DateTime> dates = data.keys
            .map((key) => key.split(' ').first) // 日付部分だけ抽出
            .map((dateString) => DateTime.tryParse(dateString))
            .whereType<DateTime>()
            .toSet();

        setState(() {
          _trainingDates = dates;
        });
      }
    }
  }

  bool _isTrainingDay(DateTime day) {
    return _trainingDates.any(
      (d) => d.year == day.year && d.month == day.month && d.day == day.day,
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
                    if (_isTrainingDay(day)) {
                      return Positioned(
                        bottom: 1,
                        child: Text('🔥', style: TextStyle(fontSize: 14)),
                      );
                    }
                    return null;
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity, // 横幅いっぱい
              height: 1,
              color: Colors.grey, // 境界線の色
            ),
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
