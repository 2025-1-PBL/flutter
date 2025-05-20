import 'package:flutter/material.dart';
import 'edit_nickname_screen.dart';
import 'email_edit_screen.dart';
import 'password_edit_screen.dart';
import 'withdraw_screen.dart';
import '../widgets/custom_top_nav_bar.dart';
import '../widgets/custom_pop_up.dart';

class MyInfoEditScreen extends StatelessWidget {
  const MyInfoEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          CustomTopBar(
            title: '내 정보 수정',
            onBack: () => Navigator.pop(context),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // 프로필 이미지 영역
                  Align(
                    alignment: Alignment.center,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        const CircleAvatar(
                          radius: 48,
                          backgroundColor: Color(0xFFE0E0E0),
                          child: Icon(Icons.person, size: 50, color: Colors.white),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 4,
                          child: Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFFFA724),
                            ),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(Icons.edit, size: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 정보 수정 박스
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
                        _buildItem(context, '닉네임', trailing: '심슨'),
                        _buildItem(context, '이메일 변경'),
                        _buildItem(context, '비밀번호 변경', isLast: true),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 하단 메뉴 (계정탈퇴 / 로그아웃)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const WithdrawScreen()),
                          );
                        },
                        child: const Text('계정탈퇴', style: TextStyle(color: Colors.grey)),
                      ),
                      const SizedBox(width: 8),
                      const Text('|', style: TextStyle(color: Colors.grey)),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (ctx) => LogoutPopup(
                              rootContext: context,
                              message: '로그아웃 하시겠습니까?',
                            ),
                          );
                        },
                        child: const Text('로그아웃', style: TextStyle(color: Colors.grey)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, String title,
      {String? trailing, bool isLast = false}) {
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
        decoration: !isLast
            ? const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFE0E0E0)),
          ),
        )
            : null,
        child: Row(
          children: [
            Text(title, style: const TextStyle(fontSize: 16)),
            const Spacer(),
            if (trailing != null)
              Text(trailing, style: const TextStyle(color: Colors.grey)),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}