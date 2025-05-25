import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:muscle_share/main.dart';

Future<void> setupPushNotifications() async {
  // iOS用の通知許可リクエスト
  NotificationSettings settings =
      await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('✅ 通知許可されました');
  } else {
    print('❌ 通知許可されていません');
  }

  // トークンの取得（サーバー送信用）
  String? token = await FirebaseMessaging.instance.getToken();
  print("📱 FCMトークン: $token");

  // 🔔 通知受信時のリスナー（フォアグラウンド）
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    if (notification != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          iOS: DarwinNotificationDetails(),
        ),
      );
    }
  });
}
