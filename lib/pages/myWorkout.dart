import 'package:flutter/material.dart';
import 'package:muscle_share/methods/fetchMyPhoto.dart';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({super.key});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  late List<Map<String, String>> myWorkout = [];
  bool isLoading = true;
  String streek = "";

  @override
  void initState() {
    super.initState();
    initializeList();
  }

  void initializeList() async {
    myWorkout = await fetchHistory();
    print(myWorkout);
    setState(() {
      isLoading = false;
      streek = myWorkout.length.toString();
    });
  }

  void showPastMusclePhotos() {
    // 現在の日付を取得
    final now = DateTime.now();

    // 1ヶ月前、3ヶ月前、半年前の日付を計算
    final oneMonthAgo = now.subtract(Duration(days: 30));
    final threeMonthsAgo = now.subtract(Duration(days: 90));
    final sixMonthsAgo = now.subtract(Duration(days: 180));

    // 各期間の写真をフィルタリング
    final oneMonthPhoto = myWorkout.firstWhere(
      (workout) => DateTime.parse(workout["day"] ?? "").isAfter(oneMonthAgo),
      orElse: () => {},
    );
    final threeMonthsPhoto = myWorkout.firstWhere(
      (workout) => DateTime.parse(workout["day"] ?? "").isAfter(threeMonthsAgo),
      orElse: () => {},
    );
    final sixMonthsPhoto = myWorkout.firstWhere(
      (workout) => DateTime.parse(workout["day"] ?? "").isAfter(sixMonthsAgo),
      orElse: () => {},
    );

    // モーダルダイアログを表示
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black,
          title: const Text(
            "Past Muscle Photos",
            style: TextStyle(color: Color.fromARGB(255, 209, 209, 0)),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (oneMonthPhoto.isNotEmpty)
                  buildPhotoTile("1 Month Ago", oneMonthPhoto["url"]),
                if (threeMonthsPhoto.isNotEmpty)
                  buildPhotoTile("3 Months Ago", threeMonthsPhoto["url"]),
                if (sixMonthsPhoto.isNotEmpty)
                  buildPhotoTile("6 Months Ago", sixMonthsPhoto["url"]),
              ],
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
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text("Your Streek",
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 209, 209, 0),
                                      fontSize: 20)),
                              const SizedBox(height: 10),
                              myWorkout[0]["url"] != ""
                                  ? Text(
                                      streek,
                                      style: TextStyle(
                                        fontSize: 64,
                                        color: Color.fromARGB(255, 209, 209, 0),
                                      ),
                                    )
                                  : Text(
                                      "0",
                                      style: TextStyle(
                                        fontSize: 64,
                                        color: Color.fromARGB(255, 209, 209, 0),
                                      ),
                                    )
                            ],
                          ),
                        )),
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

                  // フォーカス情報
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text("You focused for chest training",
                        style: TextStyle(
                            color: Color.fromARGB(255, 209, 209, 0),
                            fontSize: 16)),
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
