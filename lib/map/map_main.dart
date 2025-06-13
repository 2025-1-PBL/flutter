import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapmoa/map/personal_schedule_sheet.dart';
import 'package:mapmoa/map/shared_schedule_sheet.dart';
import 'package:mapmoa/schedule/memo_data.dart';
import 'package:mapmoa/event/event_list_sheet.dart';
import 'package:mapmoa/event/event_data.dart';

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
  NLatLng? _currentLocation;

  final Map<String, NOverlayImage> _markerIcons = {};
  NOverlayImage? _locationIcon;
  NOverlayImage? _eventIcon;

  @override
  void initState() {
    super.initState();
    _initializeNaverMap();
    _loadAllMarkerIcons();
    _checkPermissionAndGetLocation();
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
    var status = await Permission.location.status;
    if (!status.isGranted) {
      status = await Permission.location.request();
      if (!status.isGranted) return;
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
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
      for (final memo in globalPersonalMemos) {
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
            final message = '${memo['location'] ?? ''}\n\'${memo['memo'] ?? ''}\'';
            _showSnackBar(message);
          });
          await _mapController?.addOverlay(marker);
        }
      }
    }

    if (_showSharedMarkers) {
      for (final memo in globalSharedMemos) {
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
            final message = '${memo['location'] ?? ''}\n\'${memo['memo'] ?? ''}\'';
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

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.grey[900],
        content: Center(
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        duration: const Duration(seconds: 3),
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
    var status = await Permission.location.status;
    if (!status.isGranted) {
      status = await Permission.location.request();
      if (!status.isGranted) {
        _showSnackBar('위치 권한이 필요합니다.');
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
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
          Positioned(
            bottom: 90,
            right: 20,
            child: FloatingActionButton(
              heroTag: 'zoom_in',
              mini: true,
              backgroundColor: Colors.white,
              onPressed: _zoomIn,
              child: const Icon(Icons.zoom_in, color: Colors.black),
            ),
          ),
          Positioned(
            bottom: 30,
            right: 20,
            child: FloatingActionButton(
              heroTag: 'zoom_out',
              mini: true,
              backgroundColor: Colors.white,
              onPressed: _zoomOut,
              child: const Icon(Icons.zoom_out, color: Colors.black),
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
}