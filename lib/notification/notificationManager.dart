import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api/config.dart';
import 'notificationService.dart';
import 'fcmHandler.dart';
import 'websocketService.dart';

class NotificationError extends Error {
  final String message;
  final dynamic originalError;

  NotificationError(this.message, this.originalError);

  @override
  String toString() => 'NotificationError: $message';
}

class NotificationManager {
  static final NotificationManager _instance = NotificationManager._internal();
  factory NotificationManager() => _instance;

  final _storage = const FlutterSecureStorage();
  late final NotificationService _notificationService;
  late final FCMHandler _fcmHandler;
  late final WebSocketService _webSocketService;

  bool _isInitialized = false;

  NotificationManager._internal();

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      print('알림 서비스 초기화 시작...');

      // 1. 토큰 확인
      final token = await _storage.read(key: 'token');
      print('토큰 확인: ${token != null ? '토큰 있음' : '토큰 없음'}');

      if (token == null) {
        throw NotificationError('인증 토큰이 없습니다', null);
      }

      // 2. FCM 초기화
      print('FCM 초기화 시작...');
      _fcmHandler = FCMHandler();
      await _fcmHandler.initialize();
      print('FCM 초기화 완료');

      // 3. WebSocket 초기화
      print('WebSocket 초기화 시작...');
      _webSocketService = WebSocketService();
      await _webSocketService.initializeWebSocket();
      print('WebSocket 초기화 완료');

      // 4. 알림 서비스 초기화
      print('알림 서비스 초기화 시작...');
      _notificationService = NotificationService(
        baseUrl: ApiConfig.notificationUrl,
        authToken: token,
      );
      print('알림 서비스 초기화 완료');

      _isInitialized = true;
      print('알림 서비스 전체 초기화 완료');
    } catch (e) {
      print('알림 서비스 초기화 실패: $e');
      throw NotificationError('알림 서비스 초기화 실패', e);
    }
  }

  Future<List<NotificationItem>> getNotifications() async {
    if (!_isInitialized) {
      throw NotificationError('알림 서비스가 초기화되지 않았습니다', null);
    }
    return _notificationService.getNotifications();
  }

  Future<List<NotificationItem>> getUnreadNotifications() async {
    if (!_isInitialized) {
      throw NotificationError('알림 서비스가 초기화되지 않았습니다', null);
    }
    return _notificationService.getUnreadNotifications();
  }

  Future<int> getUnreadCount() async {
    if (!_isInitialized) {
      throw NotificationError('알림 서비스가 초기화되지 않았습니다', null);
    }
    return _notificationService.getUnreadCount();
  }

  Future<void> markAsRead(int notificationId) async {
    if (!_isInitialized) {
      throw NotificationError('알림 서비스가 초기화되지 않았습니다', null);
    }
    await _notificationService.markAsRead(notificationId);
  }

  Future<void> markAllAsRead() async {
    if (!_isInitialized) {
      throw NotificationError('알림 서비스가 초기화되지 않았습니다', null);
    }
    await _notificationService.markAllAsRead();
  }

  Future<void> updateFcmToken(String fcmToken) async {
    if (!_isInitialized) {
      throw NotificationError('알림 서비스가 초기화되지 않았습니다', null);
    }
    await _notificationService.updateFcmToken(fcmToken);
  }

  void dispose() {
    _webSocketService.dispose();
    _isInitialized = false;
  }
}
