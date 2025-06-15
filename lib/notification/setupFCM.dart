import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../firebase_options.dart';
import 'fcmHandler.dart';

// FCM 초기화 및 설정
Future<void> setupFCM() async {
  try {
    // Firebase 초기화 (옵션 포함)
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // FCM 권한 요청
    NotificationSettings settings = await FirebaseMessaging.instance
        .requestPermission(alert: true, badge: true, sound: true);

    // FCM 토큰 가져오기
    String? token = await FirebaseMessaging.instance.getToken();

    // 서버에 토큰 전송
    if (token != null) {
      await sendTokenToServer(token);
    }

    // 토큰 갱신 리스너
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      sendTokenToServer(newToken);
    });

    print('FCM 초기화 성공');
  } catch (e) {
    print('FCM 초기화 실패: $e');
    // Firebase 초기화 실패 시에도 앱이 계속 실행되도록 함
  }
}

// 서버에 토큰 전송하는 함수
Future<void> sendTokenToServer(String token) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token');

    if (authToken == null) {
      print('인증 토큰이 없습니다.');
      return;
    }

    final dio = Dio();
    dio.options.headers['Authorization'] = 'Bearer $authToken';

    await dio.post(
      'http://ocb.iptime.org:8080/api/notifications/token',
      data: {'fcmToken': token},
    );

    print('FCM 토큰 서버 전송 성공');
  } catch (e) {
    print('FCM 토큰 서버 전송 실패: $e');
  }
}

// 알림 기능 활성화 함수 (Firebase 설정 완료 후 호출)
Future<void> enableNotifications() async {
  try {
    await setupFCM();
    await setupNotifications();
    print('알림 기능이 성공적으로 활성화되었습니다.');
  } catch (e) {
    print('알림 기능 활성화 실패: $e');
  }
}

// 알림 기능 비활성화 함수
Future<void> disableNotifications() async {
  try {
    // FCM 토큰 삭제
    await FirebaseMessaging.instance.deleteToken();
    print('알림 기능이 비활성화되었습니다.');
  } catch (e) {
    print('알림 기능 비활성화 실패: $e');
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
