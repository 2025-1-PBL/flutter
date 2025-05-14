import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  final bool showSignupComplete;

  const HomeScreen({super.key, this.showSignupComplete = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    if (widget.showSignupComplete) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSignupCompleteModal(context);
      });
    }
  }

  void _showSignupCompleteModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SizedBox(
          width: double.infinity,
          height: 200,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '회원가입',
                        style: TextStyle(
                          color: Color(0xFFFFA724),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: '이 되었습니다!',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 10),
                Text(
                  '맵모의 회원이 되신 것을 환영합니다!',
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: height * 0.22,
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Stack(
                    children: [
                      const CircleAvatar(
                        radius: 42,
                        backgroundColor: Color(0xFFE0E0E0),
                        child: Icon(Icons.person, size: 40, color: Colors.white),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 20,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Color(0xFFFFCC00),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Center(
                            child: Text(
                              '3',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text('심슨 님', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('오늘은 3개의 일정이 있어요!', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            SizedBox(height: height * 0.18, child: _buildScheduleCard()),
            SizedBox(height: height * 0.23, child: _buildMapCard()),
            Expanded(child: _buildCommunityCard()),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          children: [
            Container(
              height: 28,
              decoration: const BoxDecoration(
                color: Color(0xFFFFCC00),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  _buildScheduleRow('스타벅스 가서 아이스아메리카노랑 아...'),
                  const Divider(height: 16, color: Color(0xFFE0E0E0)),
                  _buildScheduleRow('롯데마트가서 이거랑 이거랑 이거 사...'),
                  const Divider(height: 16, color: Color(0xFFE0E0E0)),
                  _buildScheduleRow('약국에서 영양제 사고 물도 사기'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleRow(String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        const Icon(Icons.radio_button_unchecked, color: Colors.grey),
      ],
    );
  }

  Widget _buildMapCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            'assets/map.png',
            fit: BoxFit.cover,
            width: double.infinity,
          ),
        ),
      ),
    );
  }

  Widget _buildCommunityCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          children: List.generate(3, (_) => _buildCommunityItem()),
        ),
      ),
    );
  }

  Widget _buildCommunityItem() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: const [
          Icon(Icons.favorite, color: Color(0xFFFF9900), size: 20),
          SizedBox(width: 6),
          Text('34', style: TextStyle(fontSize: 14)),
          SizedBox(width: 10),
          Icon(Icons.location_on, color: Color(0xFF4CAF50), size: 18),
          SizedBox(width: 4),
          Text('가좌동', style: TextStyle(fontSize: 14)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              '올리브영 할인 레전드 ---',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          Icon(Icons.more_vert, size: 20)
        ],
      ),
    );
  }
}