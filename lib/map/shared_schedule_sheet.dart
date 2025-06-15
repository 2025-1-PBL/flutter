import 'package:flutter/material.dart';
import 'package:mapmoa/schedule/shared_write.dart';
import 'package:mapmoa/api/schedule_service.dart';
import 'package:mapmoa/api/auth_service.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart'; // NLatLng 사용을 위한 import

class SharedScheduleSheet extends StatefulWidget {
  final bool showMarkers;
  final Function(bool) onToggleMarkers;
  final Function(NLatLng) onMemoTap;

  const SharedScheduleSheet({
    super.key,
    required this.showMarkers,
    required this.onToggleMarkers,
    required this.onMemoTap,
  });

  @override
  State<SharedScheduleSheet> createState() => _SharedScheduleSheetState();
}

class _SharedScheduleSheetState extends State<SharedScheduleSheet> {
  final ScheduleService _scheduleService = ScheduleService();
  final AuthService _authService = AuthService();

  List<Map<String, dynamic>> _sharedSchedules = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadSharedSchedules();
  }

  Future<void> _loadSharedSchedules() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      // 현재 사용자 정보 가져오기
      final userData = await _authService.getCurrentUser();
      final userId = userData['id'] as int;

      // 사용자의 모든 일정 가져오기
      final allSchedules = await _scheduleService.getAllSchedulesByUser(userId);

      // 공유 일정만 필터링 (위치 정보가 있는 것만)
      final sharedSchedules =
          allSchedules
              .where((schedule) {
                final isShared = (schedule['isShared'] ?? false) == true;
                final hasLocation =
                    schedule['latitude'] != null &&
                    schedule['longitude'] != null;
                return isShared && hasLocation;
              })
              .map((schedule) {
                final latitude = schedule['latitude'];
                final longitude = schedule['longitude'];

                return {
                  'id': schedule['id'],
                  'memo': schedule['memo'] ?? schedule['title'] ?? '',
                  'location': schedule['location'] ?? '',
                  'color': schedule['color'] ?? 'blue',
                  'latitude': latitude is int ? latitude.toDouble() : latitude,
                  'longitude':
                      longitude is int ? longitude.toDouble() : longitude,
                  'isShared': schedule['isShared'] ?? false,
                  'createdAt': schedule['createdAt'],
                };
              })
              .toList();

      setState(() {
        _sharedSchedules = sharedSchedules;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      print('공유 일정 로딩 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF9FAFB),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Icon(Icons.drag_handle, color: Colors.grey),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.groups, size: 24, color: Colors.black),
                    const SizedBox(width: 8),
                    const Text(
                      '공유 일정',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Transform.scale(
                      scale: 0.9,
                      child: Switch(
                        value: widget.showMarkers,
                        onChanged: widget.onToggleMarkers,
                        activeColor: Color(0xFFFFA724),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child:
                      _isLoading
                          ? const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFFFFA724),
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
                                  onPressed: _loadSharedSchedules,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFFA724),
                                  ),
                                  child: const Text('다시 시도'),
                                ),
                              ],
                            ),
                          )
                          : _sharedSchedules.isEmpty
                          ? const Center(
                            child: Text(
                              '등록된 공유 일정이 없습니다.',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          )
                          : SharedWritePage(
                            memos: _sharedSchedules,
                            onMemoTap: (index) {
                              final memo = _sharedSchedules[index];
                              debugPrint(
                                '공유 메모 탭: lat=${memo['latitude']}, lng=${memo['longitude']}, color=${memo['color']}',
                              );
                              if (memo['latitude'] is double &&
                                  memo['longitude'] is double) {
                                widget.onMemoTap(
                                  NLatLng(memo['latitude'], memo['longitude']),
                                );
                              }
                            },
                            isSelecting: false,
                            selectedIndexes: {},
                          ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
