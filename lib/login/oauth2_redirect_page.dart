import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import '../api/social_login_service.dart';
import '../home/home_screen.dart';
import 'start.dart';

class OAuth2RedirectPage extends StatefulWidget {
  const OAuth2RedirectPage({super.key});

  @override
  State<OAuth2RedirectPage> createState() => _OAuth2RedirectPageState();
}

class _OAuth2RedirectPageState extends State<OAuth2RedirectPage> {
  bool _isProcessing = true;
  String _statusMessage = '로그인 처리 중...';

  @override
  void initState() {
    super.initState();
    _handleOAuth2Callback();
  }

  Future<void> _handleOAuth2Callback() async {
    try {
      // 딥링크로 전달된 URL 파라미터 처리
      final appLinks = AppLinks();
      final initialLink = await appLinks.getInitialAppLink();
      if (initialLink != null) {
        await _processCallback(initialLink.toString());
      } else {
        // URL 파라미터가 없는 경우 (직접 접근)
        _handleNoCallback();
      }
    } catch (e) {
      print('OAuth2 콜백 처리 오류: $e');
      _handleError('로그인 처리 중 오류가 발생했습니다.');
    }
  }

  Future<void> _processCallback(String callbackUrl) async {
    try {
      print('OAuth2 콜백 URL: $callbackUrl');

      final uri = Uri.parse(callbackUrl);
      print('파싱된 URI: $uri');
      print('URI 스킴: ${uri.scheme}');
      print('URI 호스트: ${uri.host}');
      print('URI 경로: ${uri.path}');
      print('URI 쿼리 파라미터: ${uri.queryParameters}');

      final token = uri.queryParameters['token'];
      final refreshToken = uri.queryParameters['refreshToken'];
      final error = uri.queryParameters['error'];
      final errorDescription = uri.queryParameters['error_description'];

      // 에러가 있는 경우 처리
      if (error != null) {
        print('OAuth2 에러: $error - $errorDescription');
        _handleError('로그인 실패: ${errorDescription ?? error}');
        return;
      }

      if (token != null && refreshToken != null) {
        setState(() {
          _statusMessage = '토큰 저장 중...';
        });

        // 토큰 저장
        await SocialLoginService.saveTokensFromCallback(token, refreshToken);

        setState(() {
          _statusMessage = '로그인 성공!';
          _isProcessing = false;
        });

        // 잠시 후 홈 화면으로 이동
        await Future.delayed(const Duration(seconds: 1));

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      } else {
        print('토큰이 없음 - token: $token, refreshToken: $refreshToken');
        _handleError('토큰을 받지 못했습니다.');
      }
    } catch (e) {
      print('콜백 처리 오류: $e');
      _handleError('로그인 처리 중 오류가 발생했습니다.');
    }
  }

  void _handleNoCallback() {
    setState(() {
      _statusMessage = '올바르지 않은 접근입니다.';
      _isProcessing = false;
    });

    // 3초 후 로그인 화면으로 이동
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    });
  }

  void _handleError(String message) {
    setState(() {
      _statusMessage = message;
      _isProcessing = false;
    });

    // 3초 후 로그인 화면으로 이동
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 로고
            Container(
              height: 120,
              alignment: Alignment.center,
              child: Image.asset('assets/logo.png', fit: BoxFit.contain),
            ),

            const SizedBox(height: 40),

            // 로딩 인디케이터 또는 완료 아이콘
            _isProcessing
                ? const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFA724)),
                )
                : const Icon(
                  Icons.check_circle,
                  color: Color(0xFF4CAF50),
                  size: 60,
                ),

            const SizedBox(height: 20),

            // 상태 메시지
            Text(
              _statusMessage,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),

            if (!_isProcessing) ...[
              const SizedBox(height: 10),
              const Text(
                '잠시 후 자동으로 이동합니다.',
                style: TextStyle(fontSize: 14, color: Color(0xFF767676)),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
