import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:muscle_share/methods/AddFriendMethod.dart';
import 'package:muscle_share/methods/PhotoSelect.dart';
import 'package:muscle_share/methods/fetchInfoProfile.dart';
import 'package:muscle_share/methods/getDeviceId.dart';
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
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: IconThemeData(color: Color.fromARGB(255, 209, 209, 0)),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // ← 左寄せ
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ✅ プロフィール画像（左端）

                Text(
                  "プロフィール",
                  style: TextStyle(
                    color: Color.fromARGB(255, 209, 209, 0),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final List<String> reasons = [
                      "スパム行為",
                      "不適切なコンテンツ",
                      "嫌がらせや誹謗中傷",
                      "その他"
                    ];
                    String? selectedReason;
                    final TextEditingController otherReasonController =
                        TextEditingController();

                    final bool? confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) {
                        return StatefulBuilder(builder: (context, setState) {
                          return AlertDialog(
                            backgroundColor: Colors.black,
                            title: Text(
                              "通報理由を選択",
                              style: TextStyle(
                                  color: Color.fromARGB(255, 209, 209, 0)),
                            ),
                            content: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ...reasons
                                      .map((reason) => RadioListTile<String>(
                                            activeColor: Color.fromARGB(
                                                255, 209, 209, 0),
                                            title: Text(
                                              reason,
                                              style: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 209, 209, 0)),
                                            ),
                                            value: reason,
                                            groupValue: selectedReason,
                                            onChanged: (value) {
                                              setState(() {
                                                selectedReason = value;
                                              });
                                            },
                                          )),
                                  if (selectedReason == "その他")
                                    TextField(
                                      controller: otherReasonController,
                                      style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 209, 209, 0)),
                                      maxLines: 3,
                                      decoration: InputDecoration(
                                        hintText: "通報理由を入力",
                                        hintStyle: TextStyle(
                                            color: Color.fromARGB(
                                                255, 150, 150, 50)),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Color.fromARGB(
                                                  255, 209, 209, 0)),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Color.fromARGB(
                                                  255, 209, 209, 0)),
                                        ),
                                      ),
                                    )
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: Text("キャンセル",
                                    style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 209, 209, 0))),
                              ),
                              TextButton(
                                onPressed: () async {
                                  // 通報理由入力ダイアログを閉じる

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('通報しました')),
                                  );
                                  Navigator.of(context).pop(true);
                                },
                                child: Text(
                                  "通報する",
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 209, 209, 0)),
                                ),
                              ),
                            ],
                          );
                        });
                      },
                    );

                    if (confirmed != true || selectedReason == null) return;

                    final String reason = selectedReason == "その他"
                        ? otherReasonController.text.trim()
                        : selectedReason!;

                    if (reason.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("通報理由を入力してください"),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final String reportedDeviceId = widget.deviceId;
                    final String reporterDeviceId = await getDeviceIDweb();

                    final docRef = FirebaseFirestore.instance
                        .collection("report_list")
                        .doc(reportedDeviceId);

                    final docSnapshot = await docRef.get();

                    if (docSnapshot.exists) {
                      List<Map<String, String>> reporters =
                          List<Map<String, String>>.from(
                              docSnapshot.data()?['reporters'] ?? []);

                      bool alreadyReported = reporters.any(
                          (report) => report['reporter'] == reporterDeviceId);

                      if (!alreadyReported) {
                        reporters.add({
                          'reporter': reporterDeviceId,
                          'reason': reason,
                          'timestamp': DateTime.now().toIso8601String(),
                        });
                        await docRef.set(
                            {'reporters': reporters}, SetOptions(merge: true));
                      }
                    } else {
                      await docRef.set({
                        'reporters': [
                          {
                            'reporter': reporterDeviceId,
                            'reason': reason,
                            'timestamp': DateTime.now().toIso8601String(),
                          }
                        ]
                      });
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("通報しました"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Color.fromARGB(255, 209, 209, 0),
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Color.fromARGB(255, 209, 209, 0)),
                    ),
                  ),
                  child: Text("通報する"),
                )
              ],
            ),
            SizedBox(height: 8),
            Container(
              width: double.infinity, // 横幅いっぱい
              height: 1,
              color: Colors.grey, // 境界線の色
            ),
          ],
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
