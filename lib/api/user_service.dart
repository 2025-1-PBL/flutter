import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http_parser/http_parser.dart';
import 'config.dart';
import 'dart:io';
import 'dart:convert';
import 'auth_service.dart';

class UserService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final AuthService _authService = AuthService();

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

  // 프로필 이미지 업로드 (임시 해결책)
  Future<Map<String, dynamic>> uploadProfileImage(String imagePath) async {
    try {
      final token = await _storage.read(key: 'token');
      if (token == null) {
        throw Exception('토큰이 없습니다.');
      }

      // 현재 사용자 정보 가져오기
      final currentUser = await _authService.getCurrentUser();
      final userId = currentUser['id'];

      // 이미지 파일 확인
      final file = File(imagePath);
      if (!await file.exists()) {
        throw Exception('이미지 파일을 찾을 수 없습니다.');
      }

      // 이미지 크기 확인 (100KB 제한으로 매우 엄격하게)
      final fileSize = await file.length();
      if (fileSize > 100 * 1024) {
        throw Exception('이미지 크기가 100KB를 초과합니다. 더 작은 이미지를 선택해주세요.');
      }

      // 이미지를 base64로 인코딩
      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes);

      // base64 문자열 길이 확인 (약 150KB 제한)
      if (base64Image.length > 150 * 1024) {
        throw Exception('이미지가 너무 큽니다. 더 작은 이미지를 선택해주세요.');
      }

      // 사용자 정보 업데이트
      final response = await updateUser(userId, {
        'profilePic': 'data:image/png;base64,$base64Image',
      });

      return {'success': true, 'data': response};
    } catch (e) {
      throw Exception('프로필 이미지 업로드에 실패했습니다: $e');
    }
  }
}
