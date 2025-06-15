import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapmoa/map/personal_schedule_sheet.dart';
import 'package:mapmoa/map/shared_schedule_sheet.dart';
import 'package:mapmoa/api/schedule_service.dart';
import 'package:mapmoa/api/auth_service.dart';
import 'package:mapmoa/event/event_list_sheet.dart';
import 'package:mapmoa/event/event_data.dart';

class MapMainPage extends StatefulWidget {
  const MapMainPage({super.key});

  @override
  State<MapMainPage> createState() => _MapMainPageState();
}

class _MapMainPageState extends State<MapMainPage> {
  final ScheduleService _scheduleService = ScheduleService();
  final AuthService _authService = AuthService();

  bool _isInitialized = false;
  bool _isMenuOpen = false;
  bool _showPersonalMarkers = false;
  bool _showSharedMarkers = false;
  bool _showEvents = false;

  NaverMapController? _mapController;
  NLatLng? _currentLocation;

  final Map<String, NOverlayImage> _markerIcons = {};
  NOverlayImage? _locationIcon;
  NOverlayImage? _eventIcon;

  List<Map<String, dynamic>> _personalSchedules = [];
  List<Map<String, dynamic>> _sharedSchedules = [];
  bool _isLoadingSchedules = false;

  @override
  void initState() {
    super.initState();
    _initializeNaverMap();
    _loadAllMarkerIcons();
    _checkPermissionAndGetLocation();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    try {
      setState(() {
        _isLoadingSchedules = true;
      });

      // 현재 사용자 정보 가져오기
      final userData = await _authService.getCurrentUser();
      final userId = userData['id'] as int;

      // 사용자의 모든 일정 가져오기
      final allSchedules = await _scheduleService.getAllSchedulesByUser(userId);

      // 개인 일정과 공유 일정 분리
      final personalSchedules = <Map<String, dynamic>>[];
      final sharedSchedules = <Map<String, dynamic>>[];

      for (final schedule in allSchedules) {
        // 위치 정보가 있는 일정만 마커로 표시
        final latitude = schedule['latitude'];
        final longitude = schedule['longitude'];

        if (latitude != null && longitude != null) {
          final scheduleMap = {
            'id': schedule['id'],
            'memo': schedule['memo'] ?? schedule['title'] ?? '',
            'location': schedule['location'] ?? '',
            'color': schedule['color'] ?? 'blue',
            'latitude': latitude is int ? latitude.toDouble() : latitude,
            'longitude': longitude is int ? longitude.toDouble() : longitude,
            'isShared': schedule['isShared'] ?? false,
            'createdAt': schedule['createdAt'],
          };

          if (scheduleMap['isShared'] == true) {
            sharedSchedules.add(scheduleMap);
          } else {
            personalSchedules.add(scheduleMap);
          }
        }
      }

      setState(() {
        _personalSchedules = personalSchedules;
        _sharedSchedules = sharedSchedules;
        _isLoadingSchedules = false;
      });

      // 마커 새로고침
      await _refreshAllMarkers();
    } catch (e) {
      setState(() {
        _isLoadingSchedules = false;
      });
      print('일정 로딩 실패: $e');

      // 에러 메시지 표시
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('일정을 불러오는데 실패했습니다: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.black,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _initializeNaverMap() async {
    final naverMap = FlutterNaverMap();
    await naverMap.init(clientId: 'til8qbn0pj');
    setState(() {
      _isInitialized = true;
    });
  }

  Future<void> _loadAllMarkerIcons() async {
    _locationIcon = await _loadIconFromAsset('assets/location.png');
    _eventIcon = await _loadIconFromAsset('assets/markers/event.png');

    final colorToAsset = {
      'blue': 'assets/markers/blue.png',
      'green': 'assets/markers/green.png',
      'orange': 'assets/markers/orange.png',
      'purple': 'assets/markers/purple.png',
      'red': 'assets/markers/red.png',
      'yellow': 'assets/markers/yellow.png',
    };

    for (var entry in colorToAsset.entries) {
      final icon = await _loadIconFromAsset(entry.value);
      _markerIcons[entry.key] = icon;
    }
  }

  Future<NOverlayImage> _loadIconFromAsset(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    final bytes = byteData.buffer.asUint8List();
    return await NOverlayImage.fromByteArray(bytes);
  }

  Future<void> _checkPermissionAndGetLocation() async {
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
        timeLimit: const Duration(seconds: 10), // 10초 타임아웃
      );

      setState(() {
        _currentLocation = NLatLng(position.latitude, position.longitude);
      });

      if (_mapController != null && _currentLocation != null) {
        final cameraUpdate = NCameraUpdate.scrollAndZoomTo(
          target: _currentLocation!,
          zoom: 15,
        )..setAnimation();

        await _mapController!.updateCamera(cameraUpdate);

        if (_locationIcon != null) {
          final locationMarker = NMarker(
            id: 'current_location',
            position: _currentLocation!,
            icon: _locationIcon!,
          );
          await _mapController!.addOverlay(locationMarker);
        }
      }
    } catch (e) {
      print('위치 가져오기 실패: $e');
      _setDefaultLocation();
    }
  }

  // 기본 위치 설정 (서울 시청)
  void _setDefaultLocation() {
    setState(() {
      _currentLocation = const NLatLng(37.5665, 126.9780); // 서울 시청
    });

    if (_mapController != null && _currentLocation != null) {
      final cameraUpdate = NCameraUpdate.scrollAndZoomTo(
        target: _currentLocation!,
        zoom: 12, // 서울 전체가 보이도록 줌 레벨 조정
      )..setAnimation();

      _mapController!.updateCamera(cameraUpdate);
    }

    // 사용자에게 알림
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('위치 정보를 가져올 수 없어 서울 시청을 기본 위치로 설정했습니다.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  String _colorToKey(dynamic color) {
    if (color == null) return 'blue';
    if (color is String) return color.toLowerCase();

    final c = color is Color ? color : (color as MaterialColor).shade500;

    if (c.red > 230 && c.green < 100 && c.blue < 100) return 'red';
    if (c.red < 100 && c.green < 100 && c.blue > 230) return 'blue';
    if (c.red < 100 && c.green > 180 && c.blue < 100) return 'green';
    if (c.red > 200 && c.green > 100 && c.blue < 50) return 'orange';
    if (c.red > 150 && c.green < 100 && c.blue > 150) return 'purple';
    if (c.red > 230 && c.green > 220 && c.blue < 50) return 'yellow';

    return 'blue';
  }

  Future<void> _refreshAllMarkers() async {
    await _mapController?.clearOverlays();

    if (_currentLocation != null && _locationIcon != null) {
      final locationMarker = NMarker(
        id: 'current_location',
        position: _currentLocation!,
        icon: _locationIcon!,
      );
      await _mapController?.addOverlay(locationMarker);
    }

    if (_showPersonalMarkers) {
      for (final memo in _personalSchedules) {
        final lat = memo['latitude'];
        final lng = memo['longitude'];
        final colorRaw = memo['color'];
        if (lat is double && lng is double) {
          final colorKey = _colorToKey(colorRaw);
          final icon = _markerIcons[colorKey] ?? _markerIcons['blue']!;
          final marker = NMarker(
            id: 'personal-${memo['id']}',
            position: NLatLng(lat, lng),
            icon: icon,
          );
          marker.setOnTapListener((_) {
            final message =
                '${memo['location'] ?? ''}\n\'${memo['memo'] ?? ''}\'';
            _showSnackBar(message);
          });
          await _mapController?.addOverlay(marker);
        }
      }
    }

    if (_showSharedMarkers) {
      for (final memo in _sharedSchedules) {
        final lat = memo['latitude'];
        final lng = memo['longitude'];
        final colorRaw = memo['color'];
        if (lat is double && lng is double) {
          final colorKey = _colorToKey(colorRaw);
          final icon = _markerIcons[colorKey] ?? _markerIcons['blue']!;
          final marker = NMarker(
            id: 'shared-${memo['location'] ?? UniqueKey()}',
            position: NLatLng(lat, lng),
            icon: icon,
          );
          marker.setOnTapListener((_) {
            final message =
                '${memo['location'] ?? ''}\n\'${memo['memo'] ?? ''}\'';
            _showSnackBar(message);
          });
          await _mapController?.addOverlay(marker);
        }
      }
    }

    if (_showEvents && _eventIcon != null) {
      for (final event in globalEventList) {
        final lat = event['latitude'];
        final lng = event['longitude'];
        if (lat is double && lng is double) {
          final marker = NMarker(
            id: 'event-${event['title'] ?? UniqueKey()}',
            position: NLatLng(lat, lng),
            icon: _eventIcon!,
          );
          marker.setOnTapListener((_) {
            final message = '[${event['title']}] ${event['description']}';
            _showSnackBar(message);
          });
          await _mapController?.addOverlay(marker);
        }
      }
    }
  }

  void _showSnackBar(String message, {Color iconColor = Colors.orange}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
        duration: const Duration(seconds: 3),
        content: Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 25),
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
          child: Row(
            children: [
              Icon(Icons.place, color: iconColor, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.split('\n').first, // 메모
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF767676),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message.split('\n').length > 1
                          ? message.split('\n')[1]
                          : '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
    _refreshAllMarkers();
  }

  Future<void> _zoomIn() async {
    if (_mapController == null) return;
    await _mapController!.updateCamera(NCameraUpdate.zoomIn());
  }

  Future<void> _zoomOut() async {
    if (_mapController == null) return;
    await _mapController!.updateCamera(NCameraUpdate.zoomOut());
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
          onMemoTap: _goToLocation,
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
          onMemoTap: _goToLocation,
        );
      },
    );
  }

  Future<void> _goToCurrentLocation() async {
    try {
      // 위치 서비스가 활성화되어 있는지 확인
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnackBar('위치 서비스를 활성화해주세요.');
        return;
      }

      // 위치 권한 확인
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnackBar('위치 권한이 필요합니다.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showSnackBar('설정에서 위치 권한을 허용해주세요.');
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      final latLng = NLatLng(position.latitude, position.longitude);

      setState(() {
        _currentLocation = latLng;
      });

      final cameraUpdate = NCameraUpdate.scrollAndZoomTo(
        target: latLng,
        zoom: 15,
      )..setAnimation();

      await _mapController?.updateCamera(cameraUpdate);
      await _refreshAllMarkers();

      _showSnackBar('현재 위치로 이동했습니다.');
    } catch (e) {
      print('현재 위치 이동 실패: $e');
      _showSnackBar('위치를 가져오는데 실패했습니다.');
    }
  }

  Future<void> _goToLocation(NLatLng location) async {
    if (_mapController == null) return;

    final cameraUpdate = NCameraUpdate.scrollAndZoomTo(
      target: location,
      zoom: 15,
    )..setAnimation();

    await _mapController!.updateCamera(cameraUpdate);
    await _refreshAllMarkers();

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        children: [
          NaverMap(
            onMapReady: (controller) {
              _mapController = controller;
              if (_currentLocation != null) {
                final cameraUpdate = NCameraUpdate.scrollAndZoomTo(
                  target: _currentLocation!,
                  zoom: 15,
                )..setAnimation();
                _mapController!.updateCamera(cameraUpdate);
                _refreshAllMarkers();
              }
            },
          ),
          Positioned(
            top: 40,
            left: 40, // ← 마진 적용
            right: 40, // ← 마진 적용
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Column(
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
                      const SizedBox(height: 8),
                      _buildMenuButton(Icons.refresh, '새로고침'),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 90,
            left: 40, // 마진
            right: 40, // 마진
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  heroTag: 'zoom_in',
                  mini: true,
                  backgroundColor: Colors.white,
                  onPressed: _zoomIn,
                  child: const Icon(Icons.zoom_in, color: Colors.black),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 30,
            left: 40,
            right: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  heroTag: 'zoom_out',
                  mini: true,
                  backgroundColor: Colors.white,
                  onPressed: _zoomOut,
                  child: const Icon(Icons.zoom_out, color: Colors.black),
                ),
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
            _goToCurrentLocation();
          } else if (label == '개인 일정') {
            _showPersonalScheduleSheet();
          } else if (label == '공유 일정') {
            _showSharedScheduleSheet();
          } else if (label == '이벤트 목록') {
            _showEventListSheet();
          } else if (label == '새로고침') {
            _refreshData();
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

  // 새로고침 기능 추가
  Future<void> _refreshData() async {
    await _loadSchedules();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('데이터가 새로고침되었습니다.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color(0xFF4CAF50),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
