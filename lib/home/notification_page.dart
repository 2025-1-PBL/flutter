import 'package:flutter/material.dart';
import '../widgets/custom_top_nav_bar.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 더미 알림 데이터
    final List<String> notifications = [
      '오늘 3개의 일정이 있어요!',
      '위치 기반 알림이 도착했어요.',
      '새로운 친구가 일정을 공유했어요.',
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          // ✅ 상단바는 전체 폭
          CustomTopBar(
            title: '알림 목록',
            onBack: () => Navigator.pop(context),
          ),

          // ✅ 나머지 아래 내용은 마진 40
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: ListView.separated(
                padding: const EdgeInsets.only(top: 20, bottom: 20),
                itemCount: notifications.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero, // 내부 여백 제거
                    leading: const Icon(Icons.notifications, color: Color(0xFFFFA724)),
                    title: Text(
                      notifications[index],
                      style: const TextStyle(fontSize: 16),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}