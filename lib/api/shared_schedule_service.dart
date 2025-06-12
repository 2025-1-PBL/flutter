import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SharedScheduleService {
  final Dio _dio = Dio();
  final String _baseUrl = 'http://127.0.0.1:8080/api/shared-schedules';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.read(key: 'accessToken');
    if (token == null) {
      throw Exception('토큰이 없습니다.');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // 일정 공유하기
  Future<Map<String, dynamic>> shareSchedule(int scheduleId, int userId) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.post(
        '$_baseUrl/share',
        queryParameters: {
          'scheduleId': scheduleId,
          'userId': userId,
        },
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 403) {
          throw Exception('일정을 공유할 권한이 없습니다.');
        }
        if (e.response?.statusCode == 409) {
          throw Exception('이미 공유 중인 일정입니다.');
        }
        if (e.response?.statusCode == 401) {
          throw Exception('인증이 필요합니다.');
        }
      }
      throw Exception('일정 공유에 실패했습니다: $e');
    }
  }

  // 공유 일정에 멤버 추가
  Future<Map<String, dynamic>> addMemberToSharedSchedule(
    int sharedScheduleId,
    int memberUserId,
    int masterId,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.post(
        '$_baseUrl/$sharedScheduleId/members',
        queryParameters: {
          'memberUserId': memberUserId,
          'masterId': masterId,
        },
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 403) {
          throw Exception('멤버를 추가할 권한이 없습니다.');
        }
        if (e.response?.statusCode == 409) {
          throw Exception('이미 공유 일정에 추가된 멤버입니다.');
        }
        if (e.response?.statusCode == 401) {
          throw Exception('인증이 필요합니다.');
        }
      }
      throw Exception('멤버 추가에 실패했습니다: $e');
    }
  }

  // 공유 일정에서 멤버 제거
  Future<void> removeMemberFromSharedSchedule(
    int sharedScheduleId,
    int memberUserId,
    int requestUserId,
  ) async {
    try {
      final headers = await _getHeaders();
      await _dio.delete(
        '$_baseUrl/$sharedScheduleId/members/$memberUserId',
        queryParameters: {
          'requestUserId': requestUserId,
        },
        options: Options(headers: headers),
      );
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 403) {
          throw Exception('멤버를 제거할 권한이 없습니다.');
        }
        if (e.response?.statusCode == 404) {
          throw Exception('멤버를 찾을 수 없습니다.');
        }
        if (e.response?.statusCode == 401) {
          throw Exception('인증이 필요합니다.');
        }
      }
      throw Exception('멤버 제거에 실패했습니다: $e');
    }
  }

  // 공유 일정 취소
  Future<void> cancelSharedSchedule(int sharedScheduleId, int userId) async {
    try {
      final headers = await _getHeaders();
      await _dio.delete(
        '$_baseUrl/$sharedScheduleId',
        queryParameters: {
          'userId': userId,
        },
        options: Options(headers: headers),
      );
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 403) {
          throw Exception('공유 일정을 취소할 권한이 없습니다.');
        }
        if (e.response?.statusCode == 404) {
          throw Exception('공유 일정을 찾을 수 없습니다.');
        }
        if (e.response?.statusCode == 401) {
          throw Exception('인증이 필요합니다.');
        }
      }
      throw Exception('공유 일정 취소에 실패했습니다: $e');
    }
  }

  // 사용자에게 공유된 모든 일정 조회
  Future<List<dynamic>> getSharedSchedulesForUser(int userId) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '$_baseUrl/shared-with-me',
        queryParameters: {
          'userId': userId,
        },
        options: Options(headers: headers),
      );
      return response.data as List<dynamic>;
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          throw Exception('인증이 필요합니다.');
        }
      }
      throw Exception('공유된 일정 목록을 불러오는데 실패했습니다: $e');
    }
  }

  // 사용자가 소유한 모든 공유 일정 조회
  Future<List<dynamic>> getOwnedSharedSchedules(int userId) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '$_baseUrl/owned',
        queryParameters: {
          'userId': userId,
        },
        options: Options(headers: headers),
      );
      return response.data as List<dynamic>;
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          throw Exception('인증이 필요합니다.');
        }
      }
      throw Exception('소유한 공유 일정 목록을 불러오는데 실패했습니다: $e');
    }
  }

  // 특정 공유 일정의 모든 멤버 조회
  Future<List<dynamic>> getMembersOfSharedSchedule(int sharedScheduleId) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '$_baseUrl/$sharedScheduleId/members',
        options: Options(headers: headers),
      );
      return response.data as List<dynamic>;
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          throw Exception('인증이 필요합니다.');
        }
        if (e.response?.statusCode == 404) {
          throw Exception('공유 일정을 찾을 수 없습니다.');
        }
      }
      throw Exception('멤버 목록을 불러오는데 실패했습니다: $e');
    }
  }
}
