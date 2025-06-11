import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// FCM 초기화 및 설정
Future<void> setupFCM() async {
  // Firebase 초기화
  await Firebase.initializeApp();

  // FCM 권한 요청
  NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

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
  // 서버의 /api/notifications/token 엔드포인트로 토큰 전송
  // NotificationController.java의 updateFcmToken 메서드에 해당
  try {
    // 실제 구현은 사용 중인 HTTP 클라이언트에 따라 다름
    // dio나 http 패키지 사용
  } catch (e) {
    print('FCM 토큰 서버 전송 실패: $e');
  }
}