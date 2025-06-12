import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final Dio _dio = Dio();
  final String _baseUrl = 'http://127.0.0.1:8080/api';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // 로그인
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/authenticate',
        data: {
          'username': username,
          'password': password,
        },
      );

      // 토큰 저장
      final accessToken = response.data['accessToken'];
      final refreshToken = response.data['refreshToken'];
      await _storage.write(key: 'accessToken', value: accessToken);
      await _storage.write(key: 'refreshToken', value: refreshToken);

      return response.data;
    } catch (e) {
      throw Exception('로그인에 실패했습니다: $e');
    }
  }

  // 회원가입
  Future<Map<String, dynamic>> signup(Map<String, dynamic> userData) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/signup',
        data: userData,
      );
      return response.data;
    } catch (e) {
      throw Exception('회원가입에 실패했습니다: $e');
    }
  }

  // 토큰 갱신
  Future<Map<String, dynamic>> refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: 'refreshToken');
      if (refreshToken == null) {
        throw Exception('리프레시 토큰이 없습니다.');
      }

      final response = await _dio.post(
        '$_baseUrl/refresh',
        data: {
          'refreshToken': refreshToken,
        },
      );

      // 새로운 토큰 저장
      final accessToken = response.data['accessToken'];
      await _storage.write(key: 'accessToken', value: accessToken);

      return response.data;
    } catch (e) {
      throw Exception('토큰 갱신에 실패했습니다: $e');
    }
  }

  // 현재 로그인한 사용자 정보 조회
  Future<Map<String, dynamic>> getCurrentUser() async {
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
        '$_baseUrl/oauth/current-user',
        options: Options(headers: headers),
      );

      return response.data;
    } catch (e) {
      throw Exception('사용자 정보를 불러오는데 실패했습니다: $e');
    }
  }

  // 로그아웃
  Future<void> logout() async {
    await _storage.delete(key: 'accessToken');
    await _storage.delete(key: 'refreshToken');
  }
}
