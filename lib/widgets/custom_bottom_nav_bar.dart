import 'package:flutter/material.dart';
import 'package:mapmoa/home/home_screen.dart';
import 'package:mapmoa/map/map_page.dart';
import 'package:mapmoa/schedule/memo_page.dart';
import 'package:mapmoa/community/community_page.dart';
import 'package:mapmoa/mypage/mypage_screen.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> navItems = [
      {'icon': Icons.home, 'label': '홈', 'page': const HomeScreen()},
      {'icon': Icons.map, 'label': '지도', 'page': const MapPage()},
      {'icon': Icons.calendar_today, 'label': '일정', 'page': const MemoPage()},
      {'icon': Icons.group, 'label': '커뮤니티', 'page': const CommunityPage()},
      {'icon': Icons.person, 'label': 'MY', 'page': const MyPageScreen()},
    ];

    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(navItems.length, (index) {
          final isSelected = index == currentIndex;
          final color = isSelected ? const Color(0xFFFFA724) : const Color(0xFFBDBDBD);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: GestureDetector(
              onTap: () {
                if (index == currentIndex) return;
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) => navItems[index]['page'],
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              },
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: 70,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Icon(
                        navItems[index]['icon'],
                        size: 25,
                        color: color,
                      ),
                    ),
                    Text(
                      navItems[index]['label'],
                      style: TextStyle(
                        fontSize: 12,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}