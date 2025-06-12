import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../community/community_page.dart';
import '../map/map_main.dart';
import '../api/schedule_service.dart';
import '../api/auth_service.dart';

class HomeScreen extends StatefulWidget {
  final bool showSignupComplete;
  const HomeScreen({super.key, this.showSignupComplete = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScheduleService _scheduleService = ScheduleService();
  final AuthService _authService = AuthService();
  List<dynamic> _schedules = [];
  Map<String, dynamic>? _currentUser;
  bool _isLoading = true;

  final List<Map<String, dynamic>> posts = [
    {'title': '[스타벅스] 3월 한 달간 30% 할인', 'location': '가좌동', 'likes': 4},
    {'title': '[올리브영] 새학기 학생들을 위한 20% 할인', 'location': '가좌동', 'likes': 3},
    {'title': '[배스킨라빈스] 봄 시즌 아이스크림 할인', 'location': '가좌동', 'likes': 2},
    {'title': '[OG버거] 개강 기념 블랙페퍼 버거 할인', 'location': '가좌동', 'likes': 1},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();

    if (widget.showSignupComplete) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSignupCompleteModal(context);
      });
    }
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // 현재 사용자 정보 가져오기
      final userData = await _authService.getCurrentUser();
      setState(() {
        _currentUser = userData;
      });

      // 사용자의 일정 가져오기
      final schedules = await _scheduleService.getAllSchedulesByUser(
        userData['id'],
      );
      setState(() {
        _schedules = schedules;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('데이터를 불러오는데 실패했습니다: $e')));
      }
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
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
            padding: const EdgeInsets.only(
              top: 40,
              left: 40,
              right: 40,
              bottom: 16,
            ),
            child: Column(
              children: [
                Column(
                  children: const [
                    CircleAvatar(
                      radius: 42,
                      backgroundColor: Color(0xFFE0E0E0),
                      child: Icon(Icons.person, size: 40, color: Colors.white),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '심슨 님',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '오늘은 3개의 일정이 있어요!',
                      style: TextStyle(color: Colors.grey),
                    ),
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
    if (_isLoading) {
      return Container(
        decoration: _boxDecoration(),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      decoration: _boxDecoration(),
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {},
            child: Container(
              height: 28,
              decoration: const BoxDecoration(
                color: Color(0xFFFFCC00),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
            ),
          ),
          Expanded(
            child:
                _schedules.isEmpty
                    ? const Center(child: Text('등록된 일정이 없습니다.'))
                    : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: _schedules.length,
                      separatorBuilder:
                          (_, __) => const Divider(
                            height: 1,
                            color: Color(0xFFE0E0E0),
                          ),
                      itemBuilder: (context, index) {
                        final schedule = _schedules[index];
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
                                    schedule['title'] ?? '제목 없음',
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ),
                              Checkbox(
                                value: schedule['isCompleted'] ?? false,
                                shape: const CircleBorder(),
                                activeColor: const Color(0xFFFFCC00),
                                onChanged: (val) async {
                                  try {
                                    await _scheduleService.updateSchedule(
                                      schedule['id'],
                                      _currentUser!['id'],
                                      {...schedule, 'isCompleted': val},
                                    );
                                    _loadData(); // 데이터 새로고침
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text('일정 상태 변경에 실패했습니다: $e'),
                                        ),
                                      );
                                    }
                                  }
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
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MapMainPage()),
        );
      },
      child: Container(
        decoration: _boxDecoration(),
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
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CommunityPage()),
        );
      },
      child: Container(
        decoration: _boxDecoration(),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: ListView.builder(
          itemCount: posts.length,
          physics: const BouncingScrollPhysics(),
          itemBuilder:
              (context, index) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: SizedBox(
                  height: 20,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.favorite,
                        color: Color(0xFFFF9900),
                        size: 20,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${posts[index]['likes']}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(width: 5),
                      const Icon(
                        Icons.location_on,
                        color: Color(0xFF4CAF50),
                        size: 18,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        posts[index]['location'],
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          posts[index]['title'],
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const Icon(Icons.more_vert, size: 20),
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
