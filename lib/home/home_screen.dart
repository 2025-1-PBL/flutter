import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mapmoa/api/schedule_service.dart';
import 'package:mapmoa/api/auth_service.dart';
import 'package:mapmoa/global/user_profile.dart';
import 'package:mapmoa/mypage/my_info_edit_screen.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../community/community_page.dart';
import '../map/map_page.dart';

class HomeScreen extends StatefulWidget {
  final bool showSignupComplete;
  const HomeScreen({super.key, this.showSignupComplete = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScheduleService _scheduleService = ScheduleService();
  final AuthService _authService = AuthService();

  List<Map<String, dynamic>> allSchedules = [];
  final List<bool> _checked = [];
  bool _isLoading = true;
  String _errorMessage = '';
  Map<String, dynamic>? _currentUser;

  List<Map<String, dynamic>> posts = [];

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
        _errorMessage = '';
      });

      // 현재 사용자 정보 가져오기
      final userData = await _authService.getCurrentUser();
      setState(() {
        _currentUser = userData;
      });

      // 사용자의 일정 목록 가져오기
      final userId = userData['id'] as int;
      final schedules = await _scheduleService.getAllSchedulesByUser(userId);

      // 일정 데이터를 Map 형태로 변환
      final scheduleMaps =
          schedules.map((schedule) {
            return {
              'id': schedule['id'],
              'memo': schedule['memo'] ?? schedule['title'] ?? '',
              'location': schedule['location'] ?? '',
              'color': schedule['color'] ?? 'blue',
              'latitude': schedule['latitude'],
              'longitude': schedule['longitude'],
              'isShared': schedule['isShared'] ?? false,
              'createdAt': schedule['createdAt'],
            };
          }).toList();

      setState(() {
        allSchedules = scheduleMaps.reversed.toList();
        _checked.addAll(List.generate(allSchedules.length, (_) => false));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      print('데이터 로딩 실패: $e');
    }
  }

  Future<void> _deleteSchedule(int index) async {
    try {
      final schedule = allSchedules[index];
      final scheduleId = schedule['id'] as int;
      final userId = _currentUser?['id'] as int;

      await _scheduleService.deleteSchedule(scheduleId, userId);

      setState(() {
        allSchedules.removeAt(index);
        _checked.removeAt(index);
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('일정 삭제 실패: $e')));
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
                GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MyInfoEditScreen(),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      ValueListenableBuilder<String?>(
                        valueListenable: globalUserProfileImage,
                        builder: (context, imagePath, _) {
                          return CircleAvatar(
                            radius: 42,
                            backgroundColor: const Color(0xFFE0E0E0),
                            backgroundImage:
                                imagePath != null
                                    ? FileImage(File(imagePath))
                                    : null,
                            child:
                                imagePath == null
                                    ? const Icon(
                                      Icons.person,
                                      size: 40,
                                      color: Colors.white,
                                    )
                                    : null,
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      ValueListenableBuilder<String>(
                        valueListenable: globalUserName,
                        builder: (context, name, _) {
                          return Column(
                            children: [
                              Text(
                                '$name 님',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '오늘은 ${allSchedules.length}개의 일정이 있어요!',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
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
                _isLoading
                    ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFFCC00),
                      ),
                    )
                    : _errorMessage.isNotEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '데이터를 불러오는데 실패했습니다',
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _loadData,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFCC00),
                            ),
                            child: const Text('다시 시도'),
                          ),
                        ],
                      ),
                    )
                    : allSchedules.isEmpty
                    ? const Center(
                      child: Text(
                        '등록된 일정이 없습니다.',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    )
                    : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: allSchedules.length,
                      separatorBuilder:
                          (_, __) => const Divider(
                            height: 1,
                            color: Color(0xFFE0E0E0),
                          ),
                      itemBuilder: (context, index) {
                        final schedule = allSchedules[index];
                        final memoText = schedule['memo'] ?? '';
                        final isShared = schedule['isShared'] ?? false;

                        return SizedBox(
                          height: 36,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Row(
                                    children: [
                                      if (isShared)
                                        const Icon(
                                          Icons.people,
                                          size: 16,
                                          color: Color(0xFF4CAF50),
                                        ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          memoText,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ],
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

                                  if (val == true) {
                                    Future.delayed(
                                      const Duration(seconds: 2),
                                      () {
                                        if (!mounted) return;
                                        if (index >= allSchedules.length)
                                          return;
                                        _deleteSchedule(index);
                                      },
                                    );
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
          MaterialPageRoute(builder: (_) => const MapPage()),
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
        child:
            posts.isEmpty
                ? const Center(
                  child: Text(
                    '등록된 게시물이 없습니다.',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                )
                : ListView.builder(
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
