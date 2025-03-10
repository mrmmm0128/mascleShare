// home_screen.dart
import 'package:flutter/material.dart';
import 'package:muscle_share/history_pages/show_history.dart';
import 'package:muscle_share/profile.dart';
import 'package:muscle_share/upload_photo.dart';
import 'package:muscle_share/history_pages/show_history.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = 'All';
  bool isPrivateMode = true;
  final List<String> categories = ['All', 'Chest', 'Back', 'Legs', 'Arms'];
  final List<Map<String, String>> sampleImages = [
    {
      'url': 'https://via.placeholder.com/300x500',
      'caption': 'Chest Day Pump!'
    },
    {
      'url': 'https://via.placeholder.com/300x500',
      'caption': 'Leg Day Intensity!'
    },
    {'url': 'https://via.placeholder.com/300x500', 'caption': 'Back Gains!'},
  ];

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
            'Mascle Share',
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
                MaterialPageRoute(builder: (context) => ShowHistory()),
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            child: Row(
              children: [
                // プライベートと全世界の選択ボタン
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            isPrivateMode = true;
                          });
                        },
                        child: Text(
                          'プライベート',
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
                        onPressed: () {
                          setState(() {
                            isPrivateMode = false;
                          });
                        },
                        child: Text(
                          '全世界',
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
                Container(
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
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: sampleImages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Icon(Icons.man_3_outlined,
                            color: const Color.fromARGB(255, 209, 209, 0)),
                        const SizedBox(width: 8),
                        Text('ユーザー名',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: const Color.fromARGB(255, 209, 209, 0))),
                      ]),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15), // 画像の角を丸める
                        child: Image.network(
                          sampleImages[index]['url']!,
                          width: double.infinity,
                          height: 500,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: double.infinity,
                              height: 500,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius:
                                    BorderRadius.circular(15), // エラー時も角を丸める
                              ),
                              child: Icon(Icons.broken_image,
                                  size: 100, color: Colors.grey),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 8), // 画像とキャプションの間隔
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          sampleImages[index]['caption']!,
                          style: TextStyle(
                              color: const Color.fromARGB(255, 209, 209, 0),
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
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color.fromARGB(255, 209, 209, 0),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UploadScreen()),
          );
        },
        child: Icon(Icons.add_a_photo, color: Colors.black),
      ),
    );
  }
}
