import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:muscle_share/pages/TopPage.dart';
import 'package:muscle_share/pages/Profile.dart'; // ← プロフィール登録画面
import 'package:muscle_share/methods/getDeviceId.dart'; // ← getDeviceIDweb()

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkProfile();
  }

  Future<void> _checkProfile() async {
    String deviceId = await getDeviceIDweb();

    final profileDoc = await FirebaseFirestore.instance
        .collection(deviceId)
        .doc("profile")
        .get();

    await Future.delayed(Duration(seconds: 2)); // スプラッシュ表示時間

    if (profileDoc.exists) {
      // プロフィールが存在 → TopPageへ
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TopPage()),
      );
    } else {
      // プロフィールが存在しない → 登録を促す
      if (!mounted) return;

      await showDialog(
        context: context,
        barrierDismissible: false, // 外タップで閉じさせない
        builder: (context) => AlertDialog(
          backgroundColor: Colors.black,
          title: Text(
            "利用規約への同意",
            style: TextStyle(color: Color.fromARGB(255, 209, 209, 0)),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "以下の利用規約に同意いただく必要があります：\n\n"
                  "・不適切なユーザー名、コメント、写真の使用は禁止です。\n"
                  "・誹謗中傷、わいせつ、暴力的な内容は禁止です。\n"
                  "・不適切な写真、コメントを確認した際には通報ボタンより報告お願いいたします。。\n"
                  "・違反が確認された場合、アカウントを停止・削除させていただきます。\n\n"
                  "これらの規約に同意のうえ、プロフィール登録を開始してください。",
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 同意して次へ進む
              },
              child: Text(
                "同意する",
                style: TextStyle(color: Color.fromARGB(255, 209, 209, 0)),
              ),
            ),
          ],
        ),
      );

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.black,
          title: Text(
            "ようこそ！",
            style: TextStyle(color: Color.fromARGB(255, 209, 209, 0)),
          ),
          content: Text(
            "まずはプロフィールを登録しましょう。",
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "OK",
                style: TextStyle(color: Color.fromARGB(255, 209, 209, 0)),
              ),
            ),
          ],
        ),
      );

      // Profile登録画面へ遷移 → 戻ってきたら完了メッセージ表示
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileScreen(condition: "firstTime"),
        ),
      );

      if (!mounted) return;

      // result が "completed" の場合にメッセージ表示
      if (result == "completed") {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.black,
            title: Text(
              "準備完了！",
              style: TextStyle(color: Color.fromARGB(255, 209, 209, 0)),
            ),
            content: Text(
              "さあ、はじめよう。",
              style: TextStyle(color: Colors.white),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  "OK",
                  style: TextStyle(color: Color.fromARGB(255, 209, 209, 0)),
                ),
              ),
            ],
          ),
        );
      }

      // 最後にトップページへ
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TopPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Image.asset(
          'assets/icons/S__22331404.png',
          width: 200,
          height: 200,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
