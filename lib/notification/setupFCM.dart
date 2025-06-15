import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

// FCM 초기화 및 설정
Future<void> setupFCM() async {
  // Firebase 초기화
  await Firebase.initializeApp();

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
