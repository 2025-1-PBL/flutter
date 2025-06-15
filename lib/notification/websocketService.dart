import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/config.dart';
import '../api/auth_service.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  StompClient? _stompClient;
  final AuthService _authService = AuthService();
  bool _isConnected = false;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool get isConnected => _isConnected;

  // 웹소켓 연결 초기화
  Future<void> initializeWebSocket() async {
    try {
      await connect();
    } catch (e) {
      print('웹소켓 초기화 실패: $e');
    }
  }

  // 연결
  Future<void> connect() async {
    if (_isConnected) {
      print('이미 연결되어 있습니다.');
      return;
    }

    try {
      print('웹소켓 연결 시도...');
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        print('토큰이 없습니다. 로그인이 필요합니다.');
        return;
      }

      // 현재 사용자 정보 가져오기
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null || currentUser['id'] == null) {
        print('사용자 정보를 가져올 수 없습니다.');
        return;
      }

      final userId = currentUser['id'].toString();
      print('웹소켓 연결 - 사용자 ID: $userId');

      _stompClient = StompClient(
        config: StompConfig(
          url: 'ws://ocb.iptime.org:8080/ws',
          onConnect: (StompFrame frame) {
            print('웹소켓 연결 성공');
            _isConnected = true;
            _stompClient?.send(
              destination: '/app/connect',
              body: '{"userId": "$userId"}',
            );
            print('연결 메시지 전송 완료 - userId: $userId');
          },
          onDisconnect: (StompFrame frame) {
            print('웹소켓 연결 해제');
            _isConnected = false;
          },
          onWebSocketError: (dynamic error) {
            print('웹소켓 에러: $error');
            _isConnected = false;
          },
          onStompError: (StompFrame frame) {
            print('STOMP 에러: ${frame.body}');
            _isConnected = false;
          },
          onDebugMessage: (String msg) {
            print('STOMP 디버그: $msg');
          },
          stompConnectHeaders: {'Authorization': 'Bearer $token'},
          webSocketConnectHeaders: {'Authorization': 'Bearer $token'},
        ),
      );

      _stompClient?.activate();
      print('웹소켓 클라이언트 활성화됨');
    } catch (e) {
      print('웹소켓 연결 실패: $e');
      _isConnected = false;
    }
  }

  // 연결 해제
  void disconnect() {
    if (_isConnected) {
      _stompClient?.deactivate();
      _isConnected = false;
    }
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
  bool get isWebSocketConnected => _isConnected;

  // 수동으로 연결 재시도
  void reconnect() {
    if (!_isConnected) {
      print('웹소켓 재연결 시도');
      connect();
    }
  }

  // 서비스 정리
  void dispose() {
    disconnect();
  }
}
