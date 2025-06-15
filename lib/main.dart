import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // provider 패키지 필요
import 'package:app_links/app_links.dart';
import 'login/start.dart';
import 'splash.dart';
import 'home/home_screen.dart';
import 'api/auth_service.dart';
import 'api/social_login_service.dart';
import 'notification/setupFCM.dart';
import 'notification/fcmHandler.dart';
import 'notification/notificationService.dart';
import 'notification/websocketService.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // FCM 및 알림 기능 초기화
  try {
    await setupFCM();
    await setupNotifications();
    print('Firebase 알림 시스템 초기화 성공');
  } catch (e) {
    print('Firebase 알림 시스템 초기화 실패: $e');
  }

  // 로컬 알림 서비스 초기화 및 시작
  try {
    final localNotificationService = LocalNotificationService();
    await localNotificationService.initialize();

    // 로그인 상태 확인 후 알림 폴링 시작
    final authService = AuthService();
    try {
      final isLoggedIn = await authService.isLoggedIn();
      if (isLoggedIn) {
        localNotificationService.startPolling(
          interval: const Duration(minutes: 3),
        );
        print('알림 폴링 시작됨');
      }
    } catch (e) {
      print('로그인 상태 확인 실패: $e');
    }
  } catch (e) {
    print('로컬 알림 서비스 초기화 실패: $e');
    // 알림 서비스 초기화 실패해도 앱은 계속 실행
  }

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
  final LocalNotificationService _localNotificationService =
      LocalNotificationService();
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _initDeepLinks();
  }

  @override
  void dispose() {
    _localNotificationService.stopPolling();
    super.dispose();
  }

  void _initDeepLinks() {
    // 앱이 실행 중일 때 딥링크 처리 (일반적인 딥링크만 처리)
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

    // OAuth2 콜백 처리 (일반적인 HTTP/HTTPS 딥링크)
    if (uri.path.startsWith('/login/oauth2/code/')) {
      final provider = uri.path.split('/').last; // google, kakao, naver
      print('OAuth2 콜백 수신: $provider');

      // 여기서 서버로 토큰을 요청하거나 추가 처리를 할 수 있습니다
      // 현재는 단순히 로그인 상태를 다시 확인합니다
      _checkLoginStatus();
    }

    // 소셜 로그인 딥링크는 SnsLoginScreen에서 처리하므로 여기서는 제거
  }

  Future<void> _checkLoginStatus() async {
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (mounted) {
        setState(() {
          _isLoggedIn = isLoggedIn;
          _isLoading = false;
        });

        // 로그인 상태에 따라 알림 폴링 시작/중지
        if (isLoggedIn) {
          _localNotificationService.startPolling(
            interval: const Duration(minutes: 3),
          );
          print('로그인됨 - 알림 폴링 시작');
        } else {
          _localNotificationService.stopPolling();
          print('로그아웃됨 - 알림 폴링 중지');
        }
      }
    } catch (e) {
      print('로그인 상태 확인 실패: $e');
      if (mounted) {
        setState(() {
          _isLoggedIn = false;
          _isLoading = false;
        });
        _localNotificationService.stopPolling();
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
