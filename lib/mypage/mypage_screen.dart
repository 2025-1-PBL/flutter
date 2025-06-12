import 'dart:io';
import 'package:flutter/material.dart';
import 'my_info_edit_screen.dart';
import 'terms_of_service_screen.dart';
import 'privacy_policy_screen.dart';
import 'member_manage_screen.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/custom_pop_up.dart';
import 'package:mapmoa/global/user_profile.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  Widget buildTile({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    bool isLast = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Container(
        decoration: !isLast
            ? const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFE0E0E0)),
          ),
        )
            : null,
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: SizedBox(
            width: 24,
            height: 24,
            child: Center(
              child: Icon(icon, color: Color(0xFF767676), size: 20),
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(fontSize: 18, color: Color(0xFF767676)),
          ),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          onTap: onTap,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 4),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 80),

              // 프로필 카드
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 25),
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
                height: 120,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MyInfoEditScreen()),
                    );
                  },
                  child: Row(
                    children: [
                      ValueListenableBuilder<String?>(
                        valueListenable: globalUserProfileImage,
                        builder: (context, profilePath, child) {
                          return CircleAvatar(
                            radius: 28,
                            backgroundColor: const Color(0xFFE0E0E0),
                            backgroundImage: profilePath != null
                                ? FileImage(File(profilePath))
                                : null,
                            child: profilePath == null
                                ? const Icon(Icons.person, size: 40, color: Colors.white)
                                : null,
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      ValueListenableBuilder<String>(
                        valueListenable: globalUserName,
                        builder: (context, name, _) {
                          return Expanded(
                            child: Text(
                              '${name.isNotEmpty ? name : '사용자'} 님',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF767676),
                              ),
                            ),
                          );
                        },
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 공유 멤버 관리
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                height: 80,
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
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MemberManageScreen()),
                    );
                  },
                  child: Row(
                    children: const [
                      Icon(Icons.groups, color: Color(0xFF767676), size: 20),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '공유 멤버 관리',
                          style: TextStyle(fontSize: 18, color: Color(0xFF767676)),
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 설정 항목 박스
              Container(
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
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    buildTile(icon: Icons.info_outline, title: '버전정보 1.1.1'),
                    buildTile(
                      icon: Icons.description_outlined,
                      title: '이용약관',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const TermsOfServiceScreen()),
                        );
                      },
                    ),
                    buildTile(
                      icon: Icons.shield_outlined,
                      title: '개인정보처리 방침',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
                        );
                      },
                      isLast: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // 문의 및 이벤트 요청 박스
              Container(
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
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    buildTile(
                      icon: Icons.search,
                      title: '문의하기',
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => const InquiryPopup(),
                        );
                      },
                    ),
                    buildTile(
                      icon: Icons.send,
                      title: '가맹점 이벤트 추가 요청',
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => const StoreEventRequestPopup(),
                        );
                      },
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
