import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserService {
  final Dio _dio = Dio();
  final String _baseUrl = 'http://127.0.0.1:8080/api/users';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // 이메일로 사용자 조회
  Future<Map<String, dynamic>> getUserByEmail(String email) async {
    try {
      final token = await _storage.read(key: 'accessToken');
      if (token == null) {
        throw Exception('토큰이 없습니다.');
      }

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await _dio.get(
        '$_baseUrl/email/$email',
        options: Options(headers: headers),
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('사용자 조회에 실패했습니다: $e');
    }
  }

  // ID로 사용자 조회
  Future<Map<String, dynamic>> getUserById(int userId) async {
    try {
      final token = await _storage.read(key: 'accessToken');
      if (token == null) {
        throw Exception('토큰이 없습니다.');
      }

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await _dio.get(
        '$_baseUrl/$userId',
        options: Options(headers: headers),
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('사용자 조회에 실패했습니다: $e');
    }
  }

  // 사용자 정보 수정
  Future<Map<String, dynamic>> updateUser(int userId, Map<String, dynamic> userData) async {
    try {
      final token = await _storage.read(key: 'accessToken');
      if (token == null) {
        throw Exception('토큰이 없습니다.');
      }

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await _dio.put(
        '$_baseUrl/$userId',
        data: userData,
        options: Options(headers: headers),
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('사용자 정보 수정에 실패했습니다: $e');
    }
  }

  // 사용자 계정 삭제
  Future<void> deleteUser(int userId) async {
    try {
      final token = await _storage.read(key: 'accessToken');
      if (token == null) {
        throw Exception('토큰이 없습니다.');
      }

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      await _dio.delete(
        '$_baseUrl/$userId',
        options: Options(headers: headers),
      );
    } catch (e) {
      throw Exception('계정 삭제에 실패했습니다: $e');
    }
  }

  // 사용자 이름으로 검색
  Future<List<dynamic>> searchUsersByName(String name) async {
    try {
      final token = await _storage.read(key: 'accessToken');
      if (token == null) {
        throw Exception('토큰이 없습니다.');
      }

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await _dio.get(
        '$_baseUrl/search',
        queryParameters: {'name': name},
        options: Options(headers: headers),
      );
      return response.data as List<dynamic>;
    } catch (e) {
      throw Exception('사용자 검색에 실패했습니다: $e');
    }
  }
}