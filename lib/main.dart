import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
//테스트
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
        fontFamily: 'Pretendard', // 사용 중이면
      ),
      home: const HomeScreen(),
    );
  }
}
