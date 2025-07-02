import 'package:flutter/material.dart';
import 'package:muscle_share/pages/FriendListScreen.dart';
import 'package:muscle_share/pages/QuickInputScreen.dart';
import 'package:muscle_share/pages/FriendTrainingTimeline.dart';
import 'package:muscle_share/pages/TrainingCarenderScreen.dart';
import 'package:muscle_share/pages/profile.dart';

class TopPage extends StatefulWidget {
  const TopPage({Key? key}) : super(key: key);

  @override
  State<TopPage> createState() => _TopPageState();
}

class _TopPageState extends State<TopPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    ToolSelectionScreen(),
    QuickInputScreen(),
    TrainingCalendarScreen(),
    FriendListScreen(),
    ProfileScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[900],
        selectedItemColor: Colors.yellowAccent,
        unselectedItemColor: Colors.white70,
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.event_note),
            label: 'タイムライン',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: '記録する',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timeline),
            label: 'レポート',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: '探す',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'プロフィール',
          ),
        ],
      ),
    );
  }
}
