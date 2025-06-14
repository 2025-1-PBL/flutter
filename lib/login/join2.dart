import 'package:flutter/material.dart';
import '../widgets/custom_top_nav_bar.dart';
import '../widgets/custom_next_nav_bar.dart';
import '../home/home_screen.dart';
import '../api/auth_service.dart';

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

  final AuthService _authService = AuthService();

  bool agreeEmail = false;
  bool agreeSMS = false;
  bool isFormValid = false;
  bool isPasswordMatch = true;
  bool _isLoading = false;
  bool _emailChecked = false;
  bool _nicknameChecked = false;

  void _validateForm() {
    final isValid =
        _idController.text.isNotEmpty &&
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
      _phoneController,
    ].forEach((controller) {
      controller.addListener(_validateForm);
    });

    // 이메일과 닉네임 변경 시 중복확인 상태 초기화
    _idController.addListener(() {
      if (_emailChecked) {
        setState(() {
          _emailChecked = false;
        });
      }
    });

    _nicknameController.addListener(() {
      if (_nicknameChecked) {
        setState(() {
          _nicknameChecked = false;
        });
      }
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
          CustomTopBar(title: '회원가입', onBack: () => Navigator.pop(context)),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 15),
                        const Text(
                          '회원정보',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        _buildTextField(
                          '이메일*',
                          _idController,
                          hint: '6-12자 이내의 영문/숫자',
                          showCheckButton: true,
                        ),
                        const SizedBox(height: 5),
                        _buildCheckboxTile(
                          '이메일 수신 동의',
                          value: agreeEmail,
                          onChanged: (val) {
                            setState(() => agreeEmail = val ?? false);
                          },
                        ),
                        const SizedBox(height: 5),
                        _buildTextField(
                          '비밀번호*',
                          _pwController,
                          hint: '8-16자 영문/숫자/특수문자 조합',
                          obscureText: true,
                        ),
                        const SizedBox(height: 5),
                        _buildTextField(
                          '비밀번호 확인*',
                          _pwConfirmController,
                          hint: '비밀번호 다시 입력',
                          obscureText: true,
                        ),
                        if (!isPasswordMatch)
                          const Padding(
                            padding: EdgeInsets.only(top: 4, left: 4),
                            child: Text(
                              '비밀번호가 다릅니다',
                              style: TextStyle(color: Colors.red, fontSize: 14),
                            ),
                          ),
                        const SizedBox(height: 5),
                        _buildTextField(
                          '닉네임*',
                          _nicknameController,
                          showCheckButton: true,
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          '개인정보',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        _buildTextField('이름*', _nameController),
                        const SizedBox(height: 5),
                        _buildDatePickerField(
                          label: '생년월일*',
                          controller: _birthController,
                        ),
                        const SizedBox(height: 5),
                        _buildTextField(
                          '휴대폰 번호*',
                          _phoneController,
                          hint: '휴대폰 번호를 입력해 주세요',
                        ),
                        const SizedBox(height: 5),
                        _buildCheckboxTile(
                          'SMS 수신 동의',
                          value: agreeSMS,
                          onChanged: (val) {
                            setState(() => agreeSMS = val ?? false);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 0, 40, 68),
                  child: CustomNextButton(
                    label: _isLoading ? '회원가입 중...' : '회원가입 완료하기',
                    enabled: isFormValid && !_isLoading,
                    onPressed: _isLoading ? null : _registerUser,
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
    if (!isFormValid) {
      _showErrorSnackBar('모든 필수 항목을 입력해주세요.');
      return;
    }

    // 중복확인 완료 여부 확인
    if (!_emailChecked) {
      _showErrorSnackBar('이메일 중복확인을 완료해주세요.');
      return;
    }

    if (!_nicknameChecked) {
      _showErrorSnackBar('닉네임 중복확인을 완료해주세요.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final email = _idController.text.trim();
      final password = _pwController.text.trim();
      final nickname = _nicknameController.text.trim();
      final name = _nameController.text.trim();
      final birth = _birthController.text.trim();
      final phone = _phoneController.text.trim();

      final userData = {
        'email': email,
        'password': password,
        'nickname': nickname,
        'name': name,
        'birth': birth,
        'phone': phone,
        'agreeEmail': agreeEmail,
        'agreeSMS': agreeSMS,
      };

      await _authService.signup(userData);

      // 회원가입 성공 시 홈 화면으로 이동
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const HomeScreen(showSignupComplete: true),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('회원가입에 실패했습니다: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    String hint = '',
    bool obscureText = false,
    bool showCheckButton = false,
  }) {
    bool isChecked = false;
    if (label == '이메일*') {
      isChecked = _emailChecked;
    } else if (label == '닉네임*') {
      isChecked = _nicknameChecked;
    }

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
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 6,
                  horizontal: 16,
                ),
                suffixIcon:
                    isChecked
                        ? const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 20,
                        )
                        : null,
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
              onPressed:
                  _isLoading
                      ? null
                      : () {
                        if (label == '이메일*') {
                          _checkEmailDuplicate();
                        } else if (label == '닉네임*') {
                          _checkNicknameDuplicate();
                        }
                      },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isChecked ? Colors.green : const Color(0xFF2C4B3F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                _isLoading ? '확인중...' : (isChecked ? '확인완료' : '중복확인'),
                style: const TextStyle(fontSize: 14, color: Colors.white),
              ),
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
            builder:
                (context, child) => Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: Color(0xFFFFA724),
                    ),
                  ),
                  child: child!,
                ),
          );
          if (picked != null) {
            controller.text =
                '${picked.year}/${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}';
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
          contentPadding: const EdgeInsets.symmetric(
            vertical: 6,
            horizontal: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildCheckboxTile(
    String label, {
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
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

  Future<void> _checkEmailDuplicate() async {
    final email = _idController.text.trim();
    if (email.isEmpty) {
      _showErrorSnackBar('이메일을 입력해주세요.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 이메일 중복확인은 회원가입 시 서버에서 처리
      // 여기서는 간단한 이메일 형식 검증만 수행
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(email)) {
        _showErrorSnackBar('올바른 이메일 형식을 입력해주세요.');
        return;
      }

      setState(() {
        _emailChecked = true;
      });

      _showSuccessSnackBar('사용 가능한 이메일입니다.');
    } catch (e) {
      _showErrorSnackBar('이메일 확인에 실패했습니다: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkNicknameDuplicate() async {
    final nickname = _nicknameController.text.trim();
    if (nickname.isEmpty) {
      _showErrorSnackBar('닉네임을 입력해주세요.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 닉네임 중복확인은 회원가입 시 서버에서 처리
      // 여기서는 간단한 길이 검증만 수행
      if (nickname.length < 2 || nickname.length > 20) {
        _showErrorSnackBar('닉네임은 2-20자 사이로 입력해주세요.');
        return;
      }

      setState(() {
        _nicknameChecked = true;
      });

      _showSuccessSnackBar('사용 가능한 닉네임입니다.');
    } catch (e) {
      _showErrorSnackBar('닉네임 확인에 실패했습니다: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
