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
  List<Map<String, String>> firstLastChest = [];
  List<Map<String, String>> firstLastBack = [];
  List<Map<String, String>> firstLastLegs = [];
  List<Map<String, String>> firstLastArms = [];
  final List<String> categories = ['All', 'Chest', 'Back', 'Legs', 'Arms'];
  bool isLoading = true;
  String streek = "";
  String selectedCategory = 'All';
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _dayKeys = {}; // "2024-04-29": GlobalKey()
  Map<String, List<Map<String, dynamic>>> firstLastData = {};

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
    // 現在の日付を取得
    // final now = DateTime.now();

    // 1ヶ月前、3ヶ月前、半年前の日付を計算
    // final oneMonthAgo = now.subtract(Duration(days: 30));
    // final threeMonthsAgo = now.subtract(Duration(days: 90));
    // final sixMonthsAgo = now.subtract(Duration(days: 180));

    // 各期間の写真をフィルタリング

    // final oneMonthPhoto = myWorkout.firstWhere(
    //   (workout) => DateTime.parse(workout["day"] ?? "").isAfter(oneMonthAgo),
    // );

    // final threeMonthsPhoto = myWorkout.firstWhere(
    //   (workout) => DateTime.parse(workout["day"] ?? "").isAfter(threeMonthsAgo),
    // );

    // final sixMonthsPhoto = myWorkout.firstWhere(
    //   (workout) => DateTime.parse(workout["day"] ?? "").isAfter(sixMonthsAgo),
    // );

    // モーダルダイアログを表示
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
                        record["mascle"] == "Chest"
                            ? "Bench press: ${record["bestRecord"] ?? 'N/A'}"
                            : record["mascle"] == "Back"
                                ? "Deadlift: ${record["bestRecord"] ?? 'N/A'}"
                                : "Squat: ${record["bestRecord"] ?? 'N/A'}",
                        style: const TextStyle(color: Colors.white),
                      ),
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

  void changeCategry(String newCategoly) {
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
    List<Map<String, String>> Chest = [];
    List<Map<String, String>> Back = [];
    List<Map<String, String>> Legs = [];
    List<Map<String, String>> Arms = [];
    if (myWorkout.isNotEmpty) {
      for (Map<String, String> workout in myWorkout) {
        if (workout["mascle"] == "Chest") {
          Chest.add(workout);
        }
        if (workout["mascle"] == "Back") {
          Back.add(workout);
        }
        if (workout["mascle"] == "Legs") {
          Legs.add(workout);
        }
        if (workout["mascle"] == "Arms") {
          Arms.add(workout);
        }
      }
      print(Chest);

      if (Chest.isNotEmpty) {
        firstLastChest.addAll([
          Chest[0],
          Chest[Chest.length - 1],
        ]);
      }

      if (Back.isNotEmpty) {
        firstLastBack.addAll([
          Back[0],
          Back[Back.length - 1],
        ]);
      }

      if (Legs.isNotEmpty) {
        firstLastLegs.addAll([
          Legs[0],
          Legs[Legs.length - 1],
        ]);
      }

      if (Arms.isNotEmpty) {
        firstLastArms.addAll([
          Arms[0],
          Arms[Arms.length - 1],
        ]);
      }
      firstLastData = {
        "Chest": firstLastChest,
        "back": firstLastBack,
        "legs": firstLastLegs,
        "Arms": firstLastArms,
      };
    }
  }

  Future selectedPhoto(String mascle, String date) {
    bool boolFirst = true;
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
                backgroundColor: Colors.black,
                content: SizedBox(
                  height: 700,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            mascle,
                            style: const TextStyle(
                              color: Color.fromARGB(255, 209, 209, 0),
                              fontSize: 20,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                boolFirst = !boolFirst;
                              });
                            },
                            child: Text(
                              boolFirst
                                  ? "switch to the latest day"
                                  : "switch to the first day",
                              style: const TextStyle(
                                color: Color.fromARGB(255, 209, 209, 0),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      boolFirst
                          ? Image.network(
                              firstLastData[mascle]![0]["url"],
                              errorBuilder: (context, error, stackTrace) {
                                return Column(
                                  children: const [
                                    Icon(
                                      Icons.broken_image,
                                      color: Colors.red,
                                      size: 80,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      "画像の読み込みに失敗しました",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                );
                              },
                            )
                          : firstLastData[mascle]![1]["url"].isNotEmpty
                              ? Image.network(
                                  firstLastData[mascle]![1]["url"]!,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Column(
                                      children: const [
                                        Icon(
                                          Icons.broken_image,
                                          color: Colors.red,
                                          size: 80,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          "画像の読み込みに失敗しました",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ],
                                    );
                                  },
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: Colors.grey.withOpacity(0.3)),
                                  ),
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    children: const [
                                      Icon(
                                        Icons.no_photography,
                                        color: Colors.grey,
                                        size: 80,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        "画像がありません",
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                      const SizedBox(
                        height: 20,
                      ),
                      boolFirst
                          ? Text(
                              firstLastData[mascle]![0]["day"],
                              style: TextStyle(
                                  color: Color.fromARGB(255, 209, 209, 0),
                                  fontSize: 20),
                            )
                          : Text(
                              firstLastData[mascle]![1]["day"],
                              style: TextStyle(
                                  color: Color.fromARGB(255, 209, 209, 0),
                                  fontSize: 20),
                            )
                    ],
                  ),
                ));
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 209, 209, 0),
        elevation: 0,
        title: Text(
          'Your workout',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
                                setState(() {
                                  selectedCategory = newValue!;
                                  changeCategry(selectedCategory);
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
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 写真追加用カード
                        Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(9),
                              child: Text(
                                "Latest",
                                style: TextStyle(
                                    color: Color.fromARGB(255, 209, 209, 0),
                                    fontSize: 25),
                              ),
                            ),
                            Padding(
                                padding: EdgeInsets.all(9),
                                child: myWorkout[0]["mascle"] != ""
                                    ? Text(
                                        myWorkout[0]["mascle"] ?? "",
                                        style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 209, 209, 0),
                                            fontSize: 14),
                                      )
                                    : Text(
                                        "",
                                        style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 209, 209, 0),
                                            fontSize: 14),
                                      )),

                            // メイン写真とStreek
                            Container(
                                width: 200, // 好きな幅
                                height: 270, // 縦長
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(20), // 角を丸く
                                  color: Colors.grey[200], // 背景色（画像読み込み前などに見える）
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
                    child: Text("Past",
                        style: TextStyle(
                            color: Color.fromARGB(255, 209, 209, 0),
                            fontSize: 20)),
                  ),

                  const SizedBox(height: 8),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 209, 209, 0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        showPastMusclePhotos();
                      },
                      child: const Text('show your past muscle',
                          style: TextStyle(color: Colors.black, fontSize: 16)),
                    ),
                  ),

                  const SizedBox(
                    height: 30,
                  ),
                  Text(
                    "Your first day",
                    style: TextStyle(
                        color: Color.fromARGB(255, 209, 209, 0), fontSize: 20),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              "chest",
                              style: TextStyle(
                                  color: Color.fromARGB(255, 209, 209, 0),
                                  fontSize: 25),
                            ),
                            SizedBox(height: 16),
                            firstLastChest.isNotEmpty
                                ? Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(
                                          20), // 角丸をInkWellにも伝える
                                      onTap: () {
                                        selectedPhoto(
                                            "chest", firstLastChest[0]["day"]!);
                                      },
                                      child: Stack(
                                        children: [
                                          Container(
                                            width: 180, // 好きな幅
                                            height: 270, // 縦長
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      20), // 角を丸く
                                              color: Colors.grey[
                                                  200], // 背景色（画像読み込み前などに見える）
                                            ),
                                            clipBehavior:
                                                Clip.antiAlias, // 画像を角丸に合わせてカット
                                            child: firstLastChest[0]["url"] !=
                                                    ""
                                                ? Image.network(
                                                    firstLastChest[0]["url"]!,
                                                    fit: BoxFit
                                                        .fitHeight, // 縦にフィット（横が余ってもOK）
                                                  )
                                                : Icon(
                                                    Icons
                                                        .image_not_supported, // 適当なアイコン（変更可能）
                                                    size: 50, // アイコンのサイズ
                                                    color:
                                                        Colors.grey, // アイコンの色
                                                  ),
                                          ),
                                          Positioned(
                                            top: 8,
                                            left: 8,
                                            child: Text(
                                              firstLastChest[0]["day"]!,
                                              style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 209, 209, 0),
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : Container(
                                    width: 180, // 好きな幅
                                    height: 270, // 縦長
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(20), // 角を丸く
                                      color: Colors
                                          .grey[200], // 背景色（画像読み込み前などに見える）
                                    ),
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.no_photography),
                                          const SizedBox(height: 7),
                                          Text("写真が追加されていません")
                                        ]),
                                  ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              "back",
                              style: TextStyle(
                                  color: Color.fromARGB(255, 209, 209, 0),
                                  fontSize: 25),
                            ),
                            SizedBox(height: 16),
                            firstLastBack.isNotEmpty
                                ? Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(
                                          20), // 角丸をInkWellにも伝える
                                      onTap: () {
                                        selectedPhoto(
                                            "back", firstLastBack[0]["day"]!);
                                      },
                                      child: Stack(
                                        children: [
                                          Container(
                                            width: 180, // 好きな幅
                                            height: 270, // 縦長
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      20), // 角を丸く
                                              color: Colors.grey[
                                                  200], // 背景色（画像読み込み前などに見える）
                                            ),
                                            clipBehavior:
                                                Clip.antiAlias, // 画像を角丸に合わせてカット
                                            child: firstLastBack[0]["url"] != ""
                                                ? Image.network(
                                                    firstLastBack[0]["url"]!,
                                                    fit: BoxFit
                                                        .fitHeight, // 縦にフィット（横が余ってもOK）
                                                  )
                                                : Icon(
                                                    Icons
                                                        .image_not_supported, // 適当なアイコン（変更可能）
                                                    size: 50, // アイコンのサイズ
                                                    color:
                                                        Colors.grey, // アイコンの色
                                                  ),
                                          ),
                                          Positioned(
                                            top: 8,
                                            left: 8,
                                            child: Text(
                                              firstLastBack[0]["day"]!,
                                              style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 209, 209, 0),
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : Container(
                                    width: 180, // 好きな幅
                                    height: 270, // 縦長
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(20), // 角を丸く
                                      color: Colors
                                          .grey[200], // 背景色（画像読み込み前などに見える）
                                    ),
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.no_photography),
                                          const SizedBox(height: 7),
                                          Text("写真が追加されていません")
                                        ]),
                                  ),
                          ],
                        ),
                      ),
                    ]),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              "Arms",
                              style: TextStyle(
                                  color: Color.fromARGB(255, 209, 209, 0),
                                  fontSize: 25),
                            ),
                            SizedBox(height: 16),
                            firstLastArms.isNotEmpty
                                ? Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(
                                          20), // 角丸をInkWellにも伝える
                                      onTap: () {
                                        selectedPhoto(
                                            "arms", firstLastArms[0]["day"]!);
                                      },
                                      child: Stack(
                                        children: [
                                          Container(
                                            width: 180, // 好きな幅
                                            height: 270, // 縦長
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      20), // 角を丸く
                                              color: Colors.grey[
                                                  200], // 背景色（画像読み込み前などに見える）
                                            ),
                                            clipBehavior:
                                                Clip.antiAlias, // 画像を角丸に合わせてカット
                                            child: firstLastArms[0]["url"] != ""
                                                ? Image.network(
                                                    firstLastArms[0]["url"]!,
                                                    fit: BoxFit
                                                        .fitHeight, // 縦にフィット（横が余ってもOK）
                                                  )
                                                : Icon(
                                                    Icons
                                                        .image_not_supported, // 適当なアイコン（変更可能）
                                                    size: 50, // アイコンのサイズ
                                                    color:
                                                        Colors.grey, // アイコンの色
                                                  ),
                                          ),
                                          Positioned(
                                            top: 8,
                                            left: 8,
                                            child: Text(
                                              firstLastArms[0]["day"]!,
                                              style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 209, 209, 0),
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : Container(
                                    width: 180, // 好きな幅
                                    height: 270, // 縦長
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(20), // 角を丸く
                                      color: Colors
                                          .grey[200], // 背景色（画像読み込み前などに見える）
                                    ),
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.no_photography),
                                          const SizedBox(height: 7),
                                          Text("写真が追加されていません")
                                        ]),
                                  ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              "Legs",
                              style: TextStyle(
                                  color: Color.fromARGB(255, 209, 209, 0),
                                  fontSize: 25),
                            ),
                            SizedBox(height: 16),
                            firstLastLegs.isNotEmpty
                                ? Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(
                                          20), // 角丸をInkWellにも伝える
                                      onTap: () {
                                        selectedPhoto(
                                            "legs", firstLastLegs[0]["day"]!);
                                      },
                                      child: Stack(
                                        children: [
                                          Container(
                                            width: 180, // 好きな幅
                                            height: 270, // 縦長
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      20), // 角を丸く
                                              color: Colors.grey[
                                                  200], // 背景色（画像読み込み前などに見える）
                                            ),
                                            clipBehavior:
                                                Clip.antiAlias, // 画像を角丸に合わせてカット
                                            child: firstLastLegs[0]["url"] != ""
                                                ? Image.network(
                                                    firstLastLegs[0]["url"]!,
                                                    fit: BoxFit
                                                        .fitHeight, // 縦にフィット（横が余ってもOK）
                                                  )
                                                : Icon(
                                                    Icons
                                                        .image_not_supported, // 適当なアイコン（変更可能）
                                                    size: 50, // アイコンのサイズ
                                                    color:
                                                        Colors.grey, // アイコンの色
                                                  ),
                                          ),
                                          Positioned(
                                            top: 8,
                                            left: 8,
                                            child: Text(
                                              firstLastLegs[0]["day"]!,
                                              style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 209, 209, 0),
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : Container(
                                    width: 180, // 好きな幅
                                    height: 270, // 縦長
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(20), // 角を丸く
                                      color: Colors
                                          .grey[200], // 背景色（画像読み込み前などに見える）
                                    ),
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.no_photography),
                                          const SizedBox(height: 7),
                                          Text("写真が追加されていません")
                                        ]),
                                  ),
                          ],
                        ),
                      ),
                    ]),
                  ),
                ],
              ),
            ),
    );
  }
}
