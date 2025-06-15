import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../firebase_options.dart';
import 'fcmHandler.dart';
import 'websocketService.dart';

// FCM 초기화
Future<void> setupFCM() async {
  try {
    // Firebase 초기화
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // FCM 핸들러 초기화
    final fcmHandler = FCMHandler();
    await fcmHandler.initialize();

    print('FCM 설정 완료');
  } catch (e) {
    print('FCM 설정 실패: $e');
    rethrow;
  }
}

// 알림 시스템 전체 초기화
Future<void> setupNotifications() async {
  try {
    // 웹소켓 서비스 초기화
    final webSocketService = WebSocketService();
    await webSocketService.initializeWebSocket();

    print('알림 시스템 초기화 완료');
  } catch (e) {
    print('알림 시스템 초기화 실패: $e');
    rethrow;
  }
}

// 알림 기능 활성화 (수동 호출용)
Future<void> enableNotifications() async {
  try {
    await setupFCM();
    await setupNotifications();
    print('알림 기능이 활성화되었습니다.');
  } catch (e) {
    print('알림 기능 활성화 실패: $e');
    rethrow;
  }
}

// 알림 기능 비활성화
Future<void> disableNotifications() async {
  try {
    final webSocketService = WebSocketService();
    webSocketService.dispose();
    print('알림 기능이 비활성화되었습니다.');
  } catch (e) {
    print('알림 기능 비활성화 실패: $e');
    rethrow;
  }
}

// 알림 권한 상태 확인
Future<bool> checkNotificationPermission() async {
  try {
    NotificationSettings settings =
        await FirebaseMessaging.instance.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  } catch (e) {
    print('알림 권한 확인 실패: $e');
    return false;
  }
}
