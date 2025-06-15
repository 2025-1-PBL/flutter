import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../api/config.dart';
import 'notificationManager.dart';

class WebSocketService {
  late StompClient _stompClient;
  final _storage = const FlutterSecureStorage();
  bool _isConnected = false;

  Future<void> initializeWebSocket() async {
    try {
      final token = await _storage.read(key: 'token');
      if (token == null) {
        throw NotificationError('인증 토큰이 없습니다', null);
      }

      _stompClient = StompClient(
        config: StompConfig(
          url: 'ws://ocb.iptime.org:8080/ws',
          onConnect: _onConnect,
          onDisconnect: _onDisconnect,
          onWebSocketError: (dynamic error) => print('WebSocket 에러: $error'),
          stompConnectHeaders: {'Authorization': 'Bearer $token'},
          webSocketConnectHeaders: {'Authorization': 'Bearer $token'},
        ),
      );

      _stompClient.activate();

      // 연결이 완료될 때까지 대기
      int retryCount = 0;
      while (!_isConnected && retryCount < 5) {
        await Future.delayed(const Duration(seconds: 1));
        retryCount++;
      }

      if (!_isConnected) {
        throw NotificationError('WebSocket 연결 시간 초과', null);
      }
    } catch (e) {
      throw NotificationError('WebSocket 초기화 실패', e);
    }
  }

  void _onConnect(StompFrame frame) {
    print('WebSocket 연결됨');
    _isConnected = true;

    // 알림 구독
    _stompClient.subscribe(
      destination: '/user/queue/notifications',
      callback: (frame) {
        if (frame.body != null) {
          final notification = json.decode(frame.body!);
          _handleNotification(notification);
        }
      },
    );
  }

  void _onDisconnect(StompFrame frame) {
    print('WebSocket 연결 해제');
    _isConnected = false;
  }

  void _handleNotification(Map<String, dynamic> notification) {
    // 알림 처리 로직
    print('새로운 알림 수신: $notification');

    // NotificationManager를 통해 알림 처리
    NotificationManager().getUnreadCount().then((count) {
      print('읽지 않은 알림 수: $count');
    });
  }

  void dispose() {
    if (_isConnected) {
      _stompClient.deactivate();
    }
  }
}
