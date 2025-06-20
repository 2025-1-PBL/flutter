import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../firebase_options.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// 백그라운드 메시지 핸들러
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('백그라운드 메시지: ${message.messageId}');
  } catch (e) {
    print('백그라운드 메시지 처리 실패: $e');
  }
}

class FCMHandler {
  static final FCMHandler _instance = FCMHandler._internal();
  factory FCMHandler() => _instance;
  FCMHandler._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();
  static final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // FCM 초기화
  Future<void> initialize() async {
    try {
      // 권한 요청
      await _requestPermission();

      // FCM 토큰 가져오기
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        print('FCM 토큰: $token');
        await _registerTokenToServer(token);
      }

      // 토큰 갱신 리스너
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        print('FCM 토큰 갱신: $newToken');
        _registerTokenToServer(newToken);
      });

      // 포그라운드 메시지 핸들러
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // 백그라운드 메시지 핸들러
      FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

      // 알림 클릭 핸들러
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationClick);

      print('FCM 핸들러 초기화 완료');
    } catch (e) {
      print('FCM 핸들러 초기화 실패: $e');
    }
  }

  // 알림 권한 요청
  Future<void> _requestPermission() async {
    try {
      NotificationSettings settings = await _firebaseMessaging
          .requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      print('알림 권한 상태: ${settings.authorizationStatus}');
    } catch (e) {
      print('알림 권한 요청 실패: $e');
    }
  }

  // 서버에 FCM 토큰 등록
  Future<void> _registerTokenToServer(String token) async {
    try {
      // SharedPreferences 대신 FlutterSecureStorage 사용
      final authToken = await _storage.read(key: 'token');

      if (authToken != null) {
        final dio = Dio();
        dio.options.headers['Authorization'] = 'Bearer $authToken';

        await dio.post(
          'http://ocb.iptime.org:8080/api/notifications/fcm-token',
          data: {
            'fcmToken': token,
            'deviceType': 'mobile',
            'platform': 'flutter',
          },
        );

        print('FCM 토큰 요청 데이터: ${jsonEncode({
          'fcmToken': token,
          'deviceType': 'mobile',
          'platform': 'flutter',
        })}');

        print('FCM 토큰이 서버에 등록되었습니다.');
      } else {
        print('인증 토큰이 없어 FCM 토큰을 등록할 수 없습니다.');
      }
    } catch (e) {
      print('FCM 토큰 서버 등록 실패: $e');
    }
  }

  // 포그라운드 메시지 처리
  void _handleForegroundMessage(RemoteMessage message) {
    print('포그라운드 메시지 수신: ${message.messageId}');

    try {
      String title = message.notification?.title ?? '새 알림';
      String body = message.notification?.body ?? '';
      Map<String, dynamic> data = message.data;

      // 로컬 알림 표시
      _showLocalNotification(title, body, data);

      // 서버에 수신 확인 (선택사항)
      if (data['notificationId'] != null) {
        _markNotificationAsReceived(int.parse(data['notificationId']));
      }
    } catch (e) {
      print('포그라운드 메시지 처리 실패: $e');
    }
  }

  // 백그라운드 메시지 처리
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    print('백그라운드 메시지 수신: ${message.messageId}');

    try {
      // 백그라운드에서는 로컬 알림을 표시할 수 없으므로
      // 서버에 수신 확인만 처리
      if (message.data['notificationId'] != null) {
        await _markBackgroundNotificationAsReceived(
          int.parse(message.data['notificationId']),
        );
      }
    } catch (e) {
      print('백그라운드 메시지 처리 실패: $e');
    }
  }

  // 백그라운드 알림 수신 확인
  static Future<void> _markBackgroundNotificationAsReceived(
      int notificationId,
      ) async {
    try {
      final authToken = await _storage.read(key: 'token');

      if (authToken != null) {
        final dio = Dio();
        dio.options.headers['Authorization'] = 'Bearer $authToken';

        await dio.put(
          'http://ocb.iptime.org:8080/api/notifications/$notificationId/received',
        );
      }
    } catch (e) {
      print('백그라운드 알림 수신 확인 실패: $e');
    }
  }

  // 알림 클릭 처리
  void _handleNotificationClick(RemoteMessage message) {
    print('알림 클릭: ${message.messageId}');

    try {
      Map<String, dynamic> data = message.data;
      String type = data['type'] ?? '';
      String referenceId = data['referenceId'] ?? '';

      // 알림 타입에 따른 처리
      switch (type) {
        case 'chat':
        // 채팅 화면으로 이동
          print('채팅 알림 클릭: $referenceId');
          break;
        case 'friend_request':
        // 친구 요청 화면으로 이동
          print('친구 요청 알림 클릭: $referenceId');
          break;
        case 'meeting':
        // 모임 알림 화면으로 이동
          print('모임 알림 클릭: $referenceId');
          break;
        default:
        // 일반 알림 처리
          print('일반 알림 클릭: $referenceId');
          break;
      }
    } catch (e) {
      print('알림 클릭 처리 실패: $e');
    }
  }

  // 로컬 알림 표시
  Future<void> _showLocalNotification(
      String title,
      String body,
      Map<String, dynamic> data,
      ) async {
    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
        'fcm_notifications',
        'FCM 알림',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
      );

      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title,
        body,
        platformChannelSpecifics,
        payload: json.encode(data),
      );
    } catch (e) {
      print('로컬 알림 표시 실패: $e');
    }
  }

  // 서버에 알림 수신 확인
  Future<void> _markNotificationAsReceived(int notificationId) async {
    try {
      final authToken = await _storage.read(key: 'token');

      if (authToken != null) {
        final dio = Dio();
        dio.options.headers['Authorization'] = 'Bearer $authToken';

        await dio.put(
          'http://ocb.iptime.org:8080/api/notifications/$notificationId/received',
        );
      }
    } catch (e) {
      print('알림 수신 확인 실패: $e');
    }
  }

  // FCM 토큰 가져오기
  Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }

  // 알림 설정 변경
  Future<void> updateNotificationSettings({
    bool? alert,
    bool? badge,
    bool? sound,
  }) async {
    try {
      await _firebaseMessaging.requestPermission(
        alert: alert ?? true,
        badge: badge ?? true,
        sound: sound ?? true,
      );
    } catch (e) {
      print('알림 설정 변경 실패: $e');
    }
  }
}
