import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:http/http.dart' as http;

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
  }

  Future<void> _initializeNaverMap() async {
    final naverMap = FlutterNaverMap();
    await naverMap.init(clientId: 'til8qbn0pj');
    setState(() {
      _isInitialized = true;
    });
  }

  void _onMapTap(NPoint point, NLatLng latLng) async {
    setState(() {
      selectedLatLng = latLng;
    });

    final marker = NMarker(id: 'selected', position: latLng);
    _mapController?.clearOverlays();
    _mapController?.addOverlay(marker);

    final address = await _getAddressFromCoords(latLng.latitude, latLng.longitude);
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
            '&orders=roadaddr,addr,admcode,legalcode'
    );

    final response = await http.get(url, headers: {
      'X-NCP-APIGW-API-KEY-ID': 'til8qbn0pj',
      'X-NCP-APIGW-API-KEY': 'An9HynJ2ZOKhkw3hYKxEccniuCX8hJAOvlN0Qayl',
    });

    debugPrint('statusCode: ${response.statusCode}');
    debugPrint('response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final results = data['results'] as List;

      for (var result in results) {
        if (result['name'] == 'roadaddr') {
          final region = result['region'];
          final area1 = region['area1']['name'];
          final area2 = region['area2']['name'];
          final area3 = region['area3']['name'];

          final land = result['land'];
          final roadName = land['name'] ?? '';
          final number1 = land['number1'] ?? '';
          final number2 = land['number2'] ?? '';
          final fullNumber = number2 != '' ? '$number1-$number2' : number1;

          final buildingName = land['addition0']?['value'] ?? '';
          final roadAddr = '$area1 $area2 $roadName $fullNumber';

          return buildingName.isNotEmpty
              ? '$buildingName ($roadAddr)'
              : roadAddr;
        }
      }

      final fallback = results.firstWhere((r) => r['name'] == 'admcode', orElse: () => null);
      if (fallback != null) {
        final region = fallback['region'];
        final area1 = region['area1']['name'];
        final area2 = region['area2']['name'];
        final area3 = region['area3']['name'];
        return '$area1 $area2 $area3';
      }
    } else {
      debugPrint('API 호출 실패: ${response.statusCode}');
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFA724),
        title: const Text('위치 선택'),
      ),
      body: Stack(
        children: [
          NaverMap(
            onMapTapped: _onMapTap,
            onMapReady: (controller) {
              _mapController = controller;
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
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4),
                  ],
                ),
                child: Text(
                  selectedAddress ?? '주소를 불러오는 중...'
                      '(${selectedLatLng!.latitude.toStringAsFixed(5)}, ${selectedLatLng!.longitude.toStringAsFixed(5)})',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: selectedLatLng != null
            ? () {
          Navigator.pop(context, {
            'latitude': selectedLatLng!.latitude,
            'longitude': selectedLatLng!.longitude,
            'address': selectedAddress,
          });
        }
            : null,
        backgroundColor: selectedLatLng != null ? const Color(0xFFFFA724) : Colors.grey,
        icon: const Icon(Icons.check),
        label: const Text('위치 선택 완료'),
      ),
    );
  }
}
