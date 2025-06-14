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
        data: {'username': username, 'password': password},
      );

      final token = response.data['token'];
      final refreshToken = response.data['refreshToken'];

      await _storage.write(key: 'token', value: token);
      await _storage.write(key: 'refreshToken', value: refreshToken);

      return response.data;
    } catch (e) {
      throw Exception('로그인에 실패했습니다: $e');
    }
  }

  //eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJzaXM5NzcyQG5hdmVyLmNvbSIsImF1dGgiOiJST0xFX1VTRVIiLCJleHAiOjE3NDk4MjIyNDV9.2HnuEnLT2yALt7IGs_AWDKIb-YAFw1xRTV-NlVehpURkutJ2Zo1fgYCmkMYHW5KQJYrdxzeAxSkLSB3Ar0w8rA
  //eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJzaXM5NzcyQG5hdmVyLmNvbSIsImF1dGgiOiJST0xFX1VTRVIiLCJleHAiOjE3NDk4MjIyNDV9.2HnuEnLT2yALt7IGs_AWDKIb-YAFw1xRTV-NlVehpURkutJ2Zo1fgYCmkMYHW5KQJYrdxzeAxSkLSB3Ar0w8rA

  // 회원가입
  Future<Map<String, dynamic>> signup(Map<String, dynamic> userData) async {
    try {
      final response = await _dio.post('$_baseUrl/signup', data: userData);
      return response.data;
    } catch (e) {
      throw Exception('회원가입에 실패했습니다: $e');
    }
  }

  // 토큰 갱신
  Future<Map<String, dynamic>> refreshToken() async {
    try {
      final token = await _storage.read(key: 'token');
      final refreshToken = await _storage.read(key: 'refreshToken');

      print(token);
      print(refreshToken);


      if (refreshToken == null) {
        throw Exception('리프레시 토큰이 없습니다.');
      }

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final response = await _dio.post(
        '$_baseUrl/refresh',
        data: {'refreshToken': refreshToken},
        options: Options(headers: headers),
      );

      // 새로운 토큰 저장
      final newToken = response.data['token'];
      await _storage.write(key: 'token', value: newToken);

      return response.data;
    } catch (e) {
      throw Exception('토큰 갱신에 실패했습니다: $e');
    }
  }

  // 현재 로그인한 사용자 정보 조회
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final token = await _storage.read(key: 'token');


      if (token == null) {
        throw Exception('토큰이 없습니다.');
      }
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await _dio.get(
        '$_baseUrl/users/current-user',
        options: Options(headers: headers),
      );

      return response.data;
    } catch (e) {
      print(e);
      throw Exception('2용자 정보를 불러오는 데 실패했습니다: $e');
    }
  }

  // 로그아웃
  Future<void> logout() async {
    await _storage.delete(key: 'token');
    await _storage.delete(key: 'refreshToken');
  }
}



