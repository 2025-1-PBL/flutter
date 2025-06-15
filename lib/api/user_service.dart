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
      print('사용자 정보 수정 요청 - userId: $userId, data: ${userData.keys}');

      final response = await _dio.put(
        '${ApiConfig.userUrl}/$userId',
        data: userData,
        options: Options(headers: headers),
      );

      print('사용자 정보 수정 성공: ${response.statusCode}');
      return response.data;
    } catch (e) {
      print('사용자 정보 수정 실패: $e');
      if (e is DioException) {
        print('Dio 에러 상세: ${e.response?.statusCode} - ${e.response?.data}');
      }
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

  // 프로필 이미지 업로드 (개선된 버전)
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

      // 이미지 크기 확인 (5MB 제한으로 완화)
      final fileSize = await file.length();
      if (fileSize > 5 * 1024 * 1024) {
        // 5MB
        throw Exception('이미지 크기가 5MB를 초과합니다. 더 작은 이미지를 선택해주세요.');
      }

      print('이미지 업로드 시작 - 파일 크기: ${fileSize} bytes');

      // FormData로 이미지 업로드 (더 효율적)
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imagePath,
          filename:
              'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      });

      final headers = await _getHeaders();
      headers['Content-Type'] = 'multipart/form-data';

      // 이미지 업로드 전용 엔드포인트 사용
      final response = await _dio.post(
        '${ApiConfig.userUrl}/$userId/profile-image',
        data: formData,
        options: Options(headers: headers),
      );

      print('프로필 이미지 업로드 성공: ${response.data}');
      return {'success': true, 'data': response.data};
    } catch (e) {
      print('프로필 이미지 업로드 실패: $e');
      if (e is DioException) {
        print('Dio 에러 상세: ${e.response?.statusCode} - ${e.response?.data}');

        // 404 에러인 경우 기존 방식으로 fallback
        if (e.response?.statusCode == 404) {
          print('이미지 업로드 엔드포인트가 없습니다. 기존 방식으로 시도합니다.');
          return await uploadProfileImageFallback(imagePath);
        }
      }
      throw Exception('프로필 이미지 업로드에 실패했습니다: $e');
    }
  }

  // 기존 Base64 방식 (fallback)
  Future<Map<String, dynamic>> uploadProfileImageFallback(
    String imagePath,
  ) async {
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

      // 이미지 크기 확인 (2MB 제한)
      final fileSize = await file.length();
      if (fileSize > 2 * 1024 * 1024) {
        // 2MB
        throw Exception('이미지 크기가 2MB를 초과합니다. 더 작은 이미지를 선택해주세요.');
      }

      // 이미지를 base64로 인코딩
      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes);

      print('Base64 방식으로 이미지 업로드 시작 - 파일 크기: ${fileSize} bytes');

      // 사용자 정보 업데이트
      final response = await updateUser(userId, {
        'profilePic': 'data:image/png;base64,$base64Image',
      });

      print('프로필 이미지 업로드 성공 (Base64 방식)');
      return {'success': true, 'data': response};
    } catch (e) {
      print('프로필 이미지 업로드 실패 (Base64 방식): $e');
      throw Exception('프로필 이미지 업로드에 실패했습니다: $e');
    }
  }
}
