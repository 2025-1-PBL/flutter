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

      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication, // 브라우저에서 열기
        );
      } else {
        throw Exception('소셜 로그인을 시작할 수 없습니다: $url');
      }
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
