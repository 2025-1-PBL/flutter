import 'package:flutter/material.dart';
import '../home/home_screen.dart';
import 'join1.dart';
import 'find_email.dart';
import 'find_password.dart';
import '../api/auth_service.dart';
import 'snslogin.dart'; // 🔥 SNS 로그인 화면 import

class LoginScreen extends StatefulWidget {
  final bool showResetPopup;

  const LoginScreen({super.key, this.showResetPopup = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _hasShownPopup = false;
  final _authService = AuthService();

  Future<void> _login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('이메일과 패스워드를 입력해주세요.')));
      return;
    }

    try {
      await _authService.login(email, password);

      // 로그인 성공 시 홈 화면으로 이동
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('로그인에 실패했습니다: $e')));
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (widget.showResetPopup && !_hasShownPopup) {
      _hasShownPopup = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.white,
          isScrollControlled: false,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (context) {
            return SizedBox(
              width: double.infinity,
              height: 200,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '비밀번호 재설정',
                            style: TextStyle(
                              color: Color(0xFFFFA724),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: '이 완료되었습니다!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '수정된 비밀번호를 통해서\n맵모를 즐겨주시면 감사하겠습니다!',
                      style: TextStyle(color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const labelColor = Color(0xFF767676);
    final TextEditingController idController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 40,
                vertical: 100,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  Container(
                    height: 60,
                    color: Colors.grey[400],
                    margin: const EdgeInsets.only(bottom: 30),
                  ),
                  const Text(
                    '지금 Map-Mo와\n하루를 함께 하세요!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    '다양한 소식을 빠르게 확인해보세요',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: labelColor),
                  ),
                  const SizedBox(height: 20),

                  // 이메일 입력
                  Container(
                    decoration: _inputBoxDecoration(),
                    child: TextField(
                      controller: idController,
                      decoration: _inputDecoration('이메일을 입력하세요.'),
                    ),
                  ),
                  const SizedBox(height: 5),

                  // 비밀번호 입력
                  Container(
                    decoration: _inputBoxDecoration(),
                    child: TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: _inputDecoration('비밀번호를 입력하세요.'),
                    ),
                  ),
                  const SizedBox(height: 5),

                  // 자동 로그인 체크박스
                  Row(
                    children: [
                      Transform.translate(
                        offset: const Offset(-4, 0),
                        child: Checkbox(
                          value: false,
                          onChanged: (val) {},
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                      const Text(
                        '자동 로그인',
                        style: TextStyle(fontSize: 14, color: labelColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 소셜 로그인 버튼 → snslogin.dart 이동
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SnsLoginScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF316954),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      '소셜 로그인',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 5),

                  // 일반 로그인 버튼
                  ElevatedButton(
                    onPressed: () {
                      final email = idController.text.trim();
                      final password = passwordController.text.trim();
                      _login(email, password);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFA724),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      '로그인',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 아이디/비밀번호 찾기
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const FindIdScreen(),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          '이메일 찾기',
                          style: TextStyle(color: labelColor),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const FindPasswordScreen(),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          '비밀번호 찾기',
                          style: TextStyle(color: labelColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
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

  BoxDecoration _inputBoxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF2B1D1D).withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
    );
  }
}
