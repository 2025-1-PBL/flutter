import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../community/community_page.dart';

class HomeScreen extends StatefulWidget {
  final bool showSignupComplete;
  const HomeScreen({super.key, this.showSignupComplete = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> memos = [
    '스타벅스 가서 아이스아메리카노랑 아...',
    '롯데마트가서 이거랑 이거랑 이거 사...',
    '약국에서 영양제 사고 물도 사기',
    '택배 찾아오기',
    '계란 사기',
    '은행 가기',
  ];
  final List<bool> _checked = [];

  @override
  void initState() {
    super.initState();
    _checked.addAll(List.generate(memos.length, (_) => false));

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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SizedBox(
          height: 200,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: '회원가입', style: TextStyle(color: Color(0xFFFFA724), fontWeight: FontWeight.bold)),
                      TextSpan(text: '이 되었습니다!', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 10),
                Text('맵모의 회원이 되신 것을 환영합니다!'),
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
    final boxHeight = (height - 360) / 3.2;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 40, left: 40, right: 40, bottom: 16),
            child: Column(
              children: [
                // 프로필
                Column(
                  children: [
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
                              child: Text('3', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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
                const SizedBox(height: 16),
                SizedBox(height: boxHeight, child: _buildScheduleCard()),
                const SizedBox(height: 16),
                SizedBox(height: boxHeight, child: _buildMapCard()),
                const SizedBox(height: 16),
                SizedBox(height: boxHeight, child: _buildCommunityCard()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleCard() {
    return Container(
      decoration: _boxDecoration(),
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              // TODO: 메모 페이지로 이동
            },
            child: Container(
              height: 28,
              decoration: const BoxDecoration(
                color: Color(0xFFFFCC00),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: memos.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFE0E0E0)),
              itemBuilder: (context, index) {
                return SizedBox(
                  height: 36,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            memos[index],
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                      Checkbox(
                        value: _checked[index],
                        shape: const CircleBorder(),
                        activeColor: const Color(0xFFFFCC00),
                        onChanged: (val) {
                          setState(() {
                            _checked[index] = val ?? false;
                          });
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapCard() {
    return Container(
      decoration: _boxDecoration(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          'assets/map.png',
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      ),
    );
  }

  Widget _buildCommunityCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const CommunityPage()));
      },
      child: Container(
        decoration: _boxDecoration(),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: ListView.builder(
          itemCount: 6,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SizedBox(
              height: 20,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Icon(Icons.favorite, color: Color(0xFFFF9900), size: 20),
                  SizedBox(width: 5),
                  Text('34', style: TextStyle(fontSize: 14)),
                  SizedBox(width: 5),
                  Icon(Icons.location_on, color: Color(0xFF4CAF50), size: 18),
                  SizedBox(width: 5),
                  Text('가좌동', style: TextStyle(fontSize: 14)),
                  SizedBox(width: 5),
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
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}