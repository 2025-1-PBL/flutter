import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final Dio _dio = Dio();
  final String _baseUrl = 'http://127.0.0.1:8080/api';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // 로그인 (인증)
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/authenticate',
        data: {
          'email': email,
          'password': password,
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      // 토큰 저장
      final tokenData = response.data as Map<String, dynamic>;
      await _storage.write(key: 'accessToken', value: tokenData['token']);
      await _storage.write(key: 'refreshToken', value: tokenData['refreshToken']);
      
      debugPrint("▶︎ [AuthService] 로그인 성공: ${response.data}");
      return tokenData;
    } catch (e) {
      debugPrint("▶︎ [AuthService] 로그인 실패: $e");
      throw Exception('로그인에 실패했습니다: $e');
    }
  }

  // 회원가입
  Future<Map<String, dynamic>> signup(Map<String, dynamic> userData) async {
    try {
      // 필수 필드 검증
      if (!userData.containsKey('email') || !userData.containsKey('password') || !userData.containsKey('name')) {
        throw Exception('이메일, 비밀번호, 이름은 필수 입력 항목입니다.');
      }

      final response = await _dio.post(
        '$_baseUrl/signup',
        data: userData,
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );
      
      debugPrint("▶︎ [AuthService] 회원가입 성공: ${response.data}");
      return response.data;
    } catch (e) {
      debugPrint("▶︎ [AuthService] 회원가입 실패: $e");
      throw Exception('회원가입에 실패했습니다: $e');
    }
  }

  // 토큰 갱신
  Future<Map<String, dynamic>> refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: 'refreshToken');
      
      if (refreshToken == null) {
        throw Exception('리프레시 토큰이 없습니다. 다시 로그인해주세요.');
      }

      final response = await _dio.post(
        '$_baseUrl/refresh',
        data: {'refreshToken': refreshToken},
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      // 새 토큰 저장
      final tokenData = response.data as Map<String, dynamic>;
      await _storage.write(key: 'accessToken', value: tokenData['token']);
      await _storage.write(key: 'refreshToken', value: tokenData['refreshToken']);
      
      debugPrint("▶︎ [AuthService] 토큰 갱신 성공: ${response.data}");
      return tokenData;
    } catch (e) {
      debugPrint("▶︎ [AuthService] 토큰 갱신 실패: $e");
      throw Exception('토큰 갱신에 실패했습니다: $e');
    }
  }

  // 로그아웃 (클라이언트 측에서 토큰 삭제)
  Future<void> logout() async {
    try {
      await _storage.delete(key: 'accessToken');
      await _storage.delete(key: 'refreshToken');
      debugPrint("▶︎ [AuthService] 로그아웃 성공");
    } catch (e) {
      debugPrint("▶︎ [AuthService] 로그아웃 중 오류 발생: $e");
      throw Exception('로그아웃 중 오류가 발생했습니다: $e');
    }
  }

  // 토큰 유효성 확인
  Future<bool> isTokenValid() async {
    try {
      final token = await _storage.read(key: 'accessToken');
      if (token == null) {
        return false;
      }

      // 현재 사용자 정보 요청으로 토큰 유효성 검증
      await _dio.get(
        '$_baseUrl/oauth/current-user',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );
      
      return true;
    } catch (e) {
      debugPrint("▶︎ [AuthService] 토큰이 유효하지 않음: $e");
      return false;
    }
  }

  // FCM 토큰 업데이트
  Future<void> updateFcmToken(String fcmToken) async {
    try {
      final token = await _storage.read(key: 'accessToken');
      if (token == null) {
        throw Exception('인증 토큰이 없습니다.');
      }

      await _dio.post(
        '$_baseUrl/user/fcm-token',
        data: {'fcmToken': fcmToken},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );
      
      debugPrint("▶︎ [AuthService] FCM 토큰 업데이트 성공");
    } catch (e) {
      debugPrint("▶︎ [AuthService] FCM 토큰 업데이트 실패: $e");
      throw Exception('FCM 토큰 업데이트에 실패했습니다: $e');
    }
  }

  // 사용자 프로필 업데이트
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final token = await _storage.read(key: 'accessToken');
      if (token == null) {
        throw Exception('인증 토큰이 없습니다.');
      }

      final response = await _dio.put(
        '$_baseUrl/user/profile',
        data: profileData,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );
      
      debugPrint("▶︎ [AuthService] 프로필 업데이트 성공: ${response.data}");
      return response.data;
    } catch (e) {
      debugPrint("▶︎ [AuthService] 프로필 업데이트 실패: $e");
      throw Exception('프로필 업데이트에 실패했습니다: $e');
    }
  }
}