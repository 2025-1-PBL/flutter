import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'my_info_edit_screen.dart';
import 'terms_of_service_screen.dart';
import 'privacy_policy_screen.dart';
import 'member_manage_screen.dart';
import '../widgets/custom_bottom_nav_bar.dart';

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

  void _showInquiryDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 42),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('문의사항', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              const Text('abcd123@naver.com', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('문의 주시면 빠르게 답변해 드리겠습니다.', style: TextStyle(fontSize: 14)),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Clipboard.setData(const ClipboardData(text: 'abcd123@naver.com'));
                        Navigator.of(ctx).pop();
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.black),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('복사하기', style: TextStyle(color: Colors.black)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFA724),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('닫기', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
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

              // ✅ 심슨 님 프로필 카드
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
                    children: const [
                      Icon(Icons.account_circle, size: 56, color: Colors.grey),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '심슨 님',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF767676),
                          ),
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ✅ 공유 멤버 관리 카드 (BoxShadow 적용)
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

              // ✅ 설정 항목 카드 (BoxShadow + Divider 적용)
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
                    ),
                    buildTile(
                      icon: Icons.search,
                      title: '문의하기',
                      onTap: () => _showInquiryDialog(context),
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