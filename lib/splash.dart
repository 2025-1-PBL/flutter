import 'dart:async';
import 'package:flutter/material.dart';
import 'login/start.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();

    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.2, 0.2), // 느리게 오른쪽 아래로 이동
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));

    Timer(const Duration(seconds: 10), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildHugePatternGrid(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final gridWidth = screenSize.width * 5;
    final gridHeight = screenSize.height * 5;

    return SlideTransition(
      position: _animation,
      child: SizedBox(
        width: gridWidth,
        height: gridHeight,
        child: Wrap(
          spacing: 40,
          runSpacing: 40,
          children: List.generate(1000, (index) {
            return Opacity(
              opacity: 0.2,
              child: Image.asset(
                'assets/logo.png',
                width: 100,
                height: 100,
              ),
            );
          }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          _buildHugePatternGrid(context),
          Center(
            child: Image.asset(
              'assets/logo.png',
              width: 180,
              height: 180,
            ),
          ),
        ],
      ),
    );
  }
}