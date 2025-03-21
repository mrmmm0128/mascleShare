import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 日付フォーマット用

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  IconData _selectedIcon = Icons.person;
  final String _startDate =
      DateFormat('yyyy/MM/dd').format(DateTime.now()); // 筋トレ開始日（今日）

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
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            IconButton(
              icon: Icon(_selectedIcon,
                  size: 30, color: Color.fromARGB(255, 209, 209, 0)),
              onPressed: () {
                setState(() {
                  // ユーザーアイコン選択ロジックをここに追加
                });
              },
            ),
            Center(
              child: Text(
                'User Name',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 209, 209, 0),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Enter your name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
            ),
            Text(
              'Start Day : $_startDate',
              style: TextStyle(
                  fontSize: 16, color: Color.fromARGB(255, 209, 209, 0)),
            ),
          ],
        ),
      ),
    );
  }
}
