import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:muscle_share/methods/fetchInfoProfile.dart';

class otherProfileScreen extends StatefulWidget {
  final String deviceId; // ← 受け取りたい変数

  const otherProfileScreen(
      {super.key, required this.deviceId}); // ← コンストラクタで受け取る

  @override // 👈 忘れずに！
  _otherProfileScreenState createState() => _otherProfileScreenState();
}

class _otherProfileScreenState extends State<otherProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _benchController = TextEditingController();
  final TextEditingController _deadController = TextEditingController();
  final TextEditingController _squatController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  late Uint8List imageBytes = Uint8List(0); // 空のバイト列で初期化
  late XFile? pickedFile = null; // nullで初期化
  late Map<String, String> infoList = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    initializeProfile();
  }

  Future<void> initializeProfile() async {
    infoList = await fetchOtherInfo(widget.deviceId);
    setState(() {
      _nameController.text = infoList["name"] ?? "";
      _dateController.text = infoList["startDay"] ?? "";
      _benchController.text = infoList["bench"] ?? "";
      _deadController.text = infoList["dead"] ?? "";
      _squatController.text = infoList["squat"] ?? "";
      _isLoading = false; // 初期化完了！
    });
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
                                  ? Image.network(infoList["url"]!,
                                      fit: BoxFit.cover)
                                  : Icon(Icons.person,
                                      size: 100, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      'User Name',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 209, 209, 0),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey), // 枠線つける
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.person,
                              color: Color.fromARGB(255, 209, 209, 0)),
                          const SizedBox(width: 10),
                          Text(
                            _nameController.text.isNotEmpty
                                ? _nameController.text
                                : 'Enter your name', // テキストがなかったらヒントみたいに
                            style: const TextStyle(
                              color: Color.fromARGB(255, 209, 209, 0),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      'Start day',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 209, 209, 0),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              color: Color.fromARGB(255, 209, 209, 0)),
                          const SizedBox(width: 10),
                          Text(
                            _dateController.text.isNotEmpty
                                ? _dateController.text
                                : 'Not defined',
                            style: const TextStyle(
                              color: Color.fromARGB(255, 209, 209, 0),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      'Best records',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 209, 209, 0),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                    child: Text(
                      'bench press',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 209, 209, 0),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.e_mobiledata,
                              color: Color.fromARGB(255, 209, 209, 0)),
                          const SizedBox(width: 10),
                          Text(
                            _benchController.text.isNotEmpty
                                ? _benchController.text
                                : 'Not defined',
                            style: const TextStyle(
                              color: Color.fromARGB(255, 209, 209, 0),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                    child: Text(
                      'deadlift',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 209, 209, 0),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.label_off_sharp,
                              color: Color.fromARGB(255, 209, 209, 0)),
                          const SizedBox(width: 10),
                          Text(
                            _deadController.text.isNotEmpty
                                ? _deadController.text
                                : 'Not defined',
                            style: const TextStyle(
                              color: Color.fromARGB(255, 209, 209, 0),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                    child: Text(
                      'squat',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 209, 209, 0),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.sailing_rounded,
                              color: Color.fromARGB(255, 209, 209, 0)),
                          const SizedBox(width: 10),
                          Text(
                            _squatController.text.isNotEmpty
                                ? _squatController.text
                                : 'Not defined',
                            style: const TextStyle(
                              color: Color.fromARGB(255, 209, 209, 0),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
    );
  }
}
