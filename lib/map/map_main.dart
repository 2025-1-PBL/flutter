import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:mapmoa/map/personal_schedule_sheet.dart';
import 'package:mapmoa/map/shared_schedule_sheet.dart';
import '../map/map_main.dart';

class MapMainPage extends StatefulWidget {
  const MapMainPage({super.key});

  @override
  State<MapMainPage> createState() => _MapMainPageState();
}

class _MapMainPageState extends State<MapMainPage> {
  bool _isInitialized = false;
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _initializeNaverMap();
  }

  Future<void> _initializeNaverMap() async {
    final naverMap = FlutterNaverMap();
    await naverMap.init(clientId: 'til8qbn0pj'); // ✅ 형의 클라이언트 ID
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          const NaverMap(),

          // ✅ 지도 위 메뉴 버튼
          Positioned(
            top: 40,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FloatingActionButton(
                  mini: true,
                  heroTag: 'menu',
                  backgroundColor: Colors.white,
                  onPressed: () {
                    setState(() {
                      _isMenuOpen = !_isMenuOpen;
                    });
                  },
                  child: Icon(
                    _isMenuOpen ? Icons.close : Icons.menu,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                if (_isMenuOpen) ...[
                  _buildMenuButton(Icons.my_location, '현재 위치'),
                  const SizedBox(height: 8),
                  _buildMenuButton(Icons.person, '개인 일정'),
                  const SizedBox(height: 8),
                  _buildMenuButton(Icons.groups, '공유 일정'),
                  const SizedBox(height: 8),
                  _buildMenuButton(Icons.event, '이벤트 목록'),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(IconData icon, String label) {
    return SizedBox(
      width: 136, // ✅ 너비 고정
      child: ElevatedButton(
        onPressed: () {
          debugPrint('$label 버튼 클릭됨');

          if (label == '개인 일정') {
            _showPersonalScheduleSheet();
          } else if (label == '공유 일정') {
            _showSharedScheduleSheet();
          }
          // 나중에 현재 위치, 이벤트 목록도 처리 가능
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center, // ✅ 가운데 정렬
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }


  void _showPersonalScheduleSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true, // ✅ 배경 터치 시 닫히도록 설정
      enableDrag: true,    // ✅ 드래그로도 닫히게
      builder: (context) {
        return const PersonalScheduleSheet();
      },
    );
  }

  void _showSharedScheduleSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) {
        return const SharedScheduleSheet();
      },
    );
  }


}
