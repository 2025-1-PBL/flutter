import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'edit_nickname_screen.dart';
import 'email_edit_screen.dart';
import 'withdraw_screen.dart';
import '../widgets/custom_top_nav_bar.dart';
import '../widgets/custom_pop_up.dart';
import '../widgets/custom_schedule_button.dart';
import '../api/auth_service.dart';
import '../api/user_service.dart';
import 'password_edit_screen.dart';

class MyInfoEditScreen extends StatefulWidget {
  const MyInfoEditScreen({super.key});

  @override
  State<MyInfoEditScreen> createState() => _MyInfoEditScreenState();
}

class _MyInfoEditScreenState extends State<MyInfoEditScreen> {
  final ImagePicker _picker = ImagePicker();
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  XFile? _image;
  bool _isSaving = false;
  Map<String, dynamic>? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      final userData = await _authService.getCurrentUser();
      setState(() {
        _currentUser = userData;
      });
    } catch (e) {
      print('사용자 정보 로딩 실패: $e');
    }
  }

  Future<void> getUserProfileFromLibrary() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 600,
      maxWidth: 600,
      imageQuality: 50,
    );

    if (image != null) {
      setState(() {
        _image = image;
      });
    }
  }

  Future<void> postUserProfileToDB(String imagePath) async {
    try {
      print('프로필 이미지 업로드 시작: $imagePath');

      final token = await _authService.getStoredToken();
      if (token == null) {
        throw Exception('토큰이 없습니다.');
      }

      final response = await _userService.uploadProfileImage(imagePath);
      print('서버 응답: $response');

      // 성공적으로 업로드된 경우
      setState(() {
        _image = XFile(imagePath);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('프로필 이미지가 업로드되었습니다.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Color(0xFF4CAF50),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // 사용자 정보 새로고침
      await _loadUserInfo();
    } catch (e) {
      print('프로필 이미지 업로드 에러: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('프로필 이미지 업로드에 실패했습니다: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          CustomTopBar(title: '내 정보 수정', onBack: () => Navigator.pop(context)),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.center,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundColor: const Color(0xFFE0E0E0),
                          backgroundImage:
                              _image != null
                                  ? FileImage(File(_image!.path))
                                  : (_currentUser?['profilePic'] != null
                                      ? NetworkImage(
                                        _currentUser!['profilePic'],
                                      )
                                      : null),
                          child:
                              (_image == null &&
                                      _currentUser?['profilePic'] == null)
                                  ? const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.white,
                                  )
                                  : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 4,
                          child: GestureDetector(
                            onTap: getUserProfileFromLibrary,
                            child: Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFFFA724),
                              ),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(
                                Icons.edit,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2B1D1D).withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildItem(
                          context,
                          '닉네임',
                          trailingWidget: Text(
                            _currentUser?['name'] ?? '사용자',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                        _buildItem(context, '이메일 변경'),
                        _buildItem(context, '비밀번호 변경', isLast: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const WithdrawScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          '계정탈퇴',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('|', style: TextStyle(color: Colors.grey)),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () async {
                          // 로그아웃 확인 다이얼로그 표시
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder:
                                (ctx) => LogoutPopup(
                                  rootContext: context,
                                  message: '로그아웃 하시겠습니까?',
                                ),
                          );
                        },
                        child: const Text(
                          '로그아웃',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton:
          (_image != null && !_isSaving)
              ? Padding(
                padding: const EdgeInsets.only(bottom: 24, right: 40),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: CustomScheduleButton(
                    icon: Icons.check,
                    label: '저장',
                    enabled: true,
                    onTap: () async {
                      setState(() {
                        _isSaving = true;
                      });

                      try {
                        if (_image != null) {
                          await postUserProfileToDB(_image!.path);

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('프로필 사진이 저장되었습니다.'),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Color(0xFF4CAF50),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        }
                      } catch (e) {
                        print('프로필 사진 저장 실패: $e');
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('프로필 사진 저장에 실패했습니다: $e'),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.red,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      } finally {
                        if (mounted) {
                          setState(() {
                            _image = null;
                            _isSaving = false;
                          });
                        }
                      }
                    },
                  ),
                ),
              )
              : null,
    );
  }

  Widget _buildItem(
    BuildContext context,
    String title, {
    String? trailing,
    Widget? trailingWidget,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: () {
        if (title == '닉네임') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EditNicknameScreen()),
          );
        } else if (title == '이메일 변경') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EmailEditScreen()),
          );
        } else if (title == '비밀번호 변경') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PasswordEditScreen()),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration:
            !isLast
                ? const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0))),
                )
                : null,
        child: Row(
          children: [
            Text(title, style: const TextStyle(fontSize: 16)),
            const Spacer(),
            if (trailingWidget != null)
              trailingWidget
            else if (trailing != null)
              Text(trailing, style: const TextStyle(color: Colors.grey)),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
