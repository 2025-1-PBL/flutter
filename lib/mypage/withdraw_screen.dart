import 'package:flutter/material.dart';
import '../widgets/custom_top_nav_bar.dart';
import '../widgets/custom_next_nav_bar.dart';
import '../widgets/custom_pop_up.dart';

class WithdrawScreen extends StatelessWidget {
  const WithdrawScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isEnabled = true; // 실제 조건에 맞게 변경 가능

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTopBar(
            title: '회원 탈퇴',
            onBack: () => Navigator.pop(context),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  const Text(
                    '회원 탈퇴 유의사항',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Divider(thickness: 1, color: Colors.black),
                  const SizedBox(height: 12),
                  const Text(
                    '• Map-mo! 회원탈퇴 시 회원정보 및 서비스 이용기록은 모두 삭제되며, 삭제된 데이터는 복구가 불가능합니다.\n\n'
                        '• Map-mo! 회원탈퇴 시 회원정보 및 서비스 이용기록은 모두 삭제되며, 삭제된 데이터는 복구가 불가능합니다.',
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 30),
                  CustomNextButton(
                    label: '탈퇴하기',
                    enabled: isEnabled,
                    onPressed: () {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (ctx) => LogoutPopup(
                          rootContext: context,
                          message: '탈퇴하시겠습니까?',
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
