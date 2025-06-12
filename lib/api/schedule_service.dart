import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ScheduleService {
  final Dio _dio = Dio();
  final String _baseUrl = 'http://ocb.iptime.org:8080/api/schedules';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.read(key: 'accessToken');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // 사용자의 모든 일정 조회
  Future<List<dynamic>> getAllSchedulesByUser(int userId) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '$_baseUrl/user/$userId',
        options: Options(headers: headers),
      );
      return response.data as List<dynamic>;
    } catch (e) {
      throw Exception('일정 목록을 불러오는데 실패했습니다: $e');
    }
  }

  // 일정 상세 조회
  Future<dynamic> getScheduleById(int scheduleId) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '$_baseUrl/$scheduleId',
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      if (e.toString().contains('404')) {
        throw Exception('일정을 찾을 수 없습니다.');
      }
      throw Exception('일정을 불러오는데 실패했습니다: $e');
    }
  }

  // 일정 생성
  Future<dynamic> createSchedule(
    int userId,
    Map<String, dynamic> scheduleData,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.post(
        '$_baseUrl?userId=$userId',
        data: scheduleData,
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      throw Exception('일정 생성에 실패했습니다: $e');
    }
  }

  // 일정 수정
  Future<dynamic> updateSchedule(
    int scheduleId,
    int userId,
    Map<String, dynamic> scheduleData,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.put(
        '$_baseUrl/$scheduleId?userId=$userId',
        data: scheduleData,
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      if (e.toString().contains('403')) {
        throw Exception('일정을 수정할 권한이 없습니다.');
      } else if (e.toString().contains('404')) {
        throw Exception('일정을 찾을 수 없습니다.');
      }
      throw Exception('일정 수정에 실패했습니다: $e');
    }
  }

  // 일정 삭제
  Future<void> deleteSchedule(int scheduleId, int userId) async {
    try {
      final headers = await _getHeaders();
      await _dio.delete(
        '$_baseUrl/$scheduleId?userId=$userId',
        options: Options(headers: headers),
      );
    } catch (e) {
      if (e.toString().contains('403')) {
        throw Exception('일정을 삭제할 권한이 없습니다.');
      } else if (e.toString().contains('404')) {
        throw Exception('일정을 찾을 수 없습니다.');
      }
      throw Exception('일정 삭제에 실패했습니다: $e');
    }
  }

  // 일정 공유 상태 변경
  Future<dynamic> updateScheduleShareStatus(
    int scheduleId,
    bool isShared,
    int userId,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.patch(
        '$_baseUrl/$scheduleId/share?userId=$userId',
        data: {'isShared': isShared},
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      if (e.toString().contains('403')) {
        throw Exception('공유 상태를 변경할 권한이 없습니다.');
      } else if (e.toString().contains('404')) {
        throw Exception('일정을 찾을 수 없습니다.');
      }
      throw Exception('공유 상태 변경에 실패했습니다: $e');
    }
  }

  // 일정 알림 설정
  Future<dynamic> updateScheduleReminder(
    int scheduleId,
    bool enabled,
    String? reminderTime,
    int userId,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.patch(
        '$_baseUrl/$scheduleId/reminder?userId=$userId',
        data: {
          'enabled': enabled,
          if (reminderTime != null) 'reminderTime': reminderTime,
        },
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      if (e.toString().contains('403')) {
        throw Exception('알림 설정을 변경할 권한이 없습니다.');
      } else if (e.toString().contains('404')) {
        throw Exception('일정을 찾을 수 없습니다.');
      }
      throw Exception('알림 설정 변경에 실패했습니다: $e');
    }
  }

  // 특정 위치 주변의 일정 검색
  Future<List<dynamic>> findSchedulesNearby(
    double latitude,
    double longitude,
    double radius,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '$_baseUrl/nearby',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'radius': radius,
        },
        options: Options(headers: headers),
      );
      return response.data as List<dynamic>;
    } catch (e) {
      throw Exception('주변 일정을 불러오는데 실패했습니다: $e');
    }
  }
}
