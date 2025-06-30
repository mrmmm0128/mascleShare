import 'package:flutter/material.dart';
import 'package:muscle_share/methods/fetchMyPhoto.dart';
import 'package:table_calendar/table_calendar.dart';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({super.key});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  late List<Map<String, String>> myWorkout = [];
  late List<Map<String, String>> originMyWorkout = [];
  List<Map<String, dynamic>> firstLastData = [{}];

  final List<String> categories = [
    'All',
    'Chest',
    'Back',
    'Legs',
    'Arms',
    "Shoulder",
    "hip",
    "Aerobic",
    "Upper body",
    "Lower body",
    "push",
    "pull"
  ];
  bool isLoading = true;
  String streek = "";
  String selectedCategory = 'All';
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _dayKeys = {}; // "2024-04-29": GlobalKey()

  @override
  void initState() {
    super.initState();
    initializeList();
  }

  void initializeList() async {
    myWorkout = originMyWorkout = await fetchHistory();
    await takeFirstLast();
    print(myWorkout);
    setState(() {
      isLoading = false;
      streek = myWorkout.length.toString();
    });
  }

  void _jumpToDate(String dateStr) {
    final key = _dayKeys[dateStr];
    if (key != null && key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  void _showCalendarDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          // AlertDialog → Dialog に変更
          backgroundColor: Colors.black,
          child: SizedBox(
            height: 450, // 明示的に高さと幅を指定
            width: 350,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    "Select a Date",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
                Expanded(
                  child: TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: DateTime.now(),
                    calendarFormat: CalendarFormat.month,
                    eventLoader: (day) {
                      final formatted = _formatDate(day);
                      return myWorkout
                          .where((w) => w["day"] == formatted)
                          .toList();
                    },
                    calendarStyle: CalendarStyle(
                      defaultTextStyle:
                          const TextStyle(color: Colors.white), // ← 普通の日
                      weekendTextStyle:
                          const TextStyle(color: Colors.white70), // ← 土日
                      outsideTextStyle:
                          const TextStyle(color: Colors.grey), // ← 前月・次月の日付
                      selectedDecoration: const BoxDecoration(
                        color: Color.fromARGB(255, 209, 209, 0), // 黄色で選択
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: Colors.white24,
                        shape: BoxShape.circle,
                      ),
                      markersMaxCount: 3,
                      markerDecoration: BoxDecoration(
                        color: Colors.yellow.shade700,
                        shape: BoxShape.circle,
                      ),
                    ),
                    headerStyle: const HeaderStyle(
                      titleTextStyle: TextStyle(color: Colors.white),
                      formatButtonTextStyle: TextStyle(color: Colors.white),
                      formatButtonDecoration: BoxDecoration(
                        color: Color.fromARGB(255, 209, 209, 0),
                        borderRadius: BorderRadius.all(Radius.circular(12.0)),
                      ),
                      leftChevronIcon:
                          Icon(Icons.chevron_left, color: Colors.white),
                      rightChevronIcon:
                          Icon(Icons.chevron_right, color: Colors.white),
                    ),
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, focusedDay) {
                        final formatted = _formatDate(day);
                        final hasWorkout =
                            myWorkout.any((w) => w["day"] == formatted);
                        return Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${day.day}',
                            style: TextStyle(
                              color:
                                  hasWorkout ? Colors.yellow : Colors.white60,
                              fontWeight: hasWorkout
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        );
                      },
                    ),
                    onDaySelected: (selectedDay, _) {
                      Navigator.pop(context);
                      _jumpToDate(_formatDate(selectedDay));
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showPastMusclePhotos() {
    if (myWorkout[0]["url"] != "") {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.black,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Past Workout Records",
                  style: TextStyle(
                      color: Color.fromARGB(255, 209, 209, 0),
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today,
                      color: Color.fromARGB(255, 209, 209, 0)),
                  onPressed: () => _showCalendarDialog(context),
                )
              ],
            ),
            content: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: myWorkout.map((record) {
                  final dateKey = record["day"];
                  print("a$dateKey");
                  final key = GlobalKey();
                  _dayKeys[dateKey!] = key;

                  return Padding(
                    key: key,
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        record["url"] != null && record["url"]!.isNotEmpty
                            ? Image.network(record["url"]!)
                            : Container(
                                height: 150,
                                width: double.infinity,
                                color: Colors.grey.shade800,
                                alignment: Alignment.center,
                                child: const Text("No image",
                                    style: TextStyle(color: Colors.white)),
                              ),
                        const SizedBox(height: 4),
                        Text(
                          "Date: ${record["day"] ?? 'Unknown'}",
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const Divider(color: Colors.grey),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  "Close",
                  style: TextStyle(color: Color.fromARGB(255, 209, 209, 0)),
                ),
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('まだ写真が記録されていません')),
      );
    }
  }

  Widget buildPhotoTile(String title, String? url) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color.fromARGB(255, 209, 209, 0),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[200],
          ),
          child: url != null && url.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    url,
                    fit: BoxFit.cover,
                  ),
                )
              : const Icon(
                  Icons.image_not_supported,
                  size: 50,
                  color: Colors.grey,
                ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Future<void> changeCategry(String newCategoly) async {
    if (newCategoly == "All") {
      myWorkout = originMyWorkout;
    } else {
      myWorkout =
          originMyWorkout.where((map) => map["mascle"] == newCategoly).toList();
      streek = myWorkout.length.toString();

      if (myWorkout.isEmpty) {
        myWorkout = [
          {"url": "", "name": "", "startDay": ""}
        ];
      }

      print(myWorkout);
    }
  }

  Future<void> takeFirstLast() async {
    if (myWorkout.isNotEmpty) {
      firstLastData[0] = myWorkout[myWorkout.length - 1];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: const Color.fromARGB(255, 209, 209, 0)),
        elevation: 0,
        title: Text(
          'Your workout',
          style: TextStyle(
              color: const Color.fromARGB(255, 209, 209, 0),
              fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: Colors.black,
      body: isLoading
          ? Center(
              child: Theme(
                data: ThemeData(primarySwatch: Colors.yellow),
                child: const CircularProgressIndicator(),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 9, horizontal: 9),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: Colors.grey.withOpacity(0.3)),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            child: DropdownButton<String>(
                              value: selectedCategory,
                              dropdownColor: Colors.black,
                              borderRadius: BorderRadius.circular(12),
                              onChanged: (String? newValue) {
                                setState(() async {
                                  selectedCategory = newValue!;
                                  await changeCategry(selectedCategory);
                                  takeFirstLast();
                                  streek = myWorkout.length.toString();
                                  firstLastData;
                                });
                              },
                              underline: SizedBox(),
                              icon: Icon(Icons.arrow_drop_down,
                                  color: Color.fromARGB(
                                      255, 209, 209, 0)), // 👈 アイコンの色を黄色に
                              isDense: true,
                              items: categories.map<DropdownMenuItem<String>>(
                                  (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Center(
                                    child: Text(
                                      value,
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 209, 209, 0),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(9),
                    child: Text(
                      "Latest training",
                      style: TextStyle(
                          color: Color.fromARGB(255, 209, 209, 0),
                          fontSize: 30,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 写真追加用カード
                        Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 18),
                              child: Container(
                                  width: MediaQuery.of(context).size.width *
                                      5 /
                                      11, // 好きな幅
                                  height: MediaQuery.of(context).size.width *
                                      8 /
                                      11,
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(20), // 角を丸く
                                    color:
                                        Colors.grey[200], // 背景色（画像読み込み前などに見える）
                                  ),
                                  clipBehavior: Clip.antiAlias, // 画像を角丸に合わせてカット
                                  child: myWorkout[0]["url"] != ""
                                      ? Image.network(
                                          myWorkout[0]["url"]!,
                                          fit: BoxFit
                                              .fitHeight, // 縦にフィット（横が余ってもOK）
                                        )
                                      : Icon(
                                          Icons
                                              .image_not_supported, // 適当なアイコン（変更可能）
                                          size: 50, // アイコンのサイズ
                                          color: Colors.grey, // アイコンの色
                                        )),
                            )
                          ],
                        ),
                        const SizedBox(width: 20),
                        // Streek情報
                        Expanded(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text("Total training",
                                    style: TextStyle(
                                        color: Color.fromARGB(255, 209, 209, 0),
                                        fontSize: 20)),
                                const SizedBox(height: 10),
                                myWorkout[0]["url"] != ""
                                    ? Text(
                                        streek,
                                        style: TextStyle(
                                          fontSize: 64,
                                          color:
                                              Color.fromARGB(255, 209, 209, 0),
                                        ),
                                      )
                                    : Text(
                                        "0",
                                        style: TextStyle(
                                          fontSize: 64,
                                          color:
                                              Color.fromARGB(255, 209, 209, 0),
                                        ),
                                      )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),

                  // Past
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                    child: Text("History",
                        style: TextStyle(
                          color: Color.fromARGB(255, 209, 209, 0),
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        )),
                  ),

                  const SizedBox(height: 8),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        splashColor: Colors.grey[900], // タップエフェクト色
                        highlightColor: Colors.transparent,
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 209, 209, 0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4, // 少し浮かせる
                          shadowColor: Colors.black.withOpacity(0.4),
                        ),
                        onPressed: () {
                          showPastMusclePhotos();
                        },
                        child: const Text(
                          'show your past muscle',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 30,
                  ),
                  Divider(
                    thickness: 5,
                    endIndent: 0,
                    color: Colors.grey[900],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    "First day of Your trainig",
                    style: TextStyle(
                      color: Color.fromARGB(255, 209, 209, 0),
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.all(16),
                      child: firstLastData.isNotEmpty
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const SizedBox(
                                  width: 20,
                                ),
                                firstLastData[0]["day"] != ""
                                    ? Text(
                                        firstLastData[0]["day"] ??
                                            "No contents",
                                        style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 209, 209, 0),
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : Text(
                                        "No contents",
                                        style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 209, 209, 0),
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(
                                        20), // 角丸をInkWellにも伝える

                                    child: Stack(
                                      children: [
                                        Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              5 /
                                              11, // 好きな幅
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              8 /
                                              11,

                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                                20), // 角を丸く
                                            color: Colors.grey[
                                                200], // 背景色（画像読み込み前などに見える）
                                          ),
                                          clipBehavior:
                                              Clip.antiAlias, // 画像を角丸に合わせてカット
                                          child: firstLastData[0]["url"] != ""
                                              ? Image.network(
                                                  firstLastData[0]["url"]!,
                                                  fit: BoxFit
                                                      .fitHeight, // 縦にフィット（横が余ってもOK）
                                                )
                                              : Icon(
                                                  Icons
                                                      .image_not_supported, // 適当なアイコン（変更可能）
                                                  size: 50, // アイコンのサイズ
                                                  color: Colors.grey, // アイコンの色
                                                ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            )
                          : Text(
                              "No contents",
                              style: TextStyle(
                                color: Color.fromARGB(255, 209, 209, 0),
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            )),
                ],
              ),
            ),
    );
  }
}
