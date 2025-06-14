import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // provider 패키지 필요
import 'login/start.dart';
import 'splash.dart';
import 'home/home_screen.dart';
import 'api/auth_service.dart';

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
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      setState(() {
        _isLoggedIn = isLoggedIn;
        _isLoading = false;
      });
    } catch (e) {
      print('로그인 상태 확인 실패: $e');
      setState(() {
        _isLoggedIn = false;
        _isLoading = false;
      });
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
