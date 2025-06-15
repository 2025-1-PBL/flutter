import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../firebase_options.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notificationManager.dart';

// 백그라운드 메시지 핸들러
@pragma('vm:entry-point')
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

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final _storage = const FlutterSecureStorage();

  // FCM 초기화
  Future<void> initialize() async {
    try {
      print('FCM 초기화 시작...');

      // Firebase 초기화
      print('Firebase 초기화 시작...');
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('Firebase 초기화 완료');

      // FCM 권한 요청
      print('FCM 권한 요청 시작...');
      await _messaging.requestPermission(alert: true, badge: true, sound: true);
      print('FCM 권한 요청 완료');

      // 로컬 알림 초기화
      print('로컬 알림 초기화 시작...');
      const initializationSettingsAndroid = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const initializationSettingsIOS = DarwinInitializationSettings();
      const initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await _localNotifications.initialize(initializationSettings);
      print('로컬 알림 초기화 완료');

      // FCM 토큰 가져오기 및 저장 (재시도 로직 추가)
      print('FCM 토큰 가져오기 시작...');
      String? fcmToken;
      int retryCount = 0;
      const maxRetries = 3;

      while (fcmToken == null && retryCount < maxRetries) {
        try {
          fcmToken = await _messaging.getToken();
          if (fcmToken != null) {
            print('FCM 토큰 획득 성공: $fcmToken');
            break;
          }
        } catch (e) {
          print('FCM 토큰 가져오기 시도 ${retryCount + 1} 실패: $e');
          retryCount++;
          if (retryCount < maxRetries) {
            print('3초 후 재시도...');
            await Future.delayed(const Duration(seconds: 3));
          }
        }
      }

      if (fcmToken != null) {
        await _storage.write(key: 'fcm_token', value: fcmToken);
        try {
          await NotificationManager().updateFcmToken(fcmToken);
          print('FCM 토큰 저장 완료');
        } catch (e) {
          print('FCM 토큰 서버 업데이트 실패: $e');
          // 토큰 저장은 성공했으므로 계속 진행
        }
      } else {
        print('FCM 토큰을 가져오지 못했습니다. 알림 기능이 제한될 수 있습니다.');
        // 토큰이 없어도 계속 진행
      }

      // 토큰 갱신 리스너
      _messaging.onTokenRefresh.listen((newToken) async {
        print('FCM 토큰 갱신: $newToken');
        await _storage.write(key: 'fcm_token', value: newToken);
        try {
          await NotificationManager().updateFcmToken(newToken);
        } catch (e) {
          print('FCM 토큰 갱신 서버 업데이트 실패: $e');
        }
      });

      // 포그라운드 메시지 핸들러
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('포그라운드 메시지 수신: ${message.messageId}');
        _showNotification(message);
      });

      // 백그라운드 메시지 핸들러
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      // 알림 클릭 핸들러
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationClick);

      print('FCM 초기화 완료');
    } catch (e) {
      print('FCM 초기화 실패: $e');
      // FCM 초기화 실패는 치명적이지 않으므로 에러를 던지지 않음
      print('FCM 초기화 실패로 인해 알림 기능이 제한될 수 있습니다.');
    }
  }

  // 알림 권한 요청
  Future<void> _requestPermission() async {
    try {
      NotificationSettings settings = await _messaging.requestPermission(
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
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

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

        print('FCM 토큰이 서버에 등록되었습니다.');
      } else {
        print('인증 토큰이 없어 FCM 토큰을 등록할 수 없습니다.');
      }
    } catch (e) {
      print('FCM 토큰 서버 등록 실패: $e');
    }
  }

  // 포그라운드 메시지 처리
  void _showNotification(RemoteMessage message) {
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
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

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
    return await _messaging.getToken();
  }

  // 알림 설정 변경
  Future<void> updateNotificationSettings({
    bool? alert,
    bool? badge,
    bool? sound,
  }) async {
    try {
      await _messaging.requestPermission(
        alert: alert ?? true,
        badge: badge ?? true,
        sound: sound ?? true,
      );
    } catch (e) {
      print('알림 설정 변경 실패: $e');
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
}
