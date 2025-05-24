import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:muscle_share/methods/PhotoCropper.dart';
import 'package:muscle_share/methods/PhotoSelect.dart';
import 'package:muscle_share/methods/fetchInfoProfile.dart';
import 'package:muscle_share/methods/getDeviceId.dart';
import 'package:muscle_share/methods/saveDataForProfile.dart';
import 'package:muscle_share/pages/BestRecordsInput.dart';

class ProfileScreen extends StatefulWidget {
  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  // final TextEditingController _benchController = TextEditingController();
  // final TextEditingController _deadController = TextEditingController();
  // final TextEditingController _squatController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  late Uint8List imageBytes = Uint8List(0); // 空のバイト列で初期化
  late XFile? pickedFile = null; // nullで初期化
  String deviceId = "";
  late Map<String, dynamic> infoList = {};
  bool _isLoading = true;
  int? _selectedHeight;
  final List<int> _heightOptions =
      List.generate(61, (index) => 140 + index); // 140〜200
  int? _selectedWeight;
  final List<int> _weightOptions =
      List.generate(121, (index) => 30 + index); // 30〜150kg

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

      _isLoading = false;
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
    return Card(
      elevation: 6,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Color.fromARGB(159, 109, 110, 72),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 209, 209, 0),
              ),
            ),
            SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
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
                              icon: Icon(Icons.add_a_photo,
                                  color: Colors.black87),
                              iconSize: 28,
                              tooltip: '写真を撮る',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  buildSectionCard(
                    title: "User Name",
                    child: TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: "Enter your name",
                        prefixIcon: Icon(Icons.person),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  buildSectionCard(
                    title: "Start Day",
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
                          decoration: InputDecoration(
                            hintText: 'Enter your start day of muscle training',
                            prefixIcon: Icon(Icons.calendar_today),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  buildSectionCard(
                    title: "Personal Data",
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "height",
                          style: TextStyle(
                              color: Color.fromARGB(255, 209, 209, 0),
                              fontSize: 16),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        DropdownButtonFormField<int>(
                          value: _weightOptions.contains(_selectedHeight)
                              ? _selectedHeight
                              : null,
                          items: _heightOptions.map((height) {
                            return DropdownMenuItem<int>(
                              value: height,
                              child: Text('$height cm'),
                            );
                          }).toList(),
                          decoration: InputDecoration(
                            hintText: 'Select your Height (kg)',
                            prefixIcon: Icon(Icons.monitor_weight),
                            filled: true,
                            fillColor: Colors.white,
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
                          "weight",
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
                          decoration: InputDecoration(
                            hintText: 'Select your weight (kg)',
                            prefixIcon: Icon(Icons.monitor_weight),
                            filled: true,
                            fillColor: Colors.white,
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

                  buildSectionCard(
                    title: "Best Records of your training",
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
                          color: Colors.white,
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

                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_selectedHeight != null && _selectedWeight != null) {
                        saveInfoWeb(
                          _nameController.text,
                          _dateController.text,
                          deviceId,
                          imageBytes,
                          _selectedHeight!,
                          _selectedWeight!,
                        );
                      } else {
                        // 例えばダイアログやSnackBarでユーザーに通知する
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('身長と体重を入力してください')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Color.fromARGB(255, 209, 209, 0),
                      padding:
                          EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side:
                            BorderSide(color: Color.fromARGB(255, 209, 209, 0)),
                      ),
                    ),
                    child: Text("変更を保存する"),
                  ),
                  SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}
