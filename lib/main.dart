import 'package:flutter/material.dart';
import 'login/start.dart';
import 'splash.dart'; // ✅ 추가
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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