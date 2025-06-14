import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io';
import 'config.dart';

class SocialLoginService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  /// 소셜 로그인 시작
  static Future<void> startSocialLogin(String provider) async {
    try {
      final baseUrl =
          Platform.isAndroid
              ? ApiConfig.socialLoginAndroidUrl
              : ApiConfig.socialLoginBaseUrl;
      final url = '$baseUrl/oauth2/authorization/$provider';

      print('소셜 로그인 시작: $url');

      final uri = Uri.parse(url);

      // URL이 유효한지 확인
      if (!uri.hasScheme || !uri.hasAuthority) {
        throw Exception('유효하지 않은 URL입니다: $url');
      }

      // canLaunchUrl 체크를 건너뛰고 직접 실행 시도
      bool launched = false;

      // 먼저 외부 브라우저에서 실행 시도
      try {
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e) {
        print('외부 브라우저 실행 실패: $e');
      }

      // 외부 브라우저가 실패하면 인앱 브라우저로 시도
      if (!launched) {
        try {
          launched = await launchUrl(uri, mode: LaunchMode.inAppWebView);
        } catch (e) {
          print('인앱 브라우저 실행 실패: $e');
        }
      }

      // 모든 방법이 실패하면 기본 모드로 시도
      if (!launched) {
        launched = await launchUrl(uri);
      }

      if (!launched) {
        throw Exception('소셜 로그인을 시작할 수 없습니다: $url');
      }

      print('소셜 로그인 URL 실행 성공');
    } catch (e) {
      print('소셜 로그인 오류: $e');
      rethrow;
    }
  }

  /// Google 로그인
  static Future<void> googleLogin() async {
    await startSocialLogin('google');
  }

  /// Kakao 로그인
  static Future<void> kakaoLogin() async {
    await startSocialLogin('kakao');
  }

  /// Naver 로그인
  static Future<void> naverLogin() async {
    await startSocialLogin('naver');
  }

  /// OAuth2 콜백에서 토큰 저장
  static Future<void> saveTokensFromCallback(
    String token,
    String refreshToken,
  ) async {
    try {
      await _storage.write(key: 'token', value: token);
      await _storage.write(key: 'refreshToken', value: refreshToken);
      print('토큰 저장 완료');
    } catch (e) {
      print('토큰 저장 실패: $e');
      rethrow;
    }
  }

  /// 저장된 토큰 확인
  static Future<Map<String, String?>> getStoredTokens() async {
    try {
      final token = await _storage.read(key: 'token');
      final refreshToken = await _storage.read(key: 'refreshToken');
      return {'token': token, 'refreshToken': refreshToken};
    } catch (e) {
      print('토큰 읽기 실패: $e');
      return {'token': null, 'refreshToken': null};
    }
  }
}
