// home_screen.dart
import 'package:flutter/material.dart';
import 'package:muscle_share/profile.dart';
import 'package:muscle_share/upload_photo.dart';

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
        backgroundColor: Colors.white,
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
            'Masclue Share',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white, // 背景色を白に
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black.withOpacity(0.3)), // 薄い枠線
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: DropdownButton<String>(
                value: selectedCategory,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCategory = newValue!;
                  });
                },
                items: categories.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Center(
                        child: Text(
                      value,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold, // アイテムのテキストを太字に
                      ),
                    )),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                    'プライベートモード',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          isPrivateMode ? FontWeight.bold : FontWeight.normal,
                      color: isPrivateMode ? Colors.black : Colors.grey,
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
                    '全世界モード',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          !isPrivateMode ? FontWeight.bold : FontWeight.normal,
                      color: !isPrivateMode ? Colors.black : Colors.grey,
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
                      Icon(Icons.man),
                      const SizedBox(height: 10),
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
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UploadScreen()),
          );
        },
        child: Icon(Icons.add_a_photo, color: Colors.white),
      ),
    );
  }
}
