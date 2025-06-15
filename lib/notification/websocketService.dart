import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  late StompClient stompClient;
  bool isConnected = false;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // 웹소켓 연결 초기화
  Future<void> initializeWebSocket() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (authToken == null) {
        print('인증 토큰이 없어 웹소켓 연결을 건너뜁니다.');
        return;
      }

      stompClient = StompClient(
        config: StompConfig(
          url: 'ws://ocb.iptime.org:8080/ws', // 실제 서버 웹소켓 엔드포인트
          onConnect: onConnect,
          onDisconnect: onDisconnect,
          onWebSocketError: onError,
          stompConnectHeaders: {'Authorization': 'Bearer $authToken'},
          webSocketConnectHeaders: {'Authorization': 'Bearer $authToken'},
          reconnectDelay: const Duration(seconds: 5),
        ),
      );

      connect();
    } catch (e) {
      print('웹소켓 초기화 실패: $e');
    }
  }

  // 연결
  void connect() {
    if (!isConnected) {
      stompClient.activate();
    }
  }

  // 연결 해제
  void disconnect() {
    if (isConnected) {
      stompClient.deactivate();
      isConnected = false;
    }
  }

  // 연결 성공 시
  void onConnect(StompFrame frame) {
    isConnected = true;
    print('웹소켓 연결 성공');

    // 사용자별 알림 구독
    stompClient.subscribe(
      destination: '/user/queue/notifications',
      callback: (StompFrame frame) {
        if (frame.body != null) {
          try {
            final Map<String, dynamic> notification = json.decode(frame.body!);
            handleNotification(notification);
          } catch (e) {
            print('알림 파싱 실패: $e');
          }
        }
      },
    );

    // 일반 알림 구독 (모든 사용자)
    stompClient.subscribe(
      destination: '/topic/notifications',
      callback: (StompFrame frame) {
        if (frame.body != null) {
          try {
            final Map<String, dynamic> notification = json.decode(frame.body!);
            handleNotification(notification);
          } catch (e) {
            print('일반 알림 파싱 실패: $e');
          }
        }
      },
    );

    // 연결 메시지 전송
    stompClient.send(
      destination: '/app/notifications.connect',
      body: json.encode({
        'status': 'connected',
        'timestamp': DateTime.now().toIso8601String(),
      }),
    );
  }

  // 연결 해제 시
  void onDisconnect(StompFrame frame) {
    isConnected = false;
    print('웹소켓 연결 해제');
  }

  // 오류 발생 시
  void onError(dynamic error) {
    print('웹소켓 오류: $error');
    isConnected = false;
  }

  // 알림 처리
  void handleNotification(Map<String, dynamic> notification) {
    try {
      String title = notification['title'] ?? '새 알림';
      String message = notification['message'] ?? '';
      String type = notification['type'] ?? '';
      int referenceId = notification['referenceId'] ?? 0;
      int notificationId = notification['id'] ?? 0;

      print('실시간 알림 수신: $title - $message');

      // 로컬 알림 표시
      _showLocalNotification(title, message, type, referenceId, notificationId);

      // 서버에 읽음 처리 요청 (선택사항)
      _markNotificationAsReceived(notificationId);
    } catch (e) {
      print('알림 처리 실패: $e');
    }
  }

  // 로컬 알림 표시
  Future<void> _showLocalNotification(
    String title,
    String message,
    String type,
    int referenceId,
    int notificationId,
  ) async {
    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
            'realtime_notifications',
            '실시간 알림',
            importance: Importance.high,
            priority: Priority.high,
            showWhen: true,
            enableVibration: true,
            playSound: true,
          );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
      );

      await flutterLocalNotificationsPlugin.show(
        notificationId,
        title,
        message,
        platformChannelSpecifics,
        payload: json.encode({
          'type': type,
          'referenceId': referenceId,
          'notificationId': notificationId,
        }),
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

  // 연결 상태 확인
  bool get isWebSocketConnected => isConnected;

  // 수동으로 연결 재시도
  void reconnect() {
    if (!isConnected) {
      print('웹소켓 재연결 시도');
      connect();
    }
  }

  // 서비스 정리
  void dispose() {
    disconnect();
  }
}
