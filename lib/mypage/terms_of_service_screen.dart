import 'package:flutter/material.dart';
import '../widgets/custom_top_nav_bar.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          CustomTopBar(
            title: '이용약관',
            onBack: () => Navigator.pop(context),
          ),
          const SizedBox(height: 16),
          Expanded( // ✅ 스크롤 가능하게
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16), // ✅ 마진 유지
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('제1조 (목적)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text(
                      '맵모(이하 ‘앱’)가 제공하는 서비스를 이용해 주셔서 감사합니다. 앱은 여러분이 앱에 제공하는 다양한 인터넷과 모바일 서비스에 더 가깝고 편리하게 다가갈 수 있도록 ‘맵모 서비스 약관’(이하 ‘본 약관’)을 마련하였습니다. 여러분은 본 약관에 동의함으로써 서비스에 가입하여 서비스를 이용할 수 있습니다.\n\n'
                          '본 약관은 맵모(이하 ‘앱’)이 제공하는 서비스의 이용과 관련하여 회사와 ‘사용자’와의 권리, 의무 및 책임사항, 기타 필요한 사항을 규정하는 것을 목적으로 합니다.',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 24),
                    Text('제2조 (용어의 정의)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text(
                      '본 약관에서 사용하는 용어의 정의는 다음과 같습니다.\n'
                          '➀ ‘서비스’라 함은 제1조에 명시된 앱에서 제공하는 맵모 서비스 및 이와 관련된 서비스를 의미합니다.\n'
                          '➁ ‘사용자’이라 함은 본 약관에 따라 앱과 이용계약을 체결하고 회사가 제공하는 ‘서비스’를 이용할 수 있는 권한을 부여 받은 고객을 말합니다.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}