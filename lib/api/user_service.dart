import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'config.dart';

class UserService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.read(key: 'token');
    if (token == null) {
      throw Exception('토큰이 없습니다.');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // 이메일로 사용자 조회
  Future<Map<String, dynamic>> getUserByEmail(String email) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '${ApiConfig.userUrl}/email/$email',
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      throw Exception('사용자 조회에 실패했습니다: $e');
    }
  }

  // ID로 사용자 조회
  Future<Map<String, dynamic>> getUserById(int userId) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '${ApiConfig.userUrl}/$userId',
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      throw Exception('사용자 조회에 실패했습니다: $e');
    }
  }

  // 사용자 정보 수정
  Future<Map<String, dynamic>> updateUser(
    int userId,
    Map<String, dynamic> userData,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.put(
        '${ApiConfig.userUrl}/$userId',
        data: userData,
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      throw Exception('사용자 정보 수정에 실패했습니다: $e');
    }
  }

  // 사용자 계정 삭제
  Future<void> deleteUser(int userId) async {
    try {
      final headers = await _getHeaders();
      await _dio.delete(
        '${ApiConfig.userUrl}/$userId',
        options: Options(headers: headers),
      );
    } catch (e) {
      throw Exception('계정 삭제에 실패했습니다: $e');
    }
  }

  // 사용자 이름으로 검색
  Future<List<dynamic>> searchUsersByName(String name) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '${ApiConfig.userUrl}/search',
        queryParameters: {'name': name},
        options: Options(headers: headers),
      );
      return response.data as List<dynamic>;
    } catch (e) {
      throw Exception('사용자 검색에 실패했습니다: $e');
    }
  }

  // 관리자 권한 부여
  Future<Map<String, dynamic>> makeAdmin(int userId) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.post(
        '${ApiConfig.userUrl}/$userId/make-admin',
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      throw Exception('관리자 권한 부여에 실패했습니다: $e');
    }
  }

  // 관리자 목록 조회
  Future<List<dynamic>> getAdminUsers() async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '${ApiConfig.userUrl}/admins',
        options: Options(headers: headers),
      );
      return response.data as List<dynamic>;
    } catch (e) {
      throw Exception('관리자 목록 조회에 실패했습니다: $e');
    }
  }
}
