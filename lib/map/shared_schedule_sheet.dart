import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:mapmoa/api/shared_schedule_service.dart';
import 'package:mapmoa/api/auth_service.dart';
import 'package:mapmoa/schedule/schedule_list.dart';

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
  final _sharedScheduleService = SharedScheduleService();
  final _authService = AuthService();
  List<Map<String, dynamic>> _schedules = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) return;

      final schedules = await _sharedScheduleService.getSharedSchedulesForUser(
        currentUser['id'],
      );
      setState(() {
        _schedules = List<Map<String, dynamic>>.from(schedules);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('일정을 불러오는데 실패했습니다: $e');
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
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Icon(Icons.drag_handle, color: Colors.grey),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '👥 공유 일정',
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
                        activeColor: const Color(0xFFFFA724),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child:
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : RefreshIndicator(
                          onRefresh: _loadSchedules,
                          child: ScheduleListPage(
                            schedules: _schedules,
                            onScheduleTap: (index) {
                              final schedule = _schedules[index];
                              if (schedule['location'] != null) {
                                final location = schedule['location'];
                                widget.onMemoTap(
                                  NLatLng(
                                    location['latitude'],
                                    location['longitude'],
                                  ),
                                );
                              }
                            },
                            isSelecting: false,
                            selectedIndexes: {},
                          ),
                        ),
              ),
            ],
          ),
        );
      },
    );
  }
}
