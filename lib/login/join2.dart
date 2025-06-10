import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../widgets/custom_top_nav_bar.dart';
import '../widgets/custom_next_nav_bar.dart';
import '../home/home_screen.dart';

final Dio _dio = Dio();
final String _registerUrl = 'http://127.0.0.1:8080/api/signup';

class Join2Screen extends StatefulWidget {
  const Join2Screen({super.key});

  @override
  State<Join2Screen> createState() => _Join2ScreenState();
}

class _Join2ScreenState extends State<Join2Screen> {
  final _idController = TextEditingController();
  final _pwController = TextEditingController();
  final _pwConfirmController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _nameController = TextEditingController();
  final _birthController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  bool agreeEmail = false;
  bool agreeSMS = false;
  bool isFormValid = false;
  bool isPasswordMatch = true;

  void _validateForm() {
    final isValid = _idController.text.isNotEmpty &&
        _pwController.text.isNotEmpty &&
        _pwConfirmController.text.isNotEmpty &&
        _nicknameController.text.isNotEmpty &&
        _nameController.text.isNotEmpty &&
        _birthController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _phoneController.text.isNotEmpty;

    final pwMatch = _pwController.text == _pwConfirmController.text;

    setState(() {
      isFormValid = isValid && pwMatch;
      isPasswordMatch = pwMatch;
    });
  }

  @override
  void initState() {
    super.initState();
    [
      _idController,
      _pwController,
      _pwConfirmController,
      _nicknameController,
      _nameController,
      _birthController,
      _emailController,
      _phoneController
    ].forEach((controller) {
      controller.addListener(_validateForm);
    });
  }

  @override
  void dispose() {
    _idController.dispose();
    _pwController.dispose();
    _pwConfirmController.dispose();
    _nicknameController.dispose();
    _nameController.dispose();
    _birthController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          CustomTopBar(
            title: '회원가입',
            onBack: () => Navigator.pop(context),
          ),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 15),
                        const Text('회원정보', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        _buildTextField('이메일*', _idController, hint: '6-12자 이내의 영문/숫자', showCheckButton: true),
                        const SizedBox(height: 5),
                        _buildCheckboxTile('이메일 수신 동의', value: agreeEmail, onChanged: (val) {
                          setState(() => agreeEmail = val ?? false);
                        }),
                        const SizedBox(height: 5),
                        _buildTextField('비밀번호*', _pwController, hint: '8-16자 영문/숫자/특수문자 조합', obscureText: true),
                        const SizedBox(height: 5),
                        _buildTextField('비밀번호 확인*', _pwConfirmController, hint: '비밀번호 다시 입력', obscureText: true),
                        if (!isPasswordMatch)
                          const Padding(
                            padding: EdgeInsets.only(top: 4, left: 4),
                            child: Text('비밀번호가 다릅니다', style: TextStyle(color: Colors.red, fontSize: 14)),
                          ),
                        const SizedBox(height: 5),
                        _buildTextField('닉네임*', _nicknameController, showCheckButton: true),
                        const SizedBox(height: 15),
                        const Text('개인정보', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        _buildTextField('이름*', _nameController),
                        const SizedBox(height: 5),
                        _buildDatePickerField(label: '생년월일*', controller: _birthController),
                        const SizedBox(height: 5),
                        _buildTextField('휴대폰 번호*', _phoneController, hint: '휴대폰 번호를 입력해 주세요'),
                        const SizedBox(height: 5),
                        _buildCheckboxTile('SMS 수신 동의', value: agreeSMS, onChanged: (val) {
                          setState(() => agreeSMS = val ?? false);
                        }),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 0, 40, 68),
                  child: CustomNextButton(
                    label: '회원가입 완료하기',
                    enabled: true,
                    onPressed: _registerUser,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _registerUser() async {
    final email = _idController.text.trim();
    final password = _pwController.text.trim();
    final nickname = _nicknameController.text.trim();
    final name = _nameController.text.trim();
    final birth = _birthController.text.trim();
    final phone = _phoneController.text.trim();

    final data = {
      'email': email,
      'password': password,
      'nickname': nickname,
      'name': name,
      'birth': birth,
      'phone': phone,
    };

    try {
      final response = await _dio.post(
        _registerUrl,
        data: data,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        // 회원가입 성공 시 홈 화면으로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen(showSignupComplete: true)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('회원가입에 실패했습니다: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류가 발생했습니다: $e')),
      );
    }
  }

  Widget _buildTextField(
      String label,
      TextEditingController controller, {
        String hint = '',
        bool obscureText = false,
        bool showCheckButton = false,
      }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: showCheckButton ? 7 : 1,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2B1D1D).withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              cursorColor: Colors.black,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                labelText: label,
                hintText: hint,
                isDense: true,
                labelStyle: const TextStyle(color: Colors.black),
                floatingLabelStyle: const TextStyle(color: Colors.black),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
              ),
            ),
          ),
        ),
        if (showCheckButton) const SizedBox(width: 10),
        if (showCheckButton)
          SizedBox(
            width: 97,
            height: 52,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2C4B3F),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('중복확인', style: TextStyle(fontSize: 14, color: Colors.white)),
            ),
          ),
      ],
    );
  }

  Widget _buildDatePickerField({
    required String label,
    required TextEditingController controller,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2B1D1D).withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        readOnly: true,
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
            builder: (context, child) => Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(primary: Color(0xFFFFA724)),
              ),
              child: child!,
            ),
          );
          if (picked != null) {
            controller.text = '${picked.year}/${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}';
          }
        },
        cursorColor: Colors.black,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          labelText: label,
          hintText: '날짜를 선택해주세요',
          isDense: true,
          labelStyle: const TextStyle(color: Colors.black),
          floatingLabelStyle: const TextStyle(color: Colors.black),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildCheckboxTile(String label,
      {required bool value, required ValueChanged<bool?> onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(left: 0),
      child: SizedBox(
        height: 30,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Checkbox(
              value: value,
              onChanged: onChanged,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: 1),
            Text(label, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}