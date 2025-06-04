import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserService {
  final Dio _dio = Dio();
  final String _baseUrl = 'http://127.0.0.1:8080/api/oauth';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();


  // 현재 로그인한 사용자 정보 조회 (Endpoint: GET /api/oauth/current-user)
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      // 1) SecureStorage에서 토큰 읽기
      final token = await _storage.read(key: 'accessToken');
      if (token == null) {
        throw Exception('토큰이 없습니다.');
      }

      // 2) 헤더에 토큰 설정
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
      debugPrint("▶︎ [UserService] GET $_baseUrl/current-user 호출, 헤더: $headers");

      // 3) 요청
      final response = await _dio.get(
        '$_baseUrl/current-user',
        options: Options(headers: headers),
      );

      return response.data as Map<String, dynamic>;
    } catch (e) {
      debugPrint("▶︎ [UserService] 예외 발생: $e");
      throw Exception('사용자 정보를 불러오는데 실패했습니다: $e');
    }
  }
}