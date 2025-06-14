import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // provider 패키지 필요
import 'package:app_links/app_links.dart';
import 'login/start.dart';
import 'splash.dart';
import 'home/home_screen.dart';
import 'api/auth_service.dart';
import 'api/social_login_service.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => FriendProvider(),
      child: const MapMoaApp(),
    ),
  );
}

class MapMoaApp extends StatelessWidget {
  const MapMoaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'mapmoa!',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.orange, fontFamily: 'Pretendard'),
      home: const AuthWrapper(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}

// 로그인 상태를 확인하는 래퍼 위젯
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService();
  final AppLinks _appLinks = AppLinks();
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _initDeepLinks();
  }

  void _initDeepLinks() {
    // 앱이 실행 중일 때 딥링크 처리
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
    print('딥링크 수신: $uri');

    // OAuth2 콜백 처리
    if (uri.path.startsWith('/login/oauth2/code/')) {
      final provider = uri.path.split('/').last; // google, kakao, naver
      print('OAuth2 콜백 수신: $provider');

      // 여기서 서버로 토큰을 요청하거나 추가 처리를 할 수 있습니다
      // 현재는 단순히 로그인 상태를 다시 확인합니다
      _checkLoginStatus();
    }

    // 커스텀 스킴 딥링크 처리 (mapmo://oauth2/redirect)
    if (uri.scheme == 'mapmo' &&
        uri.host == 'oauth2' &&
        uri.path == '/redirect') {
      final token = uri.queryParameters['token'];
      final refreshToken = uri.queryParameters['refreshToken'];

      if (token != null && refreshToken != null) {
        print('토큰 수신: $token');
        _handleOAuth2Success(token, refreshToken);
      }
    }
  }

  Future<void> _handleOAuth2Success(String token, String refreshToken) async {
    try {
      // 토큰 저장
      await SocialLoginService.saveTokensFromCallback(token, refreshToken);

      // AuthService를 사용하여 로그인 상태 확인
      final isLoggedIn = await _authService.isLoggedIn();

      if (isLoggedIn) {
        print('소셜 로그인 성공!');

        // mounted 체크 후 화면 전환
        if (mounted) {
          // Navigator를 사용하여 HomeScreen으로 이동
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } else {
        print('소셜 로그인 실패: 토큰이 유효하지 않습니다.');
        if (mounted) {
          setState(() {
            _isLoggedIn = false;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('토큰 저장 실패: $e');
      if (mounted) {
        setState(() {
          _isLoggedIn = false;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _checkLoginStatus() async {
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (mounted) {
        setState(() {
          _isLoggedIn = isLoggedIn;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('로그인 상태 확인 실패: $e');
      if (mounted) {
        setState(() {
          _isLoggedIn = false;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return _isLoggedIn ? const HomeScreen() : const LoginScreen();
  }
}

// 여기에 Provider 클래스 정의
class FriendProvider with ChangeNotifier {
  List<String> _friends = [];
  List<String> _requests = [];

  List<String> get friends => _friends;
  List<String> get requests => _requests;

  void addFriend(String name) {
    _friends.add(name);
    notifyListeners();
  }

  void removeFriend(String name) {
    _friends.remove(name);
    notifyListeners();
  }

  void addRequest(String name) {
    _requests.add(name);
    notifyListeners();
  }

  void acceptRequest(String name) {
    if (_requests.remove(name)) {
      _friends.add(name);
      notifyListeners();
    }
  }

  void rejectRequest(String name) {
    _requests.remove(name);
    notifyListeners();
  }

  void clear() {
    _friends.clear();
    _requests.clear();
    notifyListeners();
  }
}
