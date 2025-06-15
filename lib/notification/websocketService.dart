import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class WebSocketService {
  late StompClient stompClient;
  bool isConnected = false;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // 웹소켓 연결 초기화
  void initializeWebSocket(String authToken) {
    stompClient = StompClient(
      config: StompConfig(
        url: 'ws://ocb.iptime.org:8080/ws', // 실제 서버 웹소켓 엔드포인트
        onConnect: onConnect,
        onDisconnect: onDisconnect,
        onWebSocketError: onError,
        stompConnectHeaders: {'Authorization': 'Bearer $authToken'},
        webSocketConnectHeaders: {'Authorization': 'Bearer $authToken'},
      ),
    );

    connect();
  }

  // 연결
  void connect() {
    stompClient.activate();
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
          final Map<String, dynamic> notification = json.decode(frame.body!);
          handleNotification(notification);
        }
      },
    );

    // 연결 메시지 전송
    stompClient.send(
      destination: '/app/notifications.connect',
      body: json.encode({'status': 'connected'}),
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
    String title = notification['title'] ?? '새 알림';
    String message = notification['message'] ?? '';
    String type = notification['type'] ?? '';
    int referenceId = notification['referenceId'] ?? 0;

    // 로컬 알림 표시
    _showLocalNotification(title, message, type, referenceId);

    print('실시간 알림 수신: $title - $message');
  }

  // 로컬 알림 표시
  Future<void> _showLocalNotification(
    String title,
    String message,
    String type,
    int referenceId,
  ) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'realtime_notifications',
          '실시간 알림',
          importance: Importance.high,
          priority: Priority.high,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      message,
      platformChannelSpecifics,
      payload: json.encode({'type': type, 'referenceId': referenceId}),
    );
  }
}
