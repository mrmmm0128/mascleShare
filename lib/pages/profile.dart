import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:muscle_share/methods/DeleteAccount.dart';
import 'package:muscle_share/methods/PhotoCropper.dart';
import 'package:muscle_share/methods/PhotoSelect.dart';
import 'package:muscle_share/methods/FetchInfoProfile.dart';
import 'package:muscle_share/methods/getDeviceId.dart';
import 'package:muscle_share/methods/SaveDataForProfile.dart';
import 'package:muscle_share/pages/BestRecordsInput.dart';
import 'package:muscle_share/data/PreAndCity.dart';

class ProfileScreen extends StatefulWidget {
  final String? condition;

  const ProfileScreen({super.key, this.condition}); // ← ここに `condition` が必要
  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  late Uint8List imageBytes = Uint8List(0);

  XFile? pickedFile;
  String deviceId = "";
  late Map<String, dynamic> infoList = {};
  bool _isLoading = true;
  int? _selectedHeight;
  final List<int> _heightOptions =
      List.generate(61, (index) => 140 + index); // 140〜200
  int? _selectedWeight;
  final List<int> _weightOptions =
      List.generate(121, (index) => 30 + index); // 30〜150kg
  bool enableGatoure = false;
  String? selectedPrefecture;
  String? selectedCity;
  late String originId;
  // 禁止ワードリスト（必要に応じて拡張可）
  final List<String> prohibitedWords = [
    'ちんこ',
    'まんこ',
    'うんこ',
    'しね',
    'fuck',
    '死ね',
    'sex',
    'セックス',
    'ち○こ', // 回避的表記対策も追加可能
  ];

  final Map<String, List<String>> prefectureData = PreAndCity.data;

  @override
  void initState() {
    super.initState();
    initializeProfile();
  }

  Future<void> initializeProfile() async {
    deviceId = await getDeviceUUID();
    infoList = await fetchInfo();

    setState(() {
      _nameController.text = infoList["name"] ?? "";
      _dateController.text = infoList["startDay"] ?? "";
      _selectedHeight = infoList["height"] as int?;
      _selectedWeight = infoList["weight"] as int?;
      _idController.text = infoList["id"] ?? "";
      originId = infoList["id"] ?? "";
      _isLoading = false;
      pickedFile = null;
    });
  }

  // カメラを起動して画像を取得する
  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    deviceId = await getDeviceUUID(); // デバイス ID を取得

    try {
      pickedFile = await picker.pickImage(source: ImageSource.camera);

      if (pickedFile != null) {
        if (kIsWeb) {
          try {
            Uint8List rawBytes = await pickedFile!.readAsBytes();

            // 🌟 トリミング画面に移動
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CropPhaseScreen(
                  imageBytes: rawBytes,
                  onCropped: (Uint8List croppedBytes) {
                    setState(() {
                      imageBytes = croppedBytes;
                    });
                  },
                ),
              ),
            );
          } catch (e) {
            print("トリミングエラー: $e");
          }
        }
      } else {
        print("❌ No image selected.");
      }
    } catch (e) {
      print("❌ エラーが発生しました: $e");
    }
  }

  Widget buildSectionCard({required String title, required Widget child}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: SizedBox(
        width: double.infinity, // 横幅いっぱいに広げる
        child: Card(
          elevation: 6,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Color.fromARGB(159, 109, 110, 72),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 209, 209, 0),
                  ),
                ),
                SizedBox(height: 12),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
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
                    // ローディングダイアログを表示
                    showDialog(
                      context: context,
                      barrierDismissible: false, // ダイアログ外をタップしても閉じない
                      builder: (BuildContext context) {
                        return Center(
                            child: CircularProgressIndicator(
                                color: Colors.yellowAccent));
                      },
                    );

                    // 初期化
                    bool _canSave = true;

                    // 身長と体重が選択されていない場合
                    if (_selectedHeight == null || _selectedWeight == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('身長と体重を入力してください')),
                      );
                      _canSave = false;
                    }

                    // IDが8文字未満の場合
                    if (_idController.text.length < 8) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('IDを英数字８文字以上で入力してください')),
                      );
                      _canSave = false;
                    }

                    // 名前が未入力の場合
                    if (_nameController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('名前を入力してください')),
                      );
                      _canSave = false;
                    }

                    if (prohibitedWords
                        .any((word) => _nameController.text.contains(word))) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('不適切な単語が名前に含まれています')),
                      );
                      _canSave = false;
                    }

                    // 全ての条件を満たしている場合
                    if (_canSave) {
                      // 処理を実行（例: saveInfoWeb）
                      int con = await saveInfoWeb(
                          _idController.text,
                          _nameController.text,
                          _dateController.text,
                          deviceId,
                          imageBytes,
                          _selectedHeight!,
                          _selectedWeight!,
                          originId);

                      originId = _idController.text;

                      // 処理が終わったらダイアログを閉じる
                      Navigator.pop(context); // ダイアログを閉じる

                      if (con == 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('このIDは既に使用されています')),
                        );
                      } else if (con == 2) {
                        // 成功メッセージを表示
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('プロフィール情報が保存されました！')),
                        );
                        if (widget.condition == "firstTime") {
                          Navigator.pop(context, "completed");
                        }
                      }
                    } else {
                      // 処理が無効な場合でもダイアログを閉じる
                      Navigator.pop(context);
                    }
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
                  child: Text("変更を保存する"),
                ),
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
              child: CircularProgressIndicator(
                color: Colors.yellowAccent,
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
                            color: Colors.grey[400],
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
                                        color: Colors.black,
                                      ),
                                    ),
                        ),
                        Positioned(
                          bottom: 12,
                          right: 12,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 209, 209, 0),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 6,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: IconButton(
                              onPressed: _takePhoto,
                              icon: Icon(Icons.photo, color: Colors.black87),
                              iconSize: 20,
                              tooltip: '写真を撮る',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  buildSectionCard(
                    title: "Id",
                    child: TextField(
                      controller: _idController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "英数字８文字以上で、Idを入力してください",
                        prefixIcon: Icon(Icons.person),
                        filled: true,
                        fillColor: Colors.grey[900],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  buildSectionCard(
                    title: "ユーザーネーム",
                    child: TextField(
                      controller: _nameController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Enter your name",
                        prefixIcon: Icon(Icons.person),
                        filled: true,
                        fillColor: Colors.grey[900],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  buildSectionCard(
                    title: "トレーニングを始めた日",
                    child: GestureDetector(
                      onTap: () async {
                        DateTime? selectedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (selectedDate != null) {
                          _dateController.text =
                              selectedDate.toString().split(' ')[0];
                        }
                      },
                      child: AbsorbPointer(
                        child: TextField(
                          controller: _dateController,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Enter your start day of muscle training',
                            prefixIcon: Icon(Icons.calendar_today),
                            filled: true,
                            fillColor: Colors.grey[900],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  buildSectionCard(
                    title: "身体情報",
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "身長",
                          style: TextStyle(
                              color: Color.fromARGB(255, 209, 209, 0),
                              fontSize: 16),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        DropdownButtonFormField<int>(
                          value: _heightOptions.contains(_selectedHeight)
                              ? _selectedHeight
                              : null,
                          items: _heightOptions.map((height) {
                            return DropdownMenuItem<int>(
                              value: height,
                              child: Text('$height cm'),
                            );
                          }).toList(),
                          dropdownColor: Colors.grey[900],
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Select your Height (kg)',
                            prefixIcon: Icon(Icons.monitor_weight),
                            filled: true,
                            fillColor: Colors.grey[900],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _selectedHeight = value;
                            });
                          },
                        ),
                        SizedBox(height: 12),
                        Text(
                          "体重",
                          style: TextStyle(
                              color: Color.fromARGB(255, 209, 209, 0),
                              fontSize: 16),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        DropdownButtonFormField<int>(
                          value: _weightOptions.contains(_selectedWeight)
                              ? _selectedWeight
                              : null,
                          dropdownColor: Colors.grey[900],
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Select your weight (kg)',
                            hintStyle: TextStyle(color: Colors.white),
                            prefixIcon: Icon(Icons.monitor_weight),
                            filled: true,
                            fillColor: Colors.grey[900],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: _weightOptions.map((weight) {
                            return DropdownMenuItem<int>(
                              value: weight,
                              child: Text('$weight kg'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedWeight = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  // buildSectionCard(
                  //     title: "training together",
                  //     child: Column(
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         Row(
                  //           children: [
                  //             Checkbox(
                  //               value: enableGatoure,
                  //               onChanged: (value) {
                  //                 setState(() {
                  //                   enableGatoure = value ?? false;
                  //                 });
                  //               },
                  //               activeColor: Color.fromARGB(255, 209, 209, 0),
                  //             ),
                  //             Text(
                  //               '合トレ機能を使用しますか？',
                  //               style: TextStyle(color: Colors.white),
                  //             ),
                  //           ],
                  //         ),
                  //         SizedBox(height: 16),
                  //         if (enableGatoure) ...[
                  //           Text(
                  //             '希望の合トレ場所',
                  //             style: TextStyle(color: Colors.white),
                  //           ),
                  //           SizedBox(height: 16),
                  //           DropdownButtonFormField<String>(
                  //             dropdownColor: Colors.black,
                  //             decoration: InputDecoration(
                  //               labelText: "都道府県を選択",
                  //               labelStyle: TextStyle(color: Colors.white),
                  //               filled: true,
                  //               fillColor: Colors.grey[900],
                  //               border: OutlineInputBorder(
                  //                   borderRadius: BorderRadius.circular(10)),
                  //             ),
                  //             value: selectedPrefecture,
                  //             items: prefectureData.keys.map((String key) {
                  //               return DropdownMenuItem<String>(
                  //                 value: key,
                  //                 child: Text(key,
                  //                     style: TextStyle(color: Colors.white)),
                  //               );
                  //             }).toList(),
                  //             onChanged: (value) {
                  //               setState(() {
                  //                 selectedPrefecture = value;
                  //                 selectedCity = null;
                  //               });
                  //             },
                  //           ),
                  //           SizedBox(height: 16),
                  //           if (selectedPrefecture != null)
                  //             DropdownButtonFormField<String>(
                  //               dropdownColor: Colors.black,
                  //               decoration: InputDecoration(
                  //                 labelText: "市町村を選択",
                  //                 labelStyle: TextStyle(color: Colors.white),
                  //                 filled: true,
                  //                 fillColor: Colors.grey[900],
                  //                 border: OutlineInputBorder(
                  //                     borderRadius: BorderRadius.circular(10)),
                  //               ),
                  //               value: selectedCity,
                  //               items: prefectureData[selectedPrefecture]!
                  //                   .map((city) => DropdownMenuItem<String>(
                  //                         value: city,
                  //                         child: Text(city,
                  //                             style: TextStyle(
                  //                                 color: Colors.white)),
                  //                       ))
                  //                   .toList(),
                  //               onChanged: (value) {
                  //                 setState(() {
                  //                   selectedCity = value;
                  //                 });
                  //               },
                  //             ),
                  //         ]
                  //       ],
                  //     )),

                  buildSectionCard(
                    title: "トレーニングの最高記録",
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BestRecordsInputScreen(),
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
                          'タップして最高記録を入力しましょう',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(255, 209, 209, 0),
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 20),
                  widget.condition != "firstTime"
                      ? ElevatedButton(
                          onPressed: () async {
                            bool confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                          backgroundColor: Colors.black,
                                          title: Text("本当に削除しますか？",
                                              style: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 209, 209, 0))),
                                          content: Text(
                                              "プロフィール情報、これまで記録したトレーニング記録、broリストの内容が消えてしまいますがよろしいですか？",
                                              style: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 209, 209, 0))),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(false),
                                              child: Text(
                                                "キャンセル",
                                                style: TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 209, 209, 0)),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(true),
                                              child: Text(
                                                "OK",
                                                style: TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 209, 209, 0)),
                                              ),
                                            ),
                                          ],
                                        )) ??
                                false;

                            if (confirmed) {
                              // broリストから自分を削除（相手側から）
                              await removeFromFriendLists(deviceId);

                              // 自分のコレクション全削除
                              await deleteUserCollections(deviceId);

                              // 必要であればログアウトやページ遷移も
                              // Navigator.pushReplacement(...);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Color.fromARGB(255, 209, 209, 0),
                            padding: EdgeInsets.symmetric(
                                horizontal: 32, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                  color: Color.fromARGB(255, 209, 209, 0)),
                            ),
                          ),
                          child: Text("アカウント情報を削除する"),
                        )
                      : const SizedBox(height: 16),
                  const SizedBox(height: 16)
                ],
              ),
            ),
    );
  }
}
