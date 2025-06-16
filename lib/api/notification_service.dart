import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'config.dart';
import 'auth_service.dart';

class NotificationService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final AuthService _authService = AuthService();

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
        ApiConfig.notificationUrl,
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
        '${ApiConfig.notificationUrl}/unread',
        options: Options(headers: headers),
      );

      print('알림 응답 데이터: ${response.data}'); // 응답 데이터 확인
      print('알림 응답 타입: ${response.data.runtimeType}'); // 응답 데이터 타입 확인

      if (response.data == null) {
        print('알림 데이터가 null입니다.');
        return [];
      }

      return response.data as List<dynamic>;
    } catch (e) {
      print('알림 목록 가져오기 실패: $e');
      throw Exception('읽지 않은 알림 목록을 불러오는데 실패했습니다: $e');
    }
  }

  // 사용자의 읽지 않은 알림 수 조회
  Future<int> getUnreadCount() async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '${ApiConfig.notificationUrl}/count',
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
        '${ApiConfig.notificationUrl}/$notificationId/read',
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
      await _dio.put(
        '${ApiConfig.notificationUrl}/read-all',
        options: Options(headers: headers),
      );
    } catch (e) {
      throw Exception('모든 알림 읽음 처리에 실패했습니다: $e');
    }
  }

  // FCM 토큰 업데이트
  Future<void> updateFcmToken(String fcmToken) async {
    try {
      final headers = await _getHeaders();
      await _dio.put(
        '${ApiConfig.notificationUrl}/token',
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
        '${ApiConfig.notificationUrl}/$notificationId',
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
        '${ApiConfig.notificationUrl}/type/$type',
        options: Options(headers: headers),
      );
      return response.data as List<dynamic>;
    } catch (e) {
      throw Exception('타입별 알림 목록을 불러오는데 실패했습니다: $e');
    }
  }

  // 위치 업데이트 및 근처 일정 알림 요청
  Future<void> updateLocation({
    required double latitude,
    required double longitude,
    double? proximityRadius,
  }) async {
    try {
      final headers = await _getHeaders();

      // 현재 사용자 정보 가져오기
      final userData = await _authService.getCurrentUser();
      final userId = userData['id'] as int;

      final response = await _dio.post(
        '${ApiConfig.baseUrl}/location/update',
        data: {
          'latitude': latitude,
          'longitude': longitude,
          if (proximityRadius != null) 'proximityRadius': proximityRadius,
        },
        queryParameters: {'userId': userId},
        options: Options(headers: headers),
      );

      if (response.statusCode != 200) {
        throw Exception('위치 업데이트 실패');
      }
    } catch (e) {
      print('위치 업데이트 API 호출 실패: $e');
      rethrow;
    }
  }
}
