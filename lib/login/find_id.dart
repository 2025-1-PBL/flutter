import 'package:flutter/material.dart';
import '../widgets/custom_top_nav_bar.dart';
import '../widgets/custom_next_nav_bar.dart';

class FindIdScreen extends StatefulWidget {
  const FindIdScreen({super.key});

  @override
  State<FindIdScreen> createState() => _FindIdScreenState();
}

class _FindIdScreenState extends State<FindIdScreen> {
  bool isEmailTab = true;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailOrPhoneController = TextEditingController();

  bool get isFormValid =>
      nameController.text.trim().isNotEmpty &&
          emailOrPhoneController.text.trim().isNotEmpty;

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
            const SizedBox(height: 10), // 텍스트와 하이라이트 간 거리
            Stack(
              children: [
                Container(
                  height: 2.5,
                  width: double.infinity,
                  color: const Color(0xFFDDDDDD), // 회색 선 전체
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
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
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

  void _handleSubmit() {
    final name = nameController.text.trim();
    final value = emailOrPhoneController.text.trim();

    if (name.isEmpty || value.isEmpty) {
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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('아이디 찾기 요청을 보냈습니다.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          CustomTopBar(
            title: '아이디 찾기',
            onBack: () => Navigator.pop(context),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(40, 12, 40, 0),
            child: Row(
              children: [
                _buildTabButton('이메일로 찾기', isEmailTab, () {
                  setState(() {
                    isEmailTab = true;
                    nameController.clear();
                    emailOrPhoneController.clear();
                  });
                }),
                _buildTabButton('휴대폰 번호로 찾기', !isEmailTab, () {
                  setState(() {
                    isEmailTab = false;
                    nameController.clear();
                    emailOrPhoneController.clear();
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
                  _buildInputField('이름', '이름을 입력해 주세요.', nameController),
                  const SizedBox(height: 16),
                  _buildInputField(
                    isEmailTab ? '이메일' : '휴대폰번호',
                    isEmailTab
                        ? '회원정보에 등록된 이메일을 입력해 주세요.'
                        : '회원정보에 등록된 휴대폰번호를 입력해 주세요.',
                    emailOrPhoneController,
                  ),
                  const SizedBox(height: 30),
                  _buildNotice(),
                  const SizedBox(height: 30),
                  CustomNextButton(
                    label: '확인',
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