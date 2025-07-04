import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:muscle_share/methods/AddFriendMethod.dart';
import 'package:muscle_share/methods/PhotoSelect.dart';
import 'package:muscle_share/methods/fetchInfoProfile.dart';
import 'package:muscle_share/methods/getDeviceId.dart';
import 'package:muscle_share/pages/Header.dart';
import 'package:muscle_share/pages/OtherBestRecordsInput.dart';
import 'package:muscle_share/pages/profile.dart';

class otherProfileScreen extends StatefulWidget {
  final String deviceId; // ← 受け取りたい変数

  const otherProfileScreen(
      {super.key, required this.deviceId}); // ← コンストラクタで受け取る

  @override // 👈 忘れずに！
  _otherProfileScreenState createState() => _otherProfileScreenState();
}

class _otherProfileScreenState extends State<otherProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  late Uint8List imageBytes = Uint8List(0); // 空のバイト列で初期化
  late XFile? pickedFile = null; // nullで初期化
  late Map<String, dynamic> infoList = {};
  bool _isLoading = true;
  late int? _selectedHeight;
  late int? _selectedWeight;
  late String myDeviceId;
  ProfileScreenState PS = ProfileScreenState();
  List<String> deviceIds = [];
  List<dynamic> request = [];
  bool sentRequestNow = false;

  @override
  void initState() {
    super.initState();
    initializeProfile();
  }

  Future<void> initializeProfile() async {
    infoList = await fetchOtherInfo(widget.deviceId);
    myDeviceId = await getDeviceIDweb();

    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection(myDeviceId)
        .doc("profile")
        .get();
    if (snapshot.exists) {
      if (snapshot.data() != null &&
          (snapshot.data() as Map<String, dynamic>)
              .containsKey('friendDeviceId')) {
        // ✅ 型を明示的に変換
        deviceIds = List<String>.from(
            (snapshot.data() as Map<String, dynamic>)['friendDeviceId']);
      }
    }

    setState(() {
      _nameController.text = infoList["name"] ?? "";
      _dateController.text = infoList["startDay"] ?? "";
      _selectedHeight = infoList["height"] ?? 0;
      _selectedWeight = infoList["weight"] ?? 0;
      request = infoList["requested"] ?? [];
      print(deviceIds);
      print(request);
      print(myDeviceId);
      _isLoading = false; // 初期化完了！
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(
        title: 'プロフィール',
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
                children: [
                  // 📸 画像表示カード
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Stack(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.width * 2 / 3,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: pickedFile != null
                              ? PhotoCropView(imageBytes: imageBytes)
                              : (infoList["url"]!.isNotEmpty &&
                                      infoList["url"] != "")
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: InteractiveViewer(
                                        minScale: 1.0,
                                        maxScale: 4.0,
                                        panEnabled: true,
                                        child: Image.network(
                                          infoList["url"]!,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    )
                                  : Center(
                                      child: Icon(
                                        Icons.person,
                                        size: 100,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                        ),
                      ],
                    ),
                  ),

                  request.contains(myDeviceId) || sentRequestNow
                      ? SizedBox(
                          height: 16,
                          child: Text(
                            "友達申請済みです。",
                            style: TextStyle(
                                color: Color.fromARGB(255, 209, 209, 0),
                                fontWeight: FontWeight.bold),
                          ),
                        )
                      : deviceIds.contains(widget.deviceId) ||
                              widget.deviceId == myDeviceId
                          ? SizedBox(
                              height: 16,
                              child: Text(
                                "既に友達です",
                                style: TextStyle(
                                    color: Color.fromARGB(255, 209, 209, 0),
                                    fontWeight: FontWeight.bold),
                              ),
                            )
                          : Center(
                              child: ElevatedButton(
                                onPressed: () {
                                  // 友達申請を送る
                                  requestFrend(widget.deviceId, myDeviceId);

                                  // 友達申請送信後にメッセージを表示
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('友達申請を送りました'),
                                      backgroundColor:
                                          Colors.green, // 背景色（任意で変更）
                                    ),
                                  );

                                  setState(() {
                                    sentRequestNow = true;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor:
                                      Color.fromARGB(255, 209, 209, 0),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 32, vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                        color:
                                            Color.fromARGB(255, 209, 209, 0)),
                                  ),
                                ),
                                child: Text("友達追加"),
                              ),
                            ),
                  const SizedBox(
                    height: 16,
                  ),

                  PS.buildSectionCard(
                    title: "User Name",
                    child: ListTile(
                      leading: Icon(Icons.person, color: Colors.yellowAccent),
                      title: Text("Name",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black)),
                      trailing: Text(
                        _nameController.text.isNotEmpty
                            ? _nameController.text
                            : "No name",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),

                  PS.buildSectionCard(
                    title: "Start Day",
                    child: ListTile(
                      leading: Icon(Icons.calendar_today,
                          color: Colors.yellowAccent),
                      title: Text("Start Date",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black)),
                      trailing: Text(
                        infoList["startDay"] ?? "Unknown",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),

                  PS.buildSectionCard(
                    title: "Personal Data",
                    child: Column(
                      children: [
                        ListTile(
                          leading:
                              Icon(Icons.height, color: Colors.yellowAccent),
                          title: Text("Height",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black)),
                          trailing: Text("${_selectedHeight} cm",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black)),
                          contentPadding: EdgeInsets.symmetric(horizontal: 8),
                        ),
                        Divider(color: Colors.grey.shade400),
                        ListTile(
                          leading: Icon(Icons.monitor_weight,
                              color: Colors.yellowAccent),
                          title: Text("Weight",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black)),
                          trailing: Text("${_selectedWeight} kg",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black)),
                          contentPadding: EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ],
                    ),
                  ),

                  PS.buildSectionCard(
                    title: "Best Records of your training",
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OtherBestRecordsInput(
                                deviceId: widget.deviceId),
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            )
                          ],
                        ),
                        child: Text(
                          'Tap to input your Best Records',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(255, 209, 209, 0),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
