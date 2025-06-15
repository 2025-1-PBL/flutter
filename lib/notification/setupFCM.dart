import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform, Process;
import '../firebase_options.dart';
import 'fcmHandler.dart';
import 'websocketService.dart';

// FCM 초기화
Future<void> setupFCM() async {
  // iOS 시뮬레이터에서는 FCM 초기화 건너뛰기
  if (Platform.isIOS && !Platform.environment.containsKey('FLUTTER_TEST')) {
    try {
      final isSimulator = await _isSimulator();
      if (isSimulator) {
        print('iOS 시뮬레이터 감지됨 - FCM 초기화 건너뜀');
        return;
      }
    } catch (e) {
      print('시뮬레이터 체크 실패: $e');
    }
  }

  int retryCount = 0;
  const maxRetries = 3;

  while (retryCount < maxRetries) {
    try {
      print('FCM 초기화 시작... (시도 ${retryCount + 1}/$maxRetries)');

      // Firebase 초기화 전에 앱이 이미 초기화되었는지 확인
      if (Firebase.apps.isEmpty) {
        print('Firebase 앱 초기화...');
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        print('Firebase 앱 초기화 완료');
      } else {
        print('Firebase 앱이 이미 초기화되어 있습니다.');
      }

      // FCM 설정
      print('FCM 설정 시작...');
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
            alert: true,
            badge: true,
            sound: true,
          );
      print('FCM 프레젠테이션 옵션 설정 완료');

      // FCM 핸들러 초기화
      print('FCM 핸들러 초기화 시작...');
      final fcmHandler = FCMHandler();
      await fcmHandler.initialize();
      print('FCM 핸들러 초기화 완료');

      // FCM 토큰 가져오기
      String? token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        print('FCM 토큰: $token');
        await _registerTokenToServer(token);
        print('FCM 설정 완료');
        return; // 성공적으로 완료되면 함수 종료
      } else {
        print('FCM 토큰을 가져오지 못했습니다.');
        throw Exception('FCM 토큰을 가져오지 못했습니다.');
      }
    } catch (e, stackTrace) {
      print('FCM 설정 실패 (시도 ${retryCount + 1}/$maxRetries): $e');
      print('스택 트레이스: $stackTrace');

      retryCount++;
      if (retryCount < maxRetries) {
        print('3초 후 재시도...');
        await Future.delayed(const Duration(seconds: 3));
      } else {
        print('최대 재시도 횟수를 초과했습니다.');
        rethrow;
      }
    }
  }
}

// 시뮬레이터 체크
Future<bool> _isSimulator() async {
  if (Platform.isIOS) {
    try {
      final result = await Process.run('xcrun', ['simctl', 'list', 'devices']);
      return result.stdout.toString().contains('Booted');
    } catch (e) {
      print('시뮬레이터 체크 실패: $e');
      return false;
    }
  }
  return false;
}

// 서버에 FCM 토큰 등록
Future<void> _registerTokenToServer(String token) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token');

    if (authToken != null) {
      final dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer $authToken';

      await dio.put(
        'http://ocb.iptime.org:8080/api/notifications/token',
        data: {'fcmToken': token, 'deviceType': 'mobile', 'platform': 'ios'},
      );

      print('FCM 토큰이 서버에 등록되었습니다.');
    } else {
      print('인증 토큰이 없어 FCM 토큰을 등록할 수 없습니다.');
    }
  } catch (e) {
    print('FCM 토큰 서버 등록 실패: $e');
  }
}

// 알림 시스템 전체 초기화
Future<void> setupNotifications() async {
  try {
    print('알림 시스템 초기화 시작...');

    // FCM 초기화
    await setupFCM();
    print('FCM 초기화 완료');

    // 웹소켓 서비스 초기화
    print('웹소켓 서비스 초기화 시작...');
    final webSocketService = WebSocketService();
    await webSocketService.initializeWebSocket();
    print('웹소켓 서비스 초기화 완료');

    print('알림 시스템 초기화 완료');
  } catch (e, stackTrace) {
    print('알림 시스템 초기화 실패: $e');
    print('스택 트레이스: $stackTrace');
    rethrow;
  }
}

// 알림 기능 활성화 (수동 호출용)
Future<void> enableNotifications() async {
  try {
    print('알림 기능 활성화 시작...');
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
    print('알림 기능 비활성화 시작...');
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
    print('알림 권한 확인 중...');
    NotificationSettings settings =
        await FirebaseMessaging.instance.getNotificationSettings();
    print('알림 권한 상태: ${settings.authorizationStatus}');
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  } catch (e) {
    print('알림 권한 확인 실패: $e');
    return false;
  }
}
