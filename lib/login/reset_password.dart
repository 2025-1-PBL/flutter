import 'package:flutter/material.dart';
import '../widgets/custom_top_nav_bar.dart';
import '../widgets/custom_next_nav_bar.dart';
import 'start.dart'; // ✅ LoginScreen 불러오기

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController newPwController = TextEditingController();
  final TextEditingController confirmPwController = TextEditingController();

  bool get isFormValid =>
      newPwController.text.trim().isNotEmpty &&
          confirmPwController.text.trim().isNotEmpty &&
          newPwController.text == confirmPwController.text;

  Widget _buildInputField(String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontSize: 16)),
            const Text('*', style: TextStyle(color: Colors.orange, fontSize: 16)),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2B1D1D).withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: true,
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            style: const TextStyle(fontSize: 16),
            onChanged: (_) => setState(() {}),
          ),
        ),
      ],
    );
  }

  Widget _buildNotice() {
    return const Text(
      '유의사항\n'
          '① 14세 미만 가입 회원은 가입 시 입력한 어린이 정보로 아이디 찾기가 가능합니다.\n'
          '② 휴면회원의 아이디 찾기도 가능하며, 휴면 해제 후 정상적 서비스 이용이 가능합니다.\n'
          '③ 탈퇴한 계정의 아이디 찾기는 불가능합니다.',
      style: TextStyle(fontSize: 14, color: Colors.black87),
    );
  }

  void _navigateWithModal() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginScreen(showResetPopup: true), // ✅ 여기 수정
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          CustomTopBar(
            title: '비밀번호 재설정',
            onBack: () => Navigator.pop(context),
          ),
          const SizedBox(height: 28),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '새로운 비밀번호를 입력해 주세요',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Divider(thickness: 1),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInputField('비밀번호', '8-16자 이내의 영문/숫자/특수문자 조합', newPwController),
                  const SizedBox(height: 16),
                  _buildInputField('비밀번호 확인', '비밀번호를 다시 입력해 주세요.', confirmPwController),
                  const SizedBox(height: 30),
                  _buildNotice(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(40, 0, 40, 40),
            child: CustomNextButton(
              label: '비밀번호 재설정',
              enabled: isFormValid,
              onPressed: _navigateWithModal,
            ),
          ),
        ],
      ),
    );
  }
}