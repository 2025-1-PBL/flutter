import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'join1.dart'; // JoinScreen import
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SnsLoginScreen extends StatelessWidget {
  const SnsLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const labelColor = Color(0xFF767676);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),

                  // 로고 이미지 영역
                  Container(
                    height: 60,
                    color: Colors.grey[400],
                    margin: const EdgeInsets.only(bottom: 30),
                  ),

                  // 타이틀
                  const Text(
                    '지금 Map-Mo와\n하루를 함께 하세요!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    '다양한 소식을 빠르게 확인해보세요',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: labelColor),
                  ),
                  const SizedBox(height: 20),

                  // 카카오 로그인 버튼
                  _snsButton(
                    color: const Color(0xFFFEE500),
                    text: '카카오 로그인',
                    textColor: Colors.black,
                    icon: Icons.chat_bubble_outline,
                    onPressed: () async {
                      final baseUrl = Platform.isAndroid ? 'http://10.0.2.2:8080' : 'http://127.0.0.1:8080';
                      final authUrl = '$baseUrl/oauth2/authorization/kakao';
                      if (await canLaunch(authUrl)) {
                        await launch(authUrl);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('카카오 로그인 URL을 열 수 없습니다.')),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 10),

                  // 구글 로그인 버튼
                  _snsButton(
                    color: Colors.white,
                    text: 'Google 로그인',
                    textColor: Colors.black87,
                    icon: Icons.g_mobiledata,
                    border: Border.all(color: Colors.grey.shade300),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('구글 소셜 로그인은 아직 구현되지 않았습니다.')),
                      );
                    },
                  ),
                  const SizedBox(height: 10),

                  // 네이버 로그인 버튼
                  _snsButton(
                    color: const Color(0xFF03C75A),
                    text: '네이버 로그인',
                    textColor: Colors.white,
                    icon: Icons.nat,
                    onPressed: () async {
                      final baseUrl = Platform.isAndroid ? 'http://10.0.2.2:8080' : 'http://127.0.0.1:8080';
                      final authUrl = '$baseUrl/oauth2/authorization/naver';
                      if (await canLaunch(authUrl)) {
                        await launch(authUrl);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('네이버 로그인 URL을 열 수 없습니다.')),
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 16),

                  // 다른 방법으로 로그인
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      '다른 방법으로 로그인',
                      style: TextStyle(fontSize: 14, color: Color(0xFFFFA724), fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            // 하단 회원가입 유도
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const JoinScreen()),
                    );
                  },
                  child: RichText(
                    text: const TextSpan(
                      text: '아직 맵모 회원이 아니신가요? ',
                      style: TextStyle(color: labelColor),
                      children: [
                        TextSpan(
                          text: '회원가입',
                          style: TextStyle(
                            color: labelColor,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _snsButton({
    required Color color,
    required String text,
    required Color textColor,
    required IconData icon,
    required VoidCallback onPressed,
    Border? border,
  }) {
    return SizedBox(
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: textColor),
        label: Text(text, style: TextStyle(color: textColor, fontSize: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: border?.top ?? BorderSide.none,
          ),
        ),
      ),
    );
  }
}