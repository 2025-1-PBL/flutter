import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import 'auth_service.dart';
import 'config.dart';

class ScheduleService {
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

  // 토큰 만료 여부 확인
  bool _isTokenExpired(DioException e) {
    return e.response?.statusCode == 401 ||
        e.response?.statusCode == 403 ||
        e.message?.contains('만료된 JWT 토큰') == true ||
        e.message?.contains('유효한 JWT 토큰이 없습니다') == true;
  }

  // API 호출 시 토큰 만료 처리
  Future<T> _handleApiCall<T>(Future<T> Function() apiCall) async {
    try {
      return await apiCall();
    } catch (e) {
      if (e is DioException) {
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data;

        print('API 호출 실패 - 상태 코드: $statusCode');
        print('API 호출 실패 - 응답 데이터: $responseData');

        // 토큰 만료 에러 처리
        if (_isTokenExpired(e)) {
          try {
            await _authService.refreshToken();
            // 갱신 성공 시 새로운 토큰으로 다시 시도
            return await apiCall();
          } catch (refreshError) {
            throw Exception('토큰이 만료되었습니다. 다시 로그인해주세요.');
          }
        }

        // 서버 에러 처리 (500, 502, 503 등)
        if (statusCode != null && statusCode >= 500) {
          String errorMessage = '서버 오류가 발생했습니다.';

          // 백엔드에서 구체적인 에러 메시지가 있는 경우
          if (responseData != null && responseData is Map) {
            final message = responseData['message'] ?? responseData['error'];
            if (message != null) {
              errorMessage = message.toString();
            }
          }

          // 500 에러의 경우 백엔드 문제임을 명시
          if (statusCode == 500) {
            errorMessage = '서버 내부 오류가 발생했습니다. 백엔드 개발팀에 문의해주세요.';
          }

          throw Exception(errorMessage);
        }

        // 기타 HTTP 에러 처리
        if (statusCode != null) {
          String errorMessage = '요청 처리 중 오류가 발생했습니다.';

          if (responseData != null && responseData is Map) {
            final message = responseData['message'] ?? responseData['error'];
            if (message != null) {
              errorMessage = message.toString();
            }
          }

          throw Exception(errorMessage);
        }
      }

      // 기타 예외 처리
      throw Exception('일정 처리 중 오류가 발생했습니다: ${e.toString()}');
    }
  }

  // 사용자의 모든 일정 조회
  Future<List<dynamic>> getAllSchedulesByUser(int userId) async {
    return await _handleApiCall(() async {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '${ApiConfig.scheduleUrl}/user/$userId',
        options: Options(headers: headers),
      );
      return response.data as List<dynamic>;
    });
  }

  // 일정 상세 조회
  Future<dynamic> getScheduleById(int scheduleId) async {
    return await _handleApiCall(() async {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '${ApiConfig.scheduleUrl}/$scheduleId',
        options: Options(headers: headers),
      );
      return response.data;
    });
  }

  // 일정 생성
  Future<dynamic> createSchedule(
    int userId,
    Map<String, dynamic> scheduleData,
  ) async {
    return await _handleApiCall(() async {
      final headers = await _getHeaders();

      // 날짜와 시간 데이터 처리
      final processedData = _processDateTimeData(scheduleData);

      final response = await _dio.post(
        '${ApiConfig.scheduleUrl}?userId=$userId',
        data: processedData,
        options: Options(headers: headers),
      );
      return response.data;
    });
  }

  // 일정 수정
  Future<dynamic> updateSchedule(
    int scheduleId,
    int userId,
    Map<String, dynamic> scheduleData,
  ) async {
    return await _handleApiCall(() async {
      final headers = await _getHeaders();

      // 날짜와 시간 데이터 처리
      final processedData = _processDateTimeData(scheduleData);

      final response = await _dio.put(
        '${ApiConfig.scheduleUrl}/$scheduleId?userId=$userId',
        data: processedData,
        options: Options(headers: headers),
      );
      return response.data;
    });
  }

  // 날짜와 시간 데이터 처리 헬퍼 메서드
  Map<String, dynamic> _processDateTimeData(Map<String, dynamic> data) {
    final processedData = Map<String, dynamic>.from(data);

    // 날짜와 시간 데이터 처리
    if (data['date'] != null && data['time'] != null) {
      DateTime date =
          data['date'] is DateTime
              ? data['date'] as DateTime
              : DateTime.parse(data['date']);

      String timeStr =
          data['time'] is TimeOfDay
              ? '${(data['time'] as TimeOfDay).hour.toString().padLeft(2, '0')}:${(data['time'] as TimeOfDay).minute.toString().padLeft(2, '0')}'
              : data['time'] as String;

      // 시간 문자열을 파싱
      final timeParts = timeStr.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      // 날짜와 시간을 합쳐서 datetime 생성
      final reminderDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        hour,
        minute,
      );

      // reminderTime에 datetime 저장 (camelCase로 변경)
      print('생성된 reminderTime: ${reminderDateTime.toIso8601String()}');
      processedData['reminderTime'] = reminderDateTime.toIso8601String();

      // 알림 활성화 설정 추가
      processedData['reminderEnabled'] = true;

      // 기존 date와 time 필드는 제거
      processedData.remove('date');
      processedData.remove('time');
    }

    // 요청 데이터 확인을 위한 로그
    print('서버로 전송할 데이터: $processedData');

    return processedData;
  }

  // 일정 삭제
  Future<void> deleteSchedule(int scheduleId, int userId) async {
    return await _handleApiCall(() async {
      final headers = await _getHeaders();
      await _dio.delete(
        '${ApiConfig.scheduleUrl}/$scheduleId?userId=$userId',
        options: Options(headers: headers),
      );
    });
  }

  // 일정 공유 상태 변경
  Future<dynamic> updateScheduleShareStatus(
    int scheduleId,
    bool isShared,
    int userId,
  ) async {
    return await _handleApiCall(() async {
      final headers = await _getHeaders();
      final response = await _dio.patch(
        '${ApiConfig.scheduleUrl}/$scheduleId/share?userId=$userId',
        data: {'isShared': isShared},
        options: Options(headers: headers),
      );
      return response.data;
    });
  }

  // 일정 알림 설정
  Future<dynamic> updateScheduleReminder(
    int scheduleId,
    bool enabled,
    String? reminderTime,
    int userId,
  ) async {
    return await _handleApiCall(() async {
      final headers = await _getHeaders();
      final response = await _dio.patch(
        '${ApiConfig.scheduleUrl}/$scheduleId/reminder?userId=$userId',
        data: {
          'enabled': enabled,
          if (reminderTime != null) 'reminderTime': reminderTime,
        },
        options: Options(headers: headers),
      );
      return response.data;
    });
  }

  // 특정 위치 주변의 일정 검색
  Future<List<dynamic>> findSchedulesNearby(
    double latitude,
    double longitude,
    double radius,
  ) async {
    return await _handleApiCall(() async {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '${ApiConfig.scheduleUrl}/nearby',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'radius': radius,
        },
        options: Options(headers: headers),
      );
      return response.data as List<dynamic>;
    });
  }
}
