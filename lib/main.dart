import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mentions/flutter_mentions.dart';
import 'package:muscle_share/firebase_options.dart';
//import 'package:muscle_share/methods/alert.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:muscle_share/pages/SplashScreen.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // 🔹 バックグラウンド通知の処理を書く（必要なら）
  print("💬 BG通知受信: ${message.messageId}");
}

Future<void> setupFirebaseMessaging() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // 1. 通知の許可をリクエスト
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');

  // 2. 許可が得られた場合のみトークンを取得
  if (settings.authorizationStatus == AuthorizationStatus.authorized ||
      settings.authorizationStatus == AuthorizationStatus.provisional) {
    try {
      // APNSトークンを明示的に取得してみる（デバッグ用）
      String? apnsToken = await messaging.getAPNSToken();
      print("APNS Token: $apnsToken"); // これが null でないか確認

      if (apnsToken != null) {
        String? fcmToken = await messaging.getToken();
        print("Firebase Messaging Token: $fcmToken");
        // ここで fcmToken をサーバーに送信するなどの処理
      } else {
        print("APNS token was null. FCM token cannot be generated.");
        // APNSトークンが取得できない場合の処理や再試行ロジックを検討
      }
    } catch (e) {
      print("Error getting token: $e");
    }
  } else {
    print('User declined or has not accepted permission');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  //await setupFirebaseMessaging();
  //FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // 🔔 通知チャネル初期化（iOS/Android両方に必要）
  // const initializationSettings = InitializationSettings(
  //   android: AndroidInitializationSettings('@mipmap/ic_launcher'),
  //   iOS: DarwinInitializationSettings(),
  // );
  // await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(const Portal(child: MyApp()));
  // setupPushNotifications();
  // // 🔔 通知設定
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      title: 'MuscleShare',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        canvasColor: Colors.grey[900], // ← これが BottomNavigationBar の背景に効く！
      ),
      home: SplashScreen(),
    );
  }
}
