import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class NotificationService {
  final Dio _dio = Dio();
  final String _baseUrl = 'http://127.0.0.1:8080/api/notifications';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.read(key: 'token');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // 사용자의 모든 알림 목록 조회
  Future<List<dynamic>> getUserNotifications() async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        _baseUrl,
        options: Options(headers: headers),
      );
      return response.data as List<dynamic>;
    } catch (e) {
      throw Exception('알림 목록을 불러오는데 실패했습니다: $e');
    }
  }

  // 사용자의 읽지 않은 알림 목록 조회
  Future<List<dynamic>> getUnreadNotifications() async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '$_baseUrl/unread',
        options: Options(headers: headers),
      );
      return response.data as List<dynamic>;
    } catch (e) {
      throw Exception('읽지 않은 알림 목록을 불러오는데 실패했습니다: $e');
    }
  }

  // 사용자의 읽지 않은 알림 수 조회
  Future<int> getUnreadCount() async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '$_baseUrl/count',
        options: Options(headers: headers),
      );
      return response.data['count'] as int;
    } catch (e) {
      throw Exception('읽지 않은 알림 수를 불러오는데 실패했습니다: $e');
    }
  }

  // 특정 알림을 읽음 상태로 표시
  Future<void> markAsRead(int notificationId) async {
    try {
      final headers = await _getHeaders();
      await _dio.put(
        '$_baseUrl/$notificationId/read',
        options: Options(headers: headers),
      );
    } catch (e) {
      throw Exception('알림 읽음 처리에 실패했습니다: $e');
    }
  }

  // 사용자의 모든 알림을 읽음 상태로 표시
  Future<void> markAllAsRead() async {
    try {
      final headers = await _getHeaders();
      await _dio.put('$_baseUrl/read-all', options: Options(headers: headers));
    } catch (e) {
      throw Exception('모든 알림 읽음 처리에 실패했습니다: $e');
    }
  }

  // FCM 토큰 업데이트
  Future<void> updateFcmToken(String fcmToken) async {
    try {
      final headers = await _getHeaders();
      await _dio.put(
        '$_baseUrl/token',
        data: {'fcmToken': fcmToken},
        options: Options(headers: headers),
      );
    } catch (e) {
      throw Exception('FCM 토큰 업데이트에 실패했습니다: $e');
    }
  }

  // 알림 삭제 (백엔드에 없는 기능이지만 유용할 수 있음)
  Future<void> deleteNotification(int notificationId) async {
    try {
      final headers = await _getHeaders();
      await _dio.delete(
        '$_baseUrl/$notificationId',
        options: Options(headers: headers),
      );
    } catch (e) {
      throw Exception('알림 삭제에 실패했습니다: $e');
    }
  }

  // 특정 타입의 알림만 조회 (백엔드에 없는 기능이지만 유용할 수 있음)
  Future<List<dynamic>> getNotificationsByType(String type) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '$_baseUrl/type/$type',
        options: Options(headers: headers),
      );
      return response.data as List<dynamic>;
    } catch (e) {
      throw Exception('타입별 알림 목록을 불러오는데 실패했습니다: $e');
    }
  }
}
