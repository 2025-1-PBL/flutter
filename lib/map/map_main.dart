import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:mapmoa/map/personal_schedule_sheet.dart';
import 'package:mapmoa/map/shared_schedule_sheet.dart';
import 'package:mapmoa/schedule/memo_data.dart';
import 'package:mapmoa/event/event_list_sheet.dart';

class MapMainPage extends StatefulWidget {
  const MapMainPage({super.key});

  @override
  State<MapMainPage> createState() => _MapMainPageState();
}

class _MapMainPageState extends State<MapMainPage> {
  bool _isInitialized = false;
  bool _isMenuOpen = false;
  bool _showPersonalMarkers = false;
  bool _showSharedMarkers = false;
  bool _showEvents = false;

  NaverMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _initializeNaverMap();
  }

  Future<void> _initializeNaverMap() async {
    final naverMap = FlutterNaverMap();
    await naverMap.init(clientId: 'til8qbn0pj');
    setState(() {
      _isInitialized = true;
    });
  }

  void _refreshAllMarkers() {
    _mapController?.clearOverlays();

    if (_showPersonalMarkers) {
      for (final memo in globalPersonalMemos) {
        final lat = memo['latitude'];
        final lng = memo['longitude'];
        if (lat != null && lng != null) {
          final marker = NMarker(
            id: 'personal-${memo['location'] ?? UniqueKey()}',
            position: NLatLng(lat, lng),
          );
          _mapController?.addOverlay(marker);
        }
      }
    }

    if (_showSharedMarkers) {
      for (final memo in globalSharedMemos) {
        final lat = memo['latitude'];
        final lng = memo['longitude'];
        if (lat != null && lng != null) {
          final marker = NMarker(
            id: 'shared-${memo['location'] ?? UniqueKey()}',
            position: NLatLng(lat, lng),
          );
          _mapController?.addOverlay(marker);
        }
      }
    }
  }

  void _updatePersonalMarkers(bool show) {
    setState(() {
      _showPersonalMarkers = show;
    });
    _refreshAllMarkers();
  }

  void _updateSharedMarkers(bool show) {
    setState(() {
      _showSharedMarkers = show;
    });
    _refreshAllMarkers();
  }

  void _updateShowEvents(bool show) {
    setState(() {
      _showEvents = show;
    });
  }

  void _showEventListSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) {
        return EventListSheet(
          showEvents: _showEvents,
          onToggleEvents: _updateShowEvents,
        );
      },
    );
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
          NaverMap(
            onMapReady: (controller) => _mapController = controller,
          ),
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
      width: 136,
      child: ElevatedButton(
        onPressed: () {
          debugPrint('$label 버튼 클릭됨');

          if (label == '현재 위치') {
            // TODO: 현재 위치 이동 함수 호출 (필요 시 구현)
          } else if (label == '개인 일정') {
            _showPersonalScheduleSheet();
          } else if (label == '공유 일정') {
            _showSharedScheduleSheet();
          } else if (label == '이벤트 목록') {
            _showEventListSheet();
          }
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
          mainAxisAlignment: MainAxisAlignment.center,
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
      isDismissible: true,
      enableDrag: true,
      builder: (context) {
        return PersonalScheduleSheet(
          showMarkers: _showPersonalMarkers,
          onToggleMarkers: _updatePersonalMarkers,
        );
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
        return SharedScheduleSheet(
          showMarkers: _showSharedMarkers,
          onToggleMarkers: _updateSharedMarkers,
        );
      },
    );
  }
}
