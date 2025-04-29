// home_screen.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:muscle_share/methods/fetchPhoto.dart';
import 'package:muscle_share/methods/getDeviceId.dart';
import 'package:muscle_share/methods/savaData.dart';
import 'package:muscle_share/methods/updatephotoInfo.dart';
import 'package:muscle_share/pages/myWorkout.dart';
import 'package:muscle_share/pages/otherProfile.dart';
import 'package:muscle_share/pages/profile.dart';
import 'package:image_picker/image_picker.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  List<Map<String, Map<String, String>>> originPhotoList = [];
  List<Map<String, Map<String, String>>> photoList = [];

  String selectedCategory = 'All';
  String deviceId = "";
  bool isPrivateMode = true;
  final List<String> categories = ['All', 'Chest', 'Back', 'Legs', 'Arms'];
  List<Map<String, Map<String, String>>> originMatchingValues = [];
  List<Map<String, Map<String, String>>> matchingValues = [];
  late List<bool> showHearts;
  late List<AnimationController> controllers;
  late List<Animation<double>> scaleAnimations;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    await fetchPhotos();
    final length = photoList.length;
    showHearts = List.generate(length, (_) => false);
    controllers = List.generate(length, (i) {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 400),
        vsync: this,
      );
      controller.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          Future.delayed(const Duration(milliseconds: 400), () {
            if (mounted) {
              setState(() => showHearts[i] = false);
              controller.reset();
            }
          });
        }
        print(controllers);
      });
      return controller;
    });

    scaleAnimations = controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.4).animate(
        CurvedAnimation(parent: controller, curve: Curves.elasticOut),
      );
    }).toList();
  }

  Future<void> fetchPhotos() async {
    originMatchingValues = [];
    deviceId = await getDeviceUUID(); // デバイス ID を取得
    List<Map<String, Map<String, String>>> photos = await fetchTodayphoto();

    for (var photo in photos) {
      if (photo.values.first["deviceId"] == deviceId &&
          !originMatchingValues.any((element) =>
              element.values.first["url"] == photo.values.first["url"])) {
        originMatchingValues.add(photo);
      }
    }

    setState(() {
      originPhotoList = photoList = photos;
      matchingValues = originMatchingValues;
      selectedCategory = "All";
    });
  }

  void changeCategry(String newCategoly) {
    if (newCategoly == "All") {
      photoList = originPhotoList;
      matchingValues = originMatchingValues;
    } else {
      photoList = originPhotoList
          .where((map) => map.values.first["mascle"] == newCategoly)
          .toList();
      matchingValues = originMatchingValues
          .where((map) => map.values.first["mascle"] == newCategoly)
          .toList();
    }
  }

  // カメラを起動して画像を取得する
  Future<void> _takePhoto() async {
    final picker = ImagePicker();

    try {
      final XFile? pickedFile =
          await picker.pickImage(source: ImageSource.camera);

      if (pickedFile != null) {
        if (kIsWeb) {
          // 🌍 Web の場合 → Uint8List に変換
          try {
            Uint8List imageBytes = await pickedFile.readAsBytes();
            await savePhotoWeb(context, imageBytes, deviceId);
            setState(() {
              initialize();
            });

            print("成功しました。");
          } catch (e) {
            print("エラーがはっせいしました。");
          }
        } else {
          // 📱 iOS / Android の場合 → XFile をそのまま使う
          await savePhotoMobile(context, pickedFile, deviceId);
        }
      } else {
        print("❌ No image selected.");
      }
    } catch (e) {
      print("❌ エラーが発生しました: $e");
    }
  }

  @override
  void dispose() {
    for (final c in controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onTap(int index) {
    setState(() => showHearts[index] = true);
    controllers[index].forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 209, 209, 0),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.account_circle, color: Colors.black, size: 30),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileScreen()),
            );
          },
        ),
        title: Center(
          child: Text(
            'Today',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          IconButton(
            icon:
                Icon(Icons.date_range_outlined, color: Colors.black, size: 30),
            onPressed: () {
              // Implement search logic
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WorkoutPage()),
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              child: Row(
                children: [
                  // プライベートと全世界の選択ボタン
                  const SizedBox(
                    width: 50,
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.transparent, // 背景を透明に
                            splashFactory:
                                NoSplash.splashFactory, // タップエフェクトを無効化
                          ),
                          onPressed: () {
                            setState(() {
                              isPrivateMode = true;
                            });
                          },
                          child: Text(
                            'My work',
                            style: TextStyle(
                              fontWeight: isPrivateMode
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isPrivateMode
                                  ? const Color.fromARGB(255, 209, 209, 0)
                                  : Colors.grey,
                            ),
                          ),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.transparent, // 背景を透明に
                            splashFactory:
                                NoSplash.splashFactory, // タップエフェクトを無効化
                          ),
                          onPressed: () {
                            setState(() {
                              isPrivateMode = false;
                            });
                          },
                          child: Text(
                            'World',
                            style: TextStyle(
                              fontWeight: !isPrivateMode
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: !isPrivateMode
                                  ? const Color.fromARGB(255, 209, 209, 0)
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // DropdownButtonを右端に配置
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 9),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.withOpacity(0.3)),
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
                          items: categories
                              .map<DropdownMenuItem<String>>((String value) {
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
            ),
          ),
          isPrivateMode
              ? Expanded(
                  child: RefreshIndicator(
                    onRefresh: initialize, // 👈 引っ張ったときに実行される関数
                    color: Color.fromARGB(255, 209, 209, 0), // インジケーターの色（任意）
                    backgroundColor: Colors.black, // 背景色（任意）
                    child: ListView.builder(
                      padding: EdgeInsets.all(10),
                      itemCount: matchingValues.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  matchingValues[index].values.first["icon"] !=
                                          ""
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                              20), // 丸みをつけたい場合
                                          child: Image.network(
                                            matchingValues[index]
                                                .values
                                                .first["icon"]!,
                                            width: 30,
                                            height: 30,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Icon(
                                          Icons.person,
                                          color: const Color.fromARGB(
                                              255, 209, 209, 0),
                                          size: 30,
                                        ),
                                  const SizedBox(width: 8),
                                  Text(
                                    matchingValues[index]
                                                .values
                                                .first["name"] !=
                                            ""
                                        ? matchingValues[index]
                                            .values
                                            .first["name"]!
                                        : 'Not defined',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 209, 209, 0),
                                    ),
                                  ),
                                  Spacer(),
                                  IconButton(
                                    icon: Icon(
                                      Icons.more_vert,
                                      color: Color.fromARGB(255, 209, 209, 0),
                                    ),
                                    onPressed: () async {
                                      // モーダルで編集・削除の選択肢を表示
                                      showModalBottomSheet(
                                        context: context,
                                        backgroundColor:
                                            Colors.grey[900], // ダーク系背景
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(20)),
                                        ),
                                        builder: (BuildContext context) {
                                          return Padding(
                                            padding: const EdgeInsets.all(20.0),
                                            child: Wrap(
                                              children: [
                                                ListTile(
                                                  leading: Icon(Icons.edit,
                                                      color: Colors.yellow),
                                                  title: Text('編集',
                                                      style: TextStyle(
                                                          color: Colors.white)),
                                                  onTap: () async {
                                                    Navigator.pop(
                                                        context); // モーダルを閉じる

                                                    await updatePhotoInfo(
                                                        context,
                                                        matchingValues[index]
                                                            .keys
                                                            .first);
                                                    await initialize();
                                                  },
                                                ),
                                                ListTile(
                                                  leading: Icon(Icons.delete,
                                                      color: Colors.red),
                                                  title: Text('削除',
                                                      style: TextStyle(
                                                          color: Colors.white)),
                                                  onTap: () async {
                                                    Navigator.pop(
                                                        context); // モーダルを閉じる

                                                    await deletePhoto(
                                                        matchingValues[index]
                                                            .keys
                                                            .first);
                                                    await initialize();
                                                  },
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(15), // 画像の角を丸める
                                child: CachedNetworkImage(
                                  imageUrl: matchingValues[index]
                                      .values
                                      .first["url"]!,
                                  width: double.infinity,
                                  height: 500,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Center(
                                      child: CircularProgressIndicator()),
                                  errorWidget: (context, url, error) {
                                    print("⚠️ 画像の読み込みエラー: $error");
                                    return Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.error,
                                            size: 50, color: Colors.red),
                                        Text("画像を取得できませんでした"),
                                      ],
                                    );
                                  },
                                ),
                              ),
                              SizedBox(height: 8), // 画像とキャプションの間隔
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  matchingValues[index]
                                      .values
                                      .first['caption']!,
                                  style: TextStyle(
                                      color: const Color.fromARGB(
                                          255, 209, 209, 0),
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              SizedBox(height: 8), // キャプションと次の画像の間隔
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                )
              : Expanded(
                  child: RefreshIndicator(
                    onRefresh: initialize, // 👈 引っ張ったときに実行される関数
                    color: Color.fromARGB(255, 209, 209, 0), // インジケーターの色（任意）
                    backgroundColor: Colors.black, // 背景色（任意）
                    child: ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemCount: photoList.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8),
                          child: photoList[index].values.first["isPrivate"]! ==
                                  "false"
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // ユーザーアイコン + 名前
                                    Row(
                                      children: [
                                        photoList[index].values.first["icon"] !=
                                                ""
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                child: Material(
                                                  // ← Materialを挟むとタップ時にエフェクトも出せる
                                                  color: Colors.transparent,
                                                  child: InkWell(
                                                    onTap: () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  otherProfileScreen(
                                                                      deviceId: photoList[
                                                                              index]
                                                                          .values
                                                                          .first["deviceId"]!)));
                                                    },
                                                    child: Image.network(
                                                      photoList[index]
                                                          .values
                                                          .first["icon"]!,
                                                      width: 30,
                                                      height: 30,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                child: Material(
                                                  // ← Materialを挟むとタップ時にエフェクトも出せる
                                                  color: Colors.transparent,
                                                  child: InkWell(
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              otherProfileScreen(
                                                                  deviceId: photoList[
                                                                              index]
                                                                          .values
                                                                          .first[
                                                                      "deviceId"]!),
                                                        ),
                                                      );
                                                    },
                                                    child: Icon(
                                                      Icons.person,
                                                      color: Color.fromARGB(
                                                          255, 209, 209, 0),
                                                      size: 30,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                        const SizedBox(width: 8),
                                        Text(
                                          photoList[index]
                                                      .values
                                                      .first["name"] !=
                                                  ""
                                              ? photoList[index]
                                                  .values
                                                  .first["name"]!
                                              : 'Not defined',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color.fromARGB(
                                                255, 209, 209, 0),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 8),

                                    // 📸 画像 ＋ 💛エフェクト（リスト内に直書き）
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onDoubleTap: () => _onTap(index),
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Ink.image(
                                                image:
                                                    CachedNetworkImageProvider(
                                                        photoList[index]
                                                            .values
                                                            .first["url"]!),
                                                width: double.infinity,
                                                height: 500,
                                                fit: BoxFit.cover,
                                                child: Container(),
                                              ),
                                              if (showHearts[index])
                                                ScaleTransition(
                                                  scale: scaleAnimations[index],
                                                  child: Icon(
                                                    Icons.favorite,
                                                    color:
                                                        Colors.amber.shade600,
                                                    size: 100,
                                                    shadows: [
                                                      Shadow(
                                                        blurRadius: 10,
                                                        color: Colors.black
                                                            .withOpacity(0.4),
                                                        offset:
                                                            const Offset(2, 4),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 8),

                                    // 📝 キャプション
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Text(
                                        photoList[index]
                                                .values
                                                .first['caption'] ??
                                            '',
                                        style: const TextStyle(
                                          color:
                                              Color.fromARGB(255, 209, 209, 0),
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 8),
                                  ],
                                )
                              : const SizedBox(
                                  height: 0,
                                ),
                        );
                      },
                    ),
                  ),
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color.fromARGB(255, 209, 209, 0),
        onPressed: () {
          _takePhoto();
        },
        child: Icon(Icons.add_a_photo, color: Colors.black),
      ),
    );
  }
}
