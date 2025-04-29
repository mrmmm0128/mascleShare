import 'package:flutter/material.dart';
import 'package:muscle_share/methods/fetchMyPhoto.dart';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({super.key});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  late List<Map<String, String>> myWorkout = [];
  late List<Map<String, String>> originMyWorkout = [];
  final List<String> categories = ['All', 'Chest', 'Back', 'Legs', 'Arms'];
  bool isLoading = true;
  String streek = "";
  String selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    initializeList();
  }

  void initializeList() async {
    myWorkout = originMyWorkout = await fetchHistory();
    print(myWorkout);
    setState(() {
      isLoading = false;
      streek = myWorkout.length.toString();
    });
  }

  void changeCategry(String newCategoly) {
    if (newCategoly == "All") {
      myWorkout = originMyWorkout;
    } else {
      myWorkout =
          originMyWorkout.where((map) => map["mascle"] == newCategoly).toList();

      if (myWorkout.isEmpty) {
        myWorkout = [
          {"url": "", "name": "", "startDay": ""}
        ];
      }
      print(myWorkout);
    }
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
                                width: 220, // 好きな幅
                                height: 300, // 縦長
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

                  // 過去の写真3つ

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics:
                          NeverScrollableScrollPhysics(), // 他のスクロールビューと干渉しないように
                      itemCount:
                          myWorkout.length > 1 ? myWorkout.length - 1 : 0,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 0.6,
                      ),
                      itemBuilder: (context, index) {
                        final workout =
                            myWorkout[index + 1]; // indexを+2して3つ目以降を取得
                        return Column(
                          children: [
                            Text(
                              workout["day"] ?? "",
                              style: const TextStyle(
                                color: Color.fromARGB(255, 209, 209, 0),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              workout["mascle"] ?? "",
                              style: const TextStyle(
                                color: Color.fromARGB(255, 209, 209, 0),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.yellow[100],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    workout["url"] ?? "",
                                    fit: BoxFit.fitHeight,
                                    width: double.infinity,
                                  ),
                                ),
                              ),
                            ),
                          ],
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
