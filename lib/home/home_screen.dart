import 'package:flutter/material.dart';
import 'package:mapmoa/api/schedule_service.dart';
import 'package:mapmoa/api/auth_service.dart';
import 'package:mapmoa/api/article_service.dart';
import 'package:mapmoa/mypage/my_info_edit_screen.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../community/community_page.dart';
import '../map/map_page.dart';
import '../map/map_main.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'notification_page.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HomeScreen extends StatefulWidget {
  final bool showSignupComplete;
  const HomeScreen({super.key, this.showSignupComplete = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScheduleService _scheduleService = ScheduleService();
  final AuthService _authService = AuthService();
  final ArticleService _articleService = ArticleService();

  List<Map<String, dynamic>> allSchedules = [];
  final List<bool> _checked = [];
  bool _isLoading = true;
  String _errorMessage = '';
  Map<String, dynamic>? _currentUser;

  List<Map<String, dynamic>> posts = [];
  bool _isLoadingPosts = true;

  // 지도 관련 상태 변수들
  bool _isMapInitialized = false;
  NaverMapController? _mapController;
  NLatLng? _currentLocation;

  // 알림 관련 상태 변수
  int _unreadNotificationCount = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
    _initializeMap();

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

      // 게시글 목록 가져오기 (최신 5개만)
      List<Map<String, dynamic>> articlePosts = [];
      try {
        final articleResponse = await _articleService.getAllArticles(
          page: 0,
          size: 5,
        );
        final articles = articleResponse['content'] as List<dynamic>;

        articlePosts =
            articles.map((article) {
              return {
                'id': article['id'],
                'title': article['title'] ?? '',
                'content': article['content'] ?? '',
                'location': article['location'] ?? '',
                'likes': article['likeCount'] ?? 0,
                'author': article['author'] ?? '',
                'createdAt': article['createdAt'],
              };
            }).toList();
      } catch (e) {
        print('게시글 로딩 실패: $e');
        // 게시글 로딩 실패해도 일정은 계속 표시
      }

      // 읽지 않은 알림 개수 가져오기
      await _loadUnreadNotificationCount();

      setState(() {
        allSchedules = scheduleMaps.reversed.toList();
        _checked.addAll(List.generate(allSchedules.length, (_) => false));
        posts = articlePosts;
        _isLoading = false;
        _isLoadingPosts = false;
      });
    } catch (e) {
      print('데이터 로딩 실패: $e');

      // 토큰 관련 오류인지 확인
      if (e.toString().contains('토큰이 없습니다') ||
          e.toString().contains('사용자 정보를 불러오는 데 실패했습니다')) {
        // 로그인 페이지로 리다이렉트
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
        return;
      }

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
        _isLoadingPosts = false;
      });
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

  Future<void> _initializeMap() async {
    try {
      // 네이버 지도 초기화
      final naverMap = FlutterNaverMap();
      await naverMap.init(clientId: 'til8qbn0pj');

      setState(() {
        _isMapInitialized = true;
      });

      // 현재 위치 가져오기
      await _getCurrentLocation();
    } catch (e) {
      print('지도 초기화 실패: $e');
      // 기본 위치 설정 (서울 시청)
      setState(() {
        _currentLocation = const NLatLng(37.5665, 126.9780);
        _isMapInitialized = true;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      // 위치 서비스가 활성화되어 있는지 확인
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('위치 서비스가 비활성화되어 있습니다.');
        _setDefaultLocation();
        return;
      }

      // 위치 권한 확인
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('위치 권한이 거부되었습니다.');
          _setDefaultLocation();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('위치 권한이 영구적으로 거부되었습니다.');
        _setDefaultLocation();
        return;
      }

      // 현재 위치 가져오기
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      setState(() {
        _currentLocation = NLatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      print('위치 가져오기 실패: $e');
      _setDefaultLocation();
    }
  }

  void _setDefaultLocation() {
    setState(() {
      _currentLocation = const NLatLng(37.5665, 126.9780); // 서울 시청
    });
  }

  // 읽지 않은 알림 개수 가져오기
  Future<void> _loadUnreadNotificationCount() async {
    try {
      final dio = Dio();
      final storage = FlutterSecureStorage();
      final authToken = await storage.read(key: 'token');

      if (authToken != null) {
        dio.options.headers['Authorization'] = 'Bearer $authToken';

        final response = await dio.get(
          'http://ocb.iptime.org:8080/api/notifications/count',
        );

        if (response.statusCode == 200) {
          setState(() {
            _unreadNotificationCount = response.data['count'] ?? 0;
          });
        }
      }
    } catch (e) {
      print('알림 개수 로딩 실패: $e');
      // 실패해도 앱은 계속 실행
    }
  }

  Future<void> _checkPermissionAndGetLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('위치 서비스가 비활성화되어 있습니다.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('위치 권한이 거부되었습니다.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('위치 권한이 영구적으로 거부되었습니다.');
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentLocation = NLatLng(position.latitude, position.longitude);
      });

      if (_mapController != null && _currentLocation != null) {
        final cameraUpdate = NCameraUpdate.scrollAndZoomTo(
          target: _currentLocation!,
          zoom: 13,
        );
        await _mapController!.updateCamera(cameraUpdate);
      }
    } catch (e) {
      print('위치 가져오기 실패: $e');
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final boxHeight = (height - 360) / 3.2;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: const Color(0xFFFFA724),
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
                  _buildProfileSection(), // ✅ 변경된 부분
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
      ),
    );
  }

  Widget _buildProfileSection() {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MyInfoEditScreen()),
        );
        if (mounted) {
          await _loadData();
        }
      },
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // 프로필 아이콘
              CircleAvatar(
                radius: 42,
                backgroundColor: const Color(0xFFE0E0E0),
                child: const Icon(Icons.person, size: 40, color: Colors.white),
              ),

              // 알림 뱃지 버튼 (항상 표시)
              Positioned(
                top: -2,
                right: -2,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotificationPage(),
                      ),
                    );
                  },
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          _unreadNotificationCount > 0
                              ? const Color(0xFFFFCC00)
                              : Colors.grey,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        '$_unreadNotificationCount',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Column(
            children: [
              Text(
                '${_currentUser?['name'] ?? '사용자'} 님',
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
          ),
        ],
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
          MaterialPageRoute(
            builder:
                (context) => const Scaffold(
                  body: MapMainPage(),
                  bottomNavigationBar: CustomBottomNavBar(currentIndex: 1),
                ),
          ),
        );
      },
      child: Container(
        height: 200,
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
          child: Stack(
            children: [
              NaverMap(
                onMapReady: (controller) {
                  _mapController = controller;
                  _checkPermissionAndGetLocation();
                },
              ),
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => const Scaffold(
                                body: MapMainPage(),
                                bottomNavigationBar: CustomBottomNavBar(
                                  currentIndex: 1,
                                ),
                              ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
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
            _isLoadingPosts
                ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(
                      color: Color(0xFFFFA724),
                      strokeWidth: 2,
                    ),
                  ),
                )
                : posts.isEmpty
                ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      '등록된 게시물이 없습니다.',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
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
                              Flexible(
                                // ✅ 이 부분 추가
                                child: Text(
                                  posts[index]['location'] ?? '',
                                  style: const TextStyle(fontSize: 14),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  posts[index]['title'] ?? '',
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
