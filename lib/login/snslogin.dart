import 'package:flutter/material.dart';
import 'dart:io';
import 'join1.dart';
import '../api/social_login_service.dart';
import '../api/auth_service.dart';
import '../home/home_screen.dart';
import 'package:app_links/app_links.dart';

class SnsLoginScreen extends StatefulWidget {
  const SnsLoginScreen({super.key});

  @override
  State<SnsLoginScreen> createState() => _SnsLoginScreenState();
}

class _SnsLoginScreenState extends State<SnsLoginScreen> {
  bool _isLoading = false;
  String? _loadingProvider;
  final AppLinks _appLinks = AppLinks();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  void _initDeepLinks() {
    _appLinks.uriLinkStream.listen(
          (Uri uri) {
        _handleDeepLink(uri);
      },
      onError: (err) {
        print('딥링크 스트림 오류: $err');
      },
    );
  }

  void _handleDeepLink(Uri uri) {
    print('SnsLoginScreen - 딥링크 수신: $uri');
    if (uri.scheme == 'mapmo' &&
        uri.host == 'oauth2' &&
        uri.path == '/redirect') {
      final token = uri.queryParameters['token'];
      final refreshToken = uri.queryParameters['refreshToken'];

      if (token != null && refreshToken != null) {
        print('SnsLoginScreen - 토큰 수신: $token');
        _handleOAuth2Success(token, refreshToken);
      }
    }
  }

  Future<void> _handleOAuth2Success(String token, String refreshToken) async {
    try {
      await SocialLoginService.saveTokensFromCallback(token, refreshToken);
      final isLoggedIn = await _authService.isLoggedIn();

      if (isLoggedIn) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _loadingProvider = null;
          });

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) => false,
          );
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _loadingProvider = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('로그인에 실패했습니다. 다시 시도해주세요.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      print('SnsLoginScreen - 토큰 저장 실패: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingProvider = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('로그인 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const labelColor = Color(0xFF767676);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 220,
                    alignment: Alignment.center,
                    child: Image.asset('assets/logo.png', fit: BoxFit.contain),
                  ),
                  const Text(
                    '지금 Map-Mo와\n하루를 함께 하세요!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    '다양한 소식을 빠르게 확인해보세요',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: labelColor),
                  ),
                  const SizedBox(height: 20),

                  _snsButton(
                    color: const Color(0xFFFEE500),
                    text: '카카오 로그인',
                    textColor: Colors.black,
                    imagePath: 'assets/kakao.png',
                    isLoading: _isLoading && _loadingProvider == 'kakao',
                    onPressed: _isLoading ? null : () => _handleSocialLogin('kakao'),
                  ),
                  const SizedBox(height: 10),

                  _snsButton(
                    color: Colors.white,
                    text: 'Google 로그인',
                    textColor: Colors.black87,
                    imagePath: 'assets/google.png',
                    border: Border.all(color: Colors.grey.shade300),
                    isLoading: _isLoading && _loadingProvider == 'google',
                    onPressed: _isLoading ? null : () => _handleSocialLogin('google'),
                  ),
                  const SizedBox(height: 10),

                  _snsButton(
                    color: const Color(0xFF03C75A),
                    text: '네이버 로그인',
                    textColor: Colors.white,
                    imagePath: 'assets/naver.png',
                    isLoading: _isLoading && _loadingProvider == 'naver',
                    onPressed: _isLoading ? null : () => _handleSocialLogin('naver'),
                  ),
                  const SizedBox(height: 16),

                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    child: const Text(
                      '다른 방법으로 로그인',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFFFFA724),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: GestureDetector(
                  onTap: _isLoading
                      ? null
                      : () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const JoinScreen(),
                    ),
                  ),
                  child: RichText(
                    text: const TextSpan(
                      text: '아직 맵모 회원이 아니신가요? ',
                      style: TextStyle(color: labelColor),
                      children: [
                        TextSpan(
                          text: '회원가입',
                          style: TextStyle(
                            color: labelColor,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSocialLogin(String provider) async {
    setState(() {
      _isLoading = true;
      _loadingProvider = provider;
    });

    try {
      switch (provider) {
        case 'kakao':
          await SocialLoginService.kakaoLogin();
          break;
        case 'google':
          await SocialLoginService.googleLogin();
          break;
        case 'naver':
          await SocialLoginService.naverLogin();
          break;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${provider.toUpperCase()} 로그인을 시작합니다. 브라우저를 확인해주세요.'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${provider.toUpperCase()} 로그인 실패: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingProvider = null;
        });
      }
    }
  }

  Widget _snsButton({
    required Color color,
    required String text,
    required Color textColor,
    required String imagePath,
    required VoidCallback? onPressed,
    Border? border,
    bool isLoading = false,
  }) {
    final isNaver = imagePath.contains('naver');
    final isKakao = imagePath.contains('kakao');

    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: border?.top ?? BorderSide.none,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(left: (isKakao || isNaver) ? 0 : 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              isLoading
                  ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(textColor),
                ),
              )
                  : Image.asset(
                imagePath,
                width: isNaver ? 30 : 23,
                height: isNaver ? 30 : 34,
              ),
              const SizedBox(width: 12),
              Text(
                isLoading ? '로그인 중...' : text,
                style: TextStyle(color: textColor, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}