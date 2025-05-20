import 'package:flutter/material.dart';
import '../widgets/custom_top_nav_bar.dart';
import 'password_reset_screen.dart'; // ✅ 새 화면 import

class PasswordEditScreen extends StatefulWidget {
  const PasswordEditScreen({super.key});

  @override
  State<PasswordEditScreen> createState() => _PasswordEditScreenState();
}

class _PasswordEditScreenState extends State<PasswordEditScreen> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isButtonActive = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() {
      setState(() {
        _isButtonActive = _passwordController.text.trim().isNotEmpty;
      });
    });
  }

  void _onNextPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PasswordResetScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTopBar(
            title: '비밀번호 변경',
            onBack: () => Navigator.pop(context),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  const Text(
                    '현재 비밀번호를 입력해주세요',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(thickness: 1, color: Colors.black),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: '현재 비밀번호 입력',
                      hintStyle: const TextStyle(color: Color(0xFFBDBDBD)),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: const BorderSide(color: Color(0xFFFFA724)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: ElevatedButton(
                      onPressed: _isButtonActive ? _onNextPressed : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 16),
                        backgroundColor: _isButtonActive
                            ? const Color(0xFFFFA724)
                            : const Color(0xFFBDBDBD),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        '다음',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}