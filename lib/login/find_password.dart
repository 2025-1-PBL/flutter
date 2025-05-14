import 'package:flutter/material.dart';
import '../widgets/custom_top_nav_bar.dart';
import '../widgets/custom_next_nav_bar.dart';
import 'reset_password.dart';

class FindPasswordScreen extends StatefulWidget {
  const FindPasswordScreen({super.key});

  @override
  State<FindPasswordScreen> createState() => _FindPasswordScreenState();
}

class _FindPasswordScreenState extends State<FindPasswordScreen> {
  bool isEmailTab = true;

  final TextEditingController idController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController codeController = TextEditingController();

  bool get isFormValid =>
      idController.text.trim().isNotEmpty &&
          nameController.text.trim().isNotEmpty &&
          contactController.text.trim().isNotEmpty &&
          codeController.text.trim().isNotEmpty;

  Widget _buildTabButton(String text, bool selected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            const SizedBox(height: 12),
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: selected ? const Color(0xFFFFA724) : Colors.grey,
              ),
            ),
            const SizedBox(height: 10),
            Stack(
              children: [
                Container(
                  height: 2.5,
                  width: double.infinity,
                  color: const Color(0xFFDDDDDD),
                ),
                if (selected)
                  Center(
                    child: Container(
                      height: 2.5,
                      width: 60,
                      color: const Color(0xFFFFA724),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
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

  Widget _buildRowInputWithButton({
    required String label,
    required String hint,
    required TextEditingController controller,
    required VoidCallback onButtonPressed,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Container(
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
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: onButtonPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C4B3F),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('인증번호', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
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

  void _handleSubmit() {
    if (!isFormValid) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('입력 오류'),
          content: const Text('모든 필드를 입력해 주세요.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('확인'),
            ),
          ],
        ),
      );
      return;
    }

    // ✅ 이동 처리
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ResetPasswordScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          CustomTopBar(
            title: '비밀번호 찾기',
            onBack: () => Navigator.pop(context),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(40, 12, 40, 0),
            child: Row(
              children: [
                _buildTabButton('이메일로 찾기', isEmailTab, () {
                  setState(() {
                    isEmailTab = true;
                    idController.clear();
                    nameController.clear();
                    contactController.clear();
                    codeController.clear();
                  });
                }),
                _buildTabButton('휴대폰번호로 찾기', !isEmailTab, () {
                  setState(() {
                    isEmailTab = false;
                    idController.clear();
                    nameController.clear();
                    contactController.clear();
                    codeController.clear();
                  });
                }),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInputField('아이디', '6-12자 이내의 영문/숫자', idController),
                  const SizedBox(height: 16),
                  _buildInputField('이름', '이름을 입력해 주세요.', nameController),
                  const SizedBox(height: 16),
                  _buildRowInputWithButton(
                    label: isEmailTab ? '이메일' : '휴대폰번호',
                    hint: isEmailTab
                        ? '회원정보에 등록된 이메일을 입력해 주세요.'
                        : '회원정보에 등록된 휴대폰번호를 입력해 주세요.',
                    controller: contactController,
                    onButtonPressed: () {
                      // 인증번호 전송 로직
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildInputField('인증번호 입력', '', codeController),
                  const SizedBox(height: 30),
                  _buildNotice(),
                  const SizedBox(height: 30),
                  CustomNextButton(
                    label: '비밀번호 재설정하러 가기',
                    enabled: isFormValid,
                    onPressed: _handleSubmit,
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