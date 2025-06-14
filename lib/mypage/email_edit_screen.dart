import 'package:flutter/material.dart';
import '../widgets/custom_top_nav_bar.dart';
import '../api/user_service.dart';
import '../api/auth_service.dart';

class EmailEditScreen extends StatefulWidget {
  const EmailEditScreen({super.key});

  @override
  State<EmailEditScreen> createState() => _EmailEditScreenState();
}

class _EmailEditScreenState extends State<EmailEditScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _verificationCodeController =
      TextEditingController();
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();
  bool _isButtonActive = false;
  bool _isVerificationSent = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() {
      setState(() {
        _isButtonActive = _emailController.text.trim().isNotEmpty;
      });
    });
  }

  Future<void> _sendVerificationCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: 이메일 인증번호 발송 API 호출
      // await _userService.sendEmailVerification(email);

      setState(() {
        _isVerificationSent = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('인증번호가 발송되었습니다.'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('인증번호 발송에 실패했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateEmail() async {
    final email = _emailController.text.trim();
    final verificationCode = _verificationCodeController.text.trim();

    if (email.isEmpty || verificationCode.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // 현재 사용자 정보 가져오기
      final userData = await _authService.getCurrentUser();
      final userId = userData['id'] as int;

      // TODO: 이메일 변경 API 호출 (인증번호 확인 포함)
      // await _userService.updateUser(userId, {
      //   'email': email,
      //   'verificationCode': verificationCode,
      // });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('이메일이 변경되었습니다.'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('이메일 변경에 실패했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTopBar(title: '이메일 변경', onBack: () => Navigator.pop(context)),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40), // ✅ 마진 40
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  const Text(
                    '새로운 이메일 주소를 입력해주세요.',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Divider(thickness: 1, color: Colors.black),
                  const SizedBox(height: 12),

                  // 이메일 입력창 + 인증번호 버튼
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _emailController,
                          enabled: !_isVerificationSent,
                          decoration: InputDecoration(
                            hintText: '새로운 이메일 주소',
                            hintStyle: const TextStyle(
                              color: Color(0xFFBDBDBD),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(28),
                              borderSide: const BorderSide(
                                color: Color(0xFFE0E0E0),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(28),
                              borderSide: const BorderSide(
                                color: Color(0xFFFFA724),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed:
                            (_isButtonActive &&
                                    !_isLoading &&
                                    !_isVerificationSent)
                                ? _sendVerificationCode
                                : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF256440),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child:
                            _isLoading
                                ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : const Text(
                                  '인증번호',
                                  style: TextStyle(color: Colors.white),
                                ),
                      ),
                    ],
                  ),

                  if (_isVerificationSent) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: _verificationCodeController,
                      decoration: InputDecoration(
                        hintText: '인증번호 입력',
                        hintStyle: const TextStyle(color: Color(0xFFBDBDBD)),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28),
                          borderSide: const BorderSide(
                            color: Color(0xFFE0E0E0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28),
                          borderSide: const BorderSide(
                            color: Color(0xFFFFA724),
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // 변경하기 버튼
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          (_isVerificationSent && !_isLoading)
                              ? _updateEmail
                              : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor:
                            (_isVerificationSent && !_isLoading)
                                ? const Color(0xFFFFA724)
                                : const Color(0xFFBDBDBD),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child:
                          _isLoading
                              ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : const Text(
                                '변경하기',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
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
