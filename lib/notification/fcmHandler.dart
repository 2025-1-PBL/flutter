import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// 백그라운드 메시지 핸들러
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('백그라운드 메시지: ${message.messageId}');
}

// 포그라운드 알림을 위한 채널 설정
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel',
  '중요 알림',
  importance: Importance.high,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> setupNotifications() async {
  // 백그라운드 핸들러 등록
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 로컬 알림 플러그인 초기화
  await flutterLocalNotificationsPlugin.initialize(
    InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    ),
  );

  // Android용 알림 채널 생성
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  // 포그라운드 메시지 처리
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    // 알림이 있고 Android인 경우 로컬 알림 표시
    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            icon: android.smallIcon,
          ),
        ),
        payload: message.data['referenceId'],
      );
    }

    // 알림 데이터 처리 (NotificationType에 따른 처리)
    handleNotificationData(message.data);
  });

  // 알림 클릭 처리
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('알림 클릭: ${message.data}');
    navigateToScreen(message.data);
  });
}

// 알림 데이터 처리
void handleNotificationData(Map<String, dynamic> data) {
  // NotificationType 및 referenceId에 따른 처리
  String type = data['type'] ?? '';
  String referenceId = data['referenceId'] ?? '';

  // 타입별 처리 로직
  switch (type) {
    case 'NEW_COMMENT':
    // 댓글 알림 처리
      break;
    case 'NEW_ARTICLE':
    // 새 글 알림 처리
      break;
  // 기타 타입 처리
  }
}

// 알림 클릭 시 화면 이동
void navigateToScreen(Map<String, dynamic> data) {
  // 알림 타입에 따라 적절한 화면으로 이동
  String type = data['type'] ?? '';
  String referenceId = data['referenceId'] ?? '';

  switch (type) {
    case 'NEW_COMMENT':
    // 댓글이 달린 게시글로 이동
      break;
    case 'NEW_ARTICLE':
    // 새 게시글로 이동
      break;
  // 기타 타입 처리
  }
}