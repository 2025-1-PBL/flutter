import 'package:flutter/material.dart';
import 'login/start.dart';
import 'splash.dart'; // ✅ 추가

void main() {
  runApp(const MapMoaApp());
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
      home: const SplashScreen(), // ✅ 최초 화면을 SplashScreen으로 설정
    );
  }
}