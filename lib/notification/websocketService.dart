import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'dart:convert';
import 'package:dio/dio.dart';

class WebSocketService {
  late StompClient stompClient;
  bool isConnected = false;

  // 웹소켓 연결 초기화
  void initializeWebSocket(String authToken) {
    stompClient = StompClient(
      config: StompConfig(
        url: 'ws://your-server-url/ws',  // 서버의 웹소켓 엔드포인트
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

    // 연결 메시지 전송 (서버의 notifications.connect 엔드포인트와 매핑)
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
  }

  // 알림 처리
  void handleNotification(Map<String, dynamic> notification) {
    // NotificationMessage 데이터 처리
    String title = notification['title'] ?? '';
    String message = notification['message'] ?? '';
    String type = notification['type'] ?? '';
    int referenceId = notification['referenceId'] ?? 0;

    // 앱 내 알림 표시 또는 이벤트 발생
    // 예: 이벤트 버스 또는 상태 관리 솔루션을 통해 UI 업데이트
  }
}