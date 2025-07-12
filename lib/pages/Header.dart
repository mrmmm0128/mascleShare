import 'package:flutter/material.dart';
import 'package:muscle_share/methods/FetchInfoProfile.dart';

class Header extends StatefulWidget implements PreferredSizeWidget {
  final String title;

  const Header({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  State<Header> createState() => _HeaderState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _HeaderState extends State<Header> {
  String? imageUrl;

  @override
  void initState() {
    super.initState();
    fetchInfo().then((info) {
      setState(() {
        imageUrl = info["url"];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      iconTheme: IconThemeData(color: Color.fromARGB(255, 209, 209, 0)),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // ← 左寄せ
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ✅ プロフィール画像（左端）
              if (imageUrl != null && imageUrl!.isNotEmpty)
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(imageUrl!),
                  backgroundColor: Colors.grey[800],
                )
              else
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey[800],
                  child: Icon(Icons.person, color: Colors.white),
                ),
              SizedBox(width: 16),
              Text(
                widget.title,
                style: TextStyle(
                  color: Color.fromARGB(255, 209, 209, 0),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
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
    );
  }
}
