import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../widgets/custom_top_nav_bar.dart';
import '../widgets/custom_schedule_button.dart';

class MapSelectPage extends StatefulWidget {
  const MapSelectPage({super.key});

  @override
  State<MapSelectPage> createState() => _MapSelectPageState();
}

class _MapSelectPageState extends State<MapSelectPage> {
  NLatLng? selectedLatLng;
  String? selectedAddress;
  bool _isInitialized = false;
  NaverMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _initializeNaverMap();
    _checkPermissionAndGetLocation();
  }

  Future<void> _initializeNaverMap() async {
    final naverMap = FlutterNaverMap();
    await naverMap.init(clientId: 'til8qbn0pj');
    setState(() {
      _isInitialized = true;
    });
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
        timeLimit: const Duration(seconds: 10),
      );

      if (_mapController != null) {
        final currentLatLng = NLatLng(position.latitude, position.longitude);
        final cameraUpdate = NCameraUpdate.scrollAndZoomTo(
          target: currentLatLng,
          zoom: 15,
        )..setAnimation();

        await _mapController!.updateCamera(cameraUpdate);
      }
    } catch (e) {
      print('위치 가져오기 실패: $e');
      _setDefaultLocation();
    }
  }

  // 기본 위치 설정 (서울 시청)
  void _setDefaultLocation() {
    if (_mapController != null) {
      final defaultLocation = const NLatLng(37.5665, 126.9780); // 서울 시청
      final cameraUpdate = NCameraUpdate.scrollAndZoomTo(
        target: defaultLocation,
        zoom: 12,
      )..setAnimation();

      _mapController!.updateCamera(cameraUpdate);
    }
  }

  Future<void> _moveToCurrentLocation() async {
    try {
      // 위치 서비스가 활성화되어 있는지 확인
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('위치 서비스를 활성화해주세요.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      // 위치 권한 확인
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('위치 권한이 필요합니다.'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('설정에서 위치 권한을 허용해주세요.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      final currentLatLng = NLatLng(position.latitude, position.longitude);

      if (_mapController != null) {
        final cameraUpdate = NCameraUpdate.scrollAndZoomTo(
          target: currentLatLng,
          zoom: 15,
        )..setAnimation();

        await _mapController!.updateCamera(cameraUpdate);
      }
    } catch (e) {
      print('현재 위치 이동 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('위치를 가져오는데 실패했습니다.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _onMapTap(NPoint point, NLatLng latLng) async {
    setState(() {
      selectedLatLng = latLng;
    });

    final marker = NMarker(id: 'selected', position: latLng);
    _mapController?.clearOverlays();
    _mapController?.addOverlay(marker);

    final address = await _getAddressFromCoords(
      latLng.latitude,
      latLng.longitude,
    );
    setState(() {
      selectedAddress = address ?? '주소를 불러올 수 없습니다';
    });
  }

  Future<String?> _getAddressFromCoords(double lat, double lng) async {
    final url = Uri.parse(
      'https://maps.apigw.ntruss.com/map-reversegeocode/v2/gc'
      '?request=coordsToaddr'
      '&coords=$lng,$lat'
      '&sourcecrs=epsg:4326'
      '&output=json'
      '&orders=roadaddr,addr,admcode,legalcode',
    );

    final response = await http.get(
      url,
      headers: {
        'X-NCP-APIGW-API-KEY-ID': 'til8qbn0pj',
        'X-NCP-APIGW-API-KEY': 'An9HynJ2ZOKhkw3hYKxEccniuCX8hJAOvlN0Qayl',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final results = data['results'] as List;

      for (var result in results) {
        if (result['name'] == 'roadaddr') {
          final region = result['region'];
          final area1 = region['area1']['name'];
          final area2 = region['area2']['name'];

          final roadName = result['land']['name'] ?? '';
          final number1 = result['land']['number1'] ?? '';
          final number2 = result['land']['number2'] ?? '';
          final fullNumber = number2 != '' ? '$number1-$number2' : number1;
          final buildingName = result['land']['addition0']?['value'] ?? '';

          final roadAddr = '$area1 $area2 $roadName $fullNumber';
          return buildingName.isNotEmpty
              ? '$buildingName ($roadAddr)'
              : roadAddr;
        }
      }

      final fallback = results.firstWhere(
        (r) => r['name'] == 'admcode',
        orElse: () => null,
      );
      if (fallback != null) {
        final region = fallback['region'];
        return '${region['area1']['name']} ${region['area2']['name']} ${region['area3']['name']}';
      }
    } else {
      debugPrint('API 호출 실패: ${response.statusCode}');
    }

    return null;
  }

  Future<void> _zoomIn() async {
    if (_mapController != null) {
      await _mapController!.updateCamera(NCameraUpdate.zoomIn());
    }
  }

  Future<void> _zoomOut() async {
    if (_mapController != null) {
      await _mapController!.updateCamera(NCameraUpdate.zoomOut());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          CustomTopBar(title: '위치 선택', onBack: () => Navigator.pop(context)),
          Expanded(
            child: Stack(
              children: [
                NaverMap(
                  onMapTapped: _onMapTap,
                  onMapReady: (controller) {
                    _mapController = controller;
                    _moveToCurrentLocation();
                  },
                ),
                if (selectedLatLng != null)
                  Positioned(
                    top: 20,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Text(
                        selectedAddress ??
                            '주소를 불러오는 중... (${selectedLatLng!.latitude.toStringAsFixed(5)}, ${selectedLatLng!.longitude.toStringAsFixed(5)})',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 90,
                  left: 20,
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
                  left: 20,
                  child: FloatingActionButton(
                    heroTag: 'zoom_out',
                    mini: true,
                    backgroundColor: Colors.white,
                    onPressed: _zoomOut,
                    child: const Icon(Icons.zoom_out, color: Colors.black),
                  ),
                ),
                Positioned(
                  bottom: 40,
                  right: 40,
                  child: CustomScheduleButton.fromType(
                    type: ScheduleButtonType.select,
                    enabled: selectedLatLng != null,
                    onTap: () {
                      if (selectedLatLng != null) {
                        Navigator.pop(context, {
                          'latitude': selectedLatLng!.latitude,
                          'longitude': selectedLatLng!.longitude,
                          'address': selectedAddress,
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
