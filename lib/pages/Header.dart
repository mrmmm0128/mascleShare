import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:muscle_share/methods/FetchInfoProfile.dart';
import 'package:muscle_share/methods/getDeviceId.dart';

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
  int _unreadCount = 0;
  String? _deviceId;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    fetchInfo().then((info) {
      if (mounted) {
        setState(() {
          imageUrl = info["url"];
        });
      }
    });
    _initDeviceIdAndLoadNotifications();
  }

  Future<void> _initDeviceIdAndLoadNotifications() async {
    final id = await getDeviceUUID();
    if (mounted) {
      setState(() {
        _deviceId = id;
      });
    }
    await _loadNotificationCount(id);
  }

  Future<void> _loadNotificationCount(String deviceId) async {
    final notfDoc = await FirebaseFirestore.instance
        .collection(deviceId)
        .doc('notification')
        .get();

    int count = 0;
    if (notfDoc.exists) {
      final data = notfDoc.data();

      for (final key in ['like', 'comment', 'mention']) {
        if (data?[key] is Map<String, dynamic>) {
          final map = data![key] as Map<String, dynamic>;
          for (var entry in map.entries) {
            final nested = entry.value;
            if (nested is Map<String, dynamic>) {
              for (var deviceEntry in nested.entries) {
                final isRead = deviceEntry.value == true;
                if (!isRead) count++;
              }
            }
          }
        }
      }
    }

    if (mounted) {
      setState(() {
        _unreadCount = count;
      });
    }
  }

  void _showNotificationPopup() async {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
      return;
    }

    final deviceId = _deviceId;
    if (deviceId == null) return;

    final docRef =
        FirebaseFirestore.instance.collection(deviceId).doc('notification');
    final snapshot = await docRef.get();
    final data = snapshot.data();

    List<Widget> notifications = [];
    Map<String, dynamic> updatedMap = {};

    Future<void> processSection(
      String key,
      IconData icon,
      Color iconColor,
    ) async {
      if (data?[key] is Map<String, dynamic>) {
        final map = data![key] as Map<String, dynamic>;

        // 通知タイトル
        String titleLabel;
        if (key == 'like') {
          titleLabel = '❤️ いいね通知';
        } else if (key == 'comment') {
          titleLabel = '💬 コメント通知';
        } else if (key == 'mention') {
          titleLabel = '🏷 メンション通知';
        } else {
          titleLabel = '🔔 通知';
        }

        notifications.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            titleLabel,
            style: const TextStyle(color: Colors.yellowAccent),
          ),
        ));

        for (var entry in map.entries) {
          final date = entry.key;
          final nested = entry.value;

          if (nested is Map<String, dynamic>) {
            for (var deviceEntry in nested.entries) {
              final fromId = deviceEntry.key;

              final profileSnapshot = await FirebaseFirestore.instance
                  .collection(fromId)
                  .doc("profile")
                  .get();

              final name = profileSnapshot.data()?['name'] ?? 'Unknown';

              // 通知内容
              String actionText;
              if (key == 'like') {
                actionText = "いいねしました";
              } else if (key == 'comment') {
                actionText = "コメントしました";
              } else if (key == 'mention') {
                actionText = "あなたをメンションしました";
              } else {
                actionText = "アクションがありました";
              }

              notifications.add(ListTile(
                leading: Icon(icon, color: iconColor),
                title: Text(
                  "$name さんが $date に $actionText",
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ));

              // 既読フラグ更新用
              updatedMap["$key.$date.$fromId"] = true;
            }
          }
        }
      }
    }

    await processSection("like", Icons.favorite, Colors.red);
    await processSection("comment", Icons.comment, Colors.blue);
    await processSection("mention", Icons.alternate_email, Colors.amber);

    if (notifications.isEmpty) {
      notifications.add(
        Padding(
          padding: EdgeInsets.all(12),
          child: Text("通知はありません", style: TextStyle(color: Colors.white70)),
        ),
      );
    }

    final overlay = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: kToolbarHeight + MediaQuery.of(context).padding.top,
        right: 12,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 300,
            height: 360,
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.yellowAccent),
              boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 10)],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Text("通知", style: TextStyle(color: Colors.yellowAccent)),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        _overlayEntry?.remove();
                        _overlayEntry = null;
                      },
                    ),
                  ],
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: notifications,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);

    // 🔄 既読フラグを更新
    if (updatedMap.isNotEmpty) {
      await docRef.update(updatedMap);
    }

    if (mounted) {
      setState(() {
        _unreadCount = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      elevation: 0,
      iconTheme: IconThemeData(color: Color.fromARGB(255, 209, 209, 0)),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Row(
            children: [
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
              Expanded(
                child: Text(
                  widget.title,
                  style: TextStyle(
                    color: Color.fromARGB(255, 209, 209, 0),
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              Stack(
                children: [
                  IconButton(
                    icon: Icon(Icons.notifications,
                        color: Color.fromARGB(255, 209, 209, 0)),
                    onPressed: _showNotificationPopup,
                  ),
                  if (_unreadCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$_unreadCount',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 1,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
}
