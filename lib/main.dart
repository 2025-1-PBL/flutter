import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // provider 패키지 필요
import 'login/start.dart';
import 'splash.dart';
import 'home/home_screen.dart';

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
      theme: ThemeData(
        primarySwatch: Colors.orange,
        fontFamily: 'Pretendard',
      ),
      home: const HomeScreen(),
    );
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
