import 'package:flutter/material.dart';
import '../widgets/custom_top_nav_bar.dart';
import '../widgets/custom_next_nav_bar.dart';

class FindIdScreen extends StatefulWidget {
  const FindIdScreen({super.key});

  @override
  State<FindIdScreen> createState() => _FindIdScreenState();
}

class _FindIdScreenState extends State<FindIdScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  bool get isFormValid =>
      nameController.text.trim().isNotEmpty &&
          phoneController.text.trim().isNotEmpty;

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
            keyboardType: label == '휴대폰번호' ? TextInputType.phone : TextInputType.text,
          ),
        ),
      ],
    );
  }

  Widget _buildNotice() {
    return const Text(
      '유의사항\n'
          '① 14세 미만 가입 회원은 가입 시 입력한 어린이 정보로 이메일 찾기가 가능합니다.\n'
          '② 휴면회원의 이메일 찾기도 가능하며, 휴면 해제 후 정상적 서비스 이용이 가능합니다.\n'
          '③ 탈퇴한 계정의 이메일 찾기는 불가능합니다.',
      style: TextStyle(fontSize: 14, color: Colors.black87),
    );
  }

  void _handleSubmit() {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
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
      const SnackBar(content: Text('휴대폰 번호로 이메일 찾기 요청을 보냈습니다.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          CustomTopBar(
            title: '이메일 찾기',
            onBack: () => Navigator.pop(context),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInputField('이름', '이름을 입력해 주세요.', nameController),
                  const SizedBox(height: 16),
                  _buildInputField(
                    '휴대폰번호',
                    '회원정보에 등록된 휴대폰번호를 입력해 주세요.',
                    phoneController,
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