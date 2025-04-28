import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:muscle_share/methods/fetchInfoProfile.dart';
import 'package:muscle_share/methods/getDeviceId.dart';
import 'package:muscle_share/methods/saveDataForProfile.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _tergetController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  late Uint8List imageBytes = Uint8List(0); // 空のバイト列で初期化
  late XFile? pickedFile = null; // nullで初期化
  String deviceId = "";
  late Map<String, String> infoList = {};
  bool _isLoading = true;
  String username = "";
  String startDay = "";

  @override
  void initState() {
    super.initState();
    // 非同期処理を別メソッドに分離して呼び出す
    initializeProfile();
  }

  Future<void> initializeProfile() async {
    try {
      // 非同期処理を実行
      deviceId = await getDeviceUUID();
      infoList = await fetchInfo();

      // 非同期処理が完了したら状態を更新
      setState(() {
        username = infoList["name"] ?? "";
        startDay = infoList["startDay"] ?? "";
        _isLoading = false; // ローディング完了
      });
    } catch (e) {
      print("エラーが発生しました: $e");
    }
  }

  // カメラを起動して画像を取得する
  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    deviceId = await getDeviceUUID(); // デバイス ID を取得

    try {
      pickedFile = await picker.pickImage(source: ImageSource.camera);

      if (pickedFile != null) {
        if (kIsWeb) {
          // 🌍 Web の場合 → Uint8List に変換
          try {
            imageBytes = await pickedFile!.readAsBytes();

            print("成功しました。");
            setState(() {
              pickedFile;
            });
          } catch (e) {
            print("エラーがはっせいしました。");
          }
        }
      } else {
        print("❌ No image selected.");
      }
    } catch (e) {
      print("❌ エラーが発生しました: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 209, 209, 0),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          'Profile',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: Colors.black,
      body: _isLoading
          ? Center(
              child: Theme(
                data: ThemeData(primarySwatch: Colors.yellow),
                child: const CircularProgressIndicator(),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Stack(
                      children: [
                        // コンテナ部分
                        Container(
                          width: MediaQuery.of(context)
                              .size
                              .width, // 横幅を画面サイズに合わせる
                          height: MediaQuery.of(context).size.width *
                              2 /
                              3, // 高さも比例
                          decoration: BoxDecoration(
                            color: Colors.grey[200], // 背景色
                          ),
                          child: pickedFile != null
                              ? Image.memory(imageBytes, fit: BoxFit.cover)
                              : (infoList["url"]!.isNotEmpty &&
                                      infoList["url"] != "")
                                  ? Image.network(infoList["url"]!)
                                  : Icon(Icons.person,
                                      size: 100, color: Colors.grey),
                        ),
                        // ボタン部分
                        Positioned(
                          bottom: 10, // コンテナの底からの距離
                          right: 10, // コンテナの右からの距離
                          child: ElevatedButton(
                            onPressed: _takePhoto, // 写真を選択するメソッド
                            style: ElevatedButton.styleFrom(
                              shape: CircleBorder(), // ボタンを丸くする
                              padding: EdgeInsets.all(12), // ボタンのパディング
                              backgroundColor: const Color.fromARGB(
                                  255, 209, 209, 0), // ボタンの色
                            ),
                            child:
                                Icon(Icons.add, color: Colors.white), // プラスアイコン
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          'User Name',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 209, 209, 0),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          "Now : $username",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 209, 209, 0),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: TextField(
                      controller: _nameController,
                      style: TextStyle(color: Color.fromARGB(255, 209, 209, 0)),
                      decoration: InputDecoration(
                        hintText: 'Enter your name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      'Your Target',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 209, 209, 0),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: TextField(
                      controller: _tergetController,
                      style: TextStyle(color: Color.fromARGB(255, 209, 209, 0)),
                      decoration: InputDecoration(
                        hintText: '目標を入力してください',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.fitness_center),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          'Start day',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 209, 209, 0),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          "Now : $startDay",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 209, 209, 0),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: GestureDetector(
                      onTap: () async {
                        DateTime? selectedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (selectedDate != null) {
                          _dateController.text = selectedDate
                              .toString()
                              .split(' ')[0]; // フォーマットをYYYY-MM-DDに
                        }
                      },
                      child: AbsorbPointer(
                        child: TextField(
                          controller: _dateController,
                          style: TextStyle(
                              color: Color.fromARGB(255, 209, 209, 0)),
                          decoration: InputDecoration(
                            hintText: 'Enter your start day of muscle training',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: ElevatedButton(
                        onPressed: () async {
                          saveInfoWeb(_nameController.text,
                              _dateController.text, deviceId, imageBytes);
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              WidgetStateProperty.resolveWith<Color>(
                                  (Set<WidgetState> states) {
                            if (states.contains(WidgetState.pressed)) {
                              return Color.fromARGB(
                                  255, 255, 255, 100); // 押したときの色（明るい黄色）
                            }
                            return Colors.black; // 通常時の色
                          }),
                          side: WidgetStateProperty.all(
                            BorderSide(color: Color.fromARGB(255, 209, 209, 0)),
                          ),
                        ),
                        child: Text(
                          "変更を保存する",
                          style: TextStyle(
                              color: Color.fromARGB(255, 209, 209, 0)),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
