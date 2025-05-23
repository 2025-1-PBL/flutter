import 'package:flutter/material.dart';
import 'login/start.dart';

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
      home: const LoginScreen(),
    );
  }
}
