import 'dart:async';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../api/config.dart';

// 알림 모델 클래스
class NotificationItem {
  final int id;
  final String title;
  final String message;
  final String type;
  final int? referenceId;
  final DateTime createdAt;
  final bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.referenceId,
    required this.createdAt,
    required this.isRead,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as int,
      title: json['title'] as String,
      message: json['message'] as String,
      type: json['type'] as String,
      referenceId: json['referenceId'] as int?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isRead: json['isRead'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'referenceId': referenceId,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
    };
  }
}

// 알림 유형 열거형
enum NotificationType {
  NEW_ARTICLE,
  NEW_COMMENT,
  ARTICLE_LIKE,
  ARTICLE_DISLIKE,
  FRIEND_REQUEST,
  SCHEDULE_INVITATION,
  TEST,
  BLOCK_INVITATION,
  EVENT_REMINDER,
  SYSTEM_NOTIFICATION,
  SCHEDULE_REMINDER,
  LOCATION_PROXIMITY,
}

// 알림 서비스 클래스
class NotificationService {
  final String _baseUrl;
  final http.Client _httpClient;
  final String _authToken;

  NotificationService({
    required String baseUrl,
    required String authToken,
    http.Client? httpClient,
  }) : _baseUrl = baseUrl,
       _authToken = authToken,
       _httpClient = httpClient ?? http.Client();

  // 모든 알림 목록 조회
  Future<List<NotificationItem>> getNotifications() async {
    final response = await _httpClient.get(
      Uri.parse(_baseUrl),
      headers: {
        'Authorization': 'Bearer $_authToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => NotificationItem.fromJson(json)).toList();
    } else {
      throw Exception('알림을 불러오는데 실패했습니다. 상태 코드: ${response.statusCode}');
    }
  }

  // 읽지 않은 알림 목록 조회
  Future<List<NotificationItem>> getUnreadNotifications() async {
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/unread'),
      headers: {
        'Authorization': 'Bearer $_authToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => NotificationItem.fromJson(json)).toList();
    } else {
      throw Exception('읽지 않은 알림을 불러오는데 실패했습니다. 상태 코드: ${response.statusCode}');
    }
  }

  // 읽지 않은 알림 수 조회
  Future<int> getUnreadCount() async {
    final response = await _httpClient.get(
      Uri.parse('$_baseUrl/count'),
      headers: {
        'Authorization': 'Bearer $_authToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data['count'] as int;
    } else {
      throw Exception(
        '읽지 않은 알림 수를 불러오는데 실패했습니다. 상태 코드: ${response.statusCode}',
      );
    }
  }

  // 특정 알림을 읽음 상태로 표시
  Future<void> markAsRead(int notificationId) async {
    final response = await _httpClient.put(
      Uri.parse('$_baseUrl/$notificationId/read'),
      headers: {
        'Authorization': 'Bearer $_authToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('알림을 읽음 처리하는데 실패했습니다. 상태 코드: ${response.statusCode}');
    }
  }

  // 모든 알림을 읽음 상태로 표시
  Future<void> markAllAsRead() async {
    final response = await _httpClient.put(
      Uri.parse('$_baseUrl/read-all'),
      headers: {
        'Authorization': 'Bearer $_authToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('모든 알림을 읽음 처리하는데 실패했습니다. 상태 코드: ${response.statusCode}');
    }
  }

  // FCM 토큰 업데이트
  Future<void> updateFcmToken(String fcmToken) async {
    final response = await _httpClient.put(
      Uri.parse('$_baseUrl/token'),
      headers: {
        'Authorization': 'Bearer $_authToken',
        'Content-Type': 'application/json',
      },
      body: json.encode({'token': fcmToken}),
    );

    if (response.statusCode != 200) {
      throw Exception('FCM 토큰 업데이트에 실패했습니다. 상태 코드: ${response.statusCode}');
    }
  }
}

// WebSocket 알림 관리 클래스
class NotificationWebSocketService {
  final String _webSocketUrl;
  WebSocketChannel? _channel;
  final String _userId;
  final VoidCallback? onConnect;
  final Function(NotificationItem)? onNewNotification;

  NotificationWebSocketService({
    required String webSocketUrl,
    required String userId,
    this.onConnect,
    this.onNewNotification,
  }) : _webSocketUrl = webSocketUrl,
       _userId = userId;

  // WebSocket 연결 시작
  void connect() {
    try {
      _channel = WebSocketChannel.connect(Uri.parse('$_webSocketUrl/ws'));

      // 연결 후 서버에 사용자 ID 전송
      _channel?.sink.add(json.encode({'type': 'connect', 'userId': _userId}));

      if (onConnect != null) {
        onConnect!();
      }

      // 메시지 수신 리스너 설정
      _channel?.stream.listen((message) {
        final data = json.decode(message);
        if (data['type'] == 'notification') {
          final notification = NotificationItem.fromJson(data['notification']);
          if (onNewNotification != null) {
            onNewNotification!(notification);
          }
        }
      });
    } catch (e) {
      debugPrint('WebSocket 연결 오류: $e');
    }
  }

  // 연결 종료
  void disconnect() {
    _channel?.sink.close();
  }
}

// 로컬 알림 서비스 클래스
class LocalNotificationService {
  static final LocalNotificationService _instance =
      LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  Timer? _pollingTimer;
  int _lastNotificationId = 0;
  bool _isInitialized = false;

  // 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );
      const InitializationSettings initializationSettings =
          InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
          );

      final bool? initialized = await _flutterLocalNotificationsPlugin
          .initialize(
            initializationSettings,
            onDidReceiveNotificationResponse: _onNotificationTapped,
          );

      if (initialized == true) {
        const AndroidNotificationChannel channel = AndroidNotificationChannel(
          'general_notifications',
          '일반 알림',
          importance: Importance.high,
        );

        await _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.createNotificationChannel(channel);

        _isInitialized = true;
        print('로컬 알림 서비스 초기화 완료');
      } else {
        print('로컬 알림 서비스 초기화 실패');
      }
    } catch (e) {
      print('로컬 알림 서비스 초기화 오류: $e');
    }
  }

  // 알림 폴링 시작
  void startPolling({Duration interval = const Duration(minutes: 5)}) {
    stopPolling();
    _pollingTimer = Timer.periodic(
      interval,
      (timer) => _checkForNewNotifications(),
    );
    print('알림 폴링 시작 - ${interval.inMinutes}분 간격');
  }

  // 알림 폴링 중지
  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    print('알림 폴링 중지');
  }

  // 새로운 알림 확인
  Future<void> _checkForNewNotifications() async {
    try {
      final notificationService = NotificationService(
        baseUrl: 'YOUR_BASE_URL',
        authToken: 'YOUR_AUTH_TOKEN',
      );

      final unreadNotifications =
          await notificationService.getUnreadNotifications();
      final newNotifications =
          unreadNotifications.where((notification) {
            return notification.id > _lastNotificationId;
          }).toList();

      if (newNotifications.isNotEmpty) {
        print('새로운 알림 ${newNotifications.length}개 발견');
        for (final notification in newNotifications) {
          await _showLocalNotification(notification);
          if (notification.id > _lastNotificationId) {
            _lastNotificationId = notification.id;
          }
        }
      }
    } catch (e) {
      print('알림 확인 중 오류: $e');
    }
  }

  // 로컬 알림 표시
  Future<void> _showLocalNotification(NotificationItem notification) async {
    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
            'general_notifications',
            '일반 알림',
            importance: Importance.high,
            priority: Priority.high,
            showWhen: true,
          );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
      );

      await _flutterLocalNotificationsPlugin.show(
        notification.id,
        notification.title,
        notification.message,
        platformChannelSpecifics,
        payload:
            '{"type": "${notification.type}", "referenceId": ${notification.referenceId}}',
      );

      print('로컬 알림 표시: ${notification.title} - ${notification.message}');
    } catch (e) {
      print('로컬 알림 표시 실패: $e');
    }
  }

  // 알림 클릭 처리
  void _onNotificationTapped(NotificationResponse response) {
    try {
      if (response.payload != null) {
        final payload = response.payload!;
        print('알림 클릭됨: $payload');
        // TODO: 알림 타입에 따른 화면 이동 로직 구현
      }
    } catch (e) {
      print('알림 클릭 처리 실패: $e');
    }
  }

  // 수동으로 알림 확인
  Future<void> checkNotificationsManually() async {
    await _checkForNewNotifications();
  }

  // 알림 권한 요청
  Future<bool> requestPermission() async {
    try {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();
      return androidImplementation != null;
    } catch (e) {
      print('알림 권한 요청 실패: $e');
      return false;
    }
  }

  // 테스트 알림 표시
  Future<void> showTestNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'general_notifications',
          '일반 알림',
          importance: Importance.high,
          priority: Priority.high,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      999,
      '테스트 알림',
      '이것은 테스트 알림입니다.',
      platformChannelSpecifics,
    );
  }

  // 서비스 정리
  void dispose() {
    stopPolling();
    _isInitialized = false;
  }
}
