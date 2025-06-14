import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'config.dart';

class AuthService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // 로그인
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _dio.post(
        '${ApiConfig.authUrl}/authenticate',
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

  // 회원가입
  Future<Map<String, dynamic>> signup(Map<String, dynamic> userData) async {
    try {
      final response = await _dio.post(
        '${ApiConfig.authUrl}/signup',
        data: userData,
      );
      return response.data;
    } catch (e) {
      throw Exception('회원가입에 실패했습니다: $e');
    }
  }

  // 이메일 중복확인
  Future<Map<String, dynamic>> checkEmailDuplicate(String email) async {
    try {
      // 이메일을 URL 인코딩
      final encodedEmail = Uri.encodeComponent(email);
      final response = await _dio.get(
        '${ApiConfig.authUrl}/check-email/$encodedEmail',
      );
      return response.data;
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 404) {
          // 404 오류 시 - 엔드포인트가 없거나 서버 문제
          throw Exception('서버 연결에 실패했습니다. 잠시 후 다시 시도해주세요.');
        } else if (e.response?.statusCode == 409) {
          // 이미 존재하는 이메일
          return {'available': false, 'message': '이미 사용 중인 이메일입니다.'};
        } else if (e.response?.statusCode == 500) {
          // 서버 내부 오류
          throw Exception('서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.');
        }
      }
      throw Exception('이메일 중복확인에 실패했습니다: $e');
    }
  }

  // 토큰 갱신
  Future<Map<String, dynamic>> refreshToken() async {
    try {
      final token = await _storage.read(key: 'token');
      final storedRefreshToken = await _storage.read(key: 'refreshToken');

      print('토큰 갱신 시작 - 현재 토큰: ${token?.substring(0, 20)}...');
      print(
        '토큰 갱신 시작 - refreshToken: ${storedRefreshToken?.substring(0, 20)}...',
      );

      if (storedRefreshToken == null) {
        throw Exception('리프레시 토큰이 없습니다.');
      }

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final response = await _dio.post(
        '${ApiConfig.authUrl}/refresh',
        data: {'refreshToken': storedRefreshToken},
        options: Options(headers: headers),
      );

      print('토큰 갱신 응답: ${response.statusCode}');
      print('토큰 갱신 응답 데이터: ${response.data}');

      // 새로운 토큰 저장
      final newToken = response.data['token'];
      print('새로운 토큰: ${newToken?.substring(0, 20)}...');

      await _storage.write(key: 'token', value: newToken);
      print('토큰 저장 완료');

      // 저장 완료를 기다림
      await Future.delayed(const Duration(milliseconds: 100));

      // 저장된 토큰 확인
      final savedToken = await _storage.read(key: 'token');
      print('저장된 토큰 확인: ${savedToken?.substring(0, 20)}...');

      return response.data;
    } catch (e) {
      print('토큰 갱신 실패: $e');
      // 토큰 갱신 실패 시 저장된 토큰 삭제
      await logout();
      throw Exception('토큰 갱신에 실패했습니다: $e');
    }
  }

  // 토큰 만료 여부 확인
  bool _isTokenExpired(DioException e) {
    return e.response?.statusCode == 401 ||
        e.response?.statusCode == 403 ||
        e.message?.contains('만료된 JWT 토큰') == true ||
        e.message?.contains('유효한 JWT 토큰이 없습니다') == true;
  }

  // 토큰이 만료되었는지 확인하고 필요시 갱신
  Future<bool> _handleTokenExpiration() async {
    try {
      await refreshToken();
      return true;
    } catch (e) {
      print('토큰 갱신 실패: $e');
      return false;
    }
  }

  // 현재 로그인한 사용자 정보 조회 (토큰 만료 시 자동 갱신)
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final token = await _storage.read(key: 'token');
      print('getCurrentUser - 저장된 토큰: ${token?.substring(0, 20)}...');

      if (token == null) {
        print('getCurrentUser - 토큰이 null입니다');
        throw Exception('토큰이 없습니다.');
      }

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      print('getCurrentUser - OAuth API 호출 시작');
      // 먼저 OAuth 컨트롤러 시도
      try {
        final response = await _dio.get(
          '${ApiConfig.authUrl}/oauth/current-user',
          options: Options(headers: headers),
        );
        print('getCurrentUser - OAuth API 성공');
        return response.data;
      } catch (e) {
        print('getCurrentUser - OAuth API 실패: $e');

        // 백엔드 문제 우회: 토큰 갱신을 시도하지 않고 바로 User API로 fallback
        print('getCurrentUser - 백엔드 문제 우회: User API로 바로 fallback');
        try {
          final response = await _dio.get(
            '${ApiConfig.authUrl}/users/current-user',
            options: Options(headers: headers),
          );
          print('getCurrentUser - User API 성공');
          return response.data;
        } catch (e2) {
          print('getCurrentUser - User API도 실패: $e2');
          throw Exception('사용자 정보를 불러오는 데 실패했습니다: $e2');
        }
      }
    } catch (e) {
      print('getCurrentUser - 최종 오류: $e');
      throw Exception('사용자 정보를 불러오는 데 실패했습니다: $e');
    }
  }

  // 로그아웃
  Future<void> logout() async {
    await _storage.delete(key: 'token');
    await _storage.delete(key: 'refreshToken');
  }

  // 토큰 유효성 검사 (토큰 만료 시 자동 갱신)
  Future<bool> isTokenValid() async {
    try {
      final token = await _storage.read(key: 'token');
      if (token == null) return false;

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      try {
        await _dio.get(
          '${ApiConfig.authUrl}/oauth/current-user',
          options: Options(headers: headers),
        );
        return true;
      } catch (e) {
        if (e is DioException && _isTokenExpired(e)) {
          // 토큰 만료 시 갱신 시도
          return await _handleTokenExpiration();
        }
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // 저장된 토큰 가져오기
  Future<String?> getStoredToken() async {
    return await _storage.read(key: 'token');
  }

  // 저장된 리프레시 토큰 가져오기
  Future<String?> getStoredRefreshToken() async {
    return await _storage.read(key: 'refreshToken');
  }

  // 로그인 상태 확인
  Future<bool> isLoggedIn() async {
    try {
      final token = await _storage.read(key: 'token');
      final refreshToken = await _storage.read(key: 'refreshToken');

      print('isLoggedIn - 토큰: ${token?.substring(0, 20)}...');
      print('isLoggedIn - refreshToken: ${refreshToken?.substring(0, 20)}...');

      // 토큰이 없으면 로그인되지 않은 상태
      if (token == null || refreshToken == null) {
        print('isLoggedIn - 토큰이 없어서 로그인되지 않은 상태');
        return false;
      }

      // 토큰 유효성 검사
      final isValid = await isTokenValid();
      print('isLoggedIn - 토큰 유효성: $isValid');

      return isValid;
    } catch (e) {
      print('isLoggedIn - 오류: $e');
      return false;
    }
  }

  // 저장된 모든 토큰 정보 출력 (디버깅용)
  Future<void> printStoredTokens() async {
    try {
      final token = await _storage.read(key: 'token');
      final refreshToken = await _storage.read(key: 'refreshToken');

      print('=== 저장된 토큰 정보 ===');
      print('토큰: ${token ?? 'null'}');
      print('refreshToken: ${refreshToken ?? 'null'}');
      print('=======================');
    } catch (e) {
      print('토큰 정보 출력 오류: $e');
    }
  }

  // 토큰 만료 시 로그인 필요 여부 확인
  Future<bool> needsReLogin() async {
    try {
      await printStoredTokens(); // 디버깅용

      final token = await _storage.read(key: 'token');
      final storedRefreshToken = await _storage.read(key: 'refreshToken');

      if (token == null || storedRefreshToken == null) {
        print('needsReLogin - 토큰이 없어서 재로그인 필요');
        return true;
      }

      // 토큰 유효성 검사 시도
      final isValid = await isTokenValid();
      if (!isValid) {
        // 토큰 갱신 시도
        try {
          await refreshToken();
          return false;
        } catch (e) {
          print('needsReLogin - 토큰 갱신 실패: $e');
          return true; // 갱신 실패 시 재로그인 필요
        }
      }

      return false;
    } catch (e) {
      print('needsReLogin - 오류: $e');
      return true;
    }
  }
}
