import 'package:flutter/material.dart';
import '../widgets/custom_top_nav_bar.dart';

class PostDetailScreen extends StatelessWidget {
  final Map<String, dynamic> post;

  const PostDetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Stack(
        children: [
          // 초록색 상단 배경
          Container(
            height: screenHeight * 0.2,
            color: const Color(0xFF316954),
          ),
          Column(
            children: [
              CustomTopBar(
                title: '게시물',
                onBack: () => Navigator.pop(context),
                backgroundColor: Colors.transparent,
                titleColor: Colors.white,
                backIconColor: Colors.white,
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(40, 40, 40, 20),
                  children: [
                    // 좋아요/조회/북마크 박스
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2B1D1D).withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: const [
                          Icon(Icons.remove_red_eye, color: Color(0xFFFFA724)),
                          Text('31'),
                          Icon(Icons.favorite, color: Color(0xFFFFA724)),
                          Text('31'),
                          Icon(Icons.bookmark, color: Color(0xFFFFA724)),
                          Text('31'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 본문 박스
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2B1D1D).withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('제목',
                              style: TextStyle(fontSize: 16, color: Colors.black)),
                          const SizedBox(height: 6),
                          Text(
                            post['title'],
                            style: const TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          const SizedBox(height: 10), // 선 위 간격
                          const Divider(
                            thickness: 0.5,
                            color: Color(0xFF316954),
                          ),
                          const SizedBox(height: 10), // 선 아래 간격

                          const Text('위치',
                              style: TextStyle(fontSize: 16, color: Colors.black)),
                          const SizedBox(height: 6),
                          Text(
                            '${post['location']} 스타벅스',
                            style: const TextStyle(fontSize: 16, color: Color(0xFFBDBDBD)),
                          ),
                          const SizedBox(height: 20),

                          const Text('내용',
                              style: TextStyle(fontSize: 16, color: Colors.black)),
                          const SizedBox(height: 6),
                          const Text(
                            '지금 스벅 안에서 아메리카노 사려고 줄 서 있는 중인데 2시부터 사면 30% 할인해서 살 수 있다고 하더라. '
                                '근데 난 카페인 수혈 급해서 그냥 지금 바로 삼. 다른 사람들한테도 알려라 ㅋㅋ',
                            style: TextStyle(fontSize: 16, color: Colors.black, height: 1.5),
                          ),
                          const SizedBox(height: 20),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(
                              3,
                                  (index) => Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE0E0E0),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.camera_alt, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}