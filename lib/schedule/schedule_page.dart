import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mapmoa/schedule/schedule_list.dart';
import 'package:mapmoa/schedule/schedule_write_page.dart';
import 'package:mapmoa/widgets/custom_bottom_nav_bar.dart';
import 'package:mapmoa/api/schedule_service.dart';
import 'package:mapmoa/api/auth_service.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  bool isPersonalSelected = true;
  bool isSelecting = false;
  Set<int> selectedIndexes = {};
  final _scheduleService = ScheduleService();
  final _authService = AuthService();
  List<Map<String, dynamic>> _personalSchedules = [];
  List<Map<String, dynamic>> _sharedSchedules = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    try {
      setState(() => _isLoading = true);

      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('사용자 정보를 가져올 수 없습니다.');
      }

      final schedules = await _scheduleService.getAllSchedulesByUser(
        currentUser['id'],
      );

      setState(() {
        _personalSchedules = List<Map<String, dynamic>>.from(
          schedules.where((schedule) => !schedule['isShared']).toList(),
        );
        _sharedSchedules = List<Map<String, dynamic>>.from(
          schedules.where((schedule) => schedule['isShared']).toList(),
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showToast('일정을 불러오는데 실패했습니다: $e');
    }
  }

  void _showToast(String message) {
    Fluttertoast.cancel();
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: const Color(0xFF333333),
      textColor: Colors.white,
      fontSize: 14,
    );
  }

  Future<void> _addNewSchedule() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ScheduleWritePage()),
    );
    if (result != null) {
      await _loadSchedules();
    }
  }

  Future<void> _editSchedule(int index) async {
    if (isSelecting) {
      setState(() {
        if (selectedIndexes.contains(index)) {
          selectedIndexes.remove(index);
        } else {
          selectedIndexes.add(index);
        }
      });
      return;
    }

    final currentSchedule =
        isPersonalSelected
            ? _personalSchedules[index]
            : _sharedSchedules[index];

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => ScheduleWritePage(
              initialData: {
                'id': currentSchedule['id'],
                'title': currentSchedule['title'],
                'description': currentSchedule['description'],
                'color': currentSchedule['color'],
                'location': currentSchedule['location'],
              },
            ),
      ),
    );

    if (result != null) {
      await _loadSchedules();
    }
  }

  void _toggleSelectMode() {
    setState(() {
      isSelecting = !isSelecting;
      selectedIndexes.clear();
    });
  }

  Future<void> _deleteSelected() async {
    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('사용자 정보를 가져올 수 없습니다.');
      }

      final schedulesToDelete =
          isPersonalSelected ? _personalSchedules : _sharedSchedules;
      for (final index in selectedIndexes) {
        await _scheduleService.deleteSchedule(
          schedulesToDelete[index]['id'],
          currentUser['id'],
        );
      }

      setState(() {
        isSelecting = false;
        selectedIndexes.clear();
      });

      await _loadSchedules();
      _showToast("선택한 일정이 삭제되었습니다!");
    } catch (e) {
      _showToast('일정 삭제에 실패했습니다: $e');
    }
  }

  Future<void> _deleteAll() async {
    try {
      final currentUser = await _authService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('사용자 정보를 가져올 수 없습니다.');
      }

      final schedulesToDelete =
          isPersonalSelected ? _personalSchedules : _sharedSchedules;
      for (final schedule in schedulesToDelete) {
        await _scheduleService.deleteSchedule(
          schedule['id'],
          currentUser['id'],
        );
      }

      setState(() {
        isSelecting = false;
        selectedIndexes.clear();
      });

      await _loadSchedules();
      _showToast("모든 일정이 삭제되었습니다!");
    } catch (e) {
      _showToast('일정 삭제에 실패했습니다: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final schedules =
        isPersonalSelected ? _personalSchedules : _sharedSchedules;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 0,
        titleSpacing: 20,
        title: Row(
          children: [
            const Icon(Icons.calendar_today, color: Colors.black, size: 24),
            const SizedBox(width: 8),
            Text(
              isPersonalSelected ? '개인일정' : '공유일정',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isSelecting)
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.grey),
                    onPressed: _loadSchedules,
                  ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  onSelected: (value) {
                    if (value == 'delete_selected') {
                      _toggleSelectMode();
                    } else if (value == 'delete_all') {
                      _deleteAll();
                    }
                  },
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(
                          value: 'delete_selected',
                          child: Center(child: Text('삭제하기')),
                        ),
                        const PopupMenuItem(
                          value: 'delete_all',
                          child: Center(child: Text('모두삭제')),
                        ),
                      ],
                ),
              ],
            ),
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : GestureDetector(
                onTap: () {
                  if (isSelecting) {
                    setState(() {
                      isSelecting = false;
                      selectedIndexes.clear();
                    });
                  }
                },
                child: ScheduleListPage(
                  schedules: schedules,
                  onScheduleTap: _editSchedule,
                  isSelecting: isSelecting,
                  selectedIndexes: selectedIndexes,
                ),
              ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
      floatingActionButton: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child:
            isSelecting
                ? Padding(
                  padding: const EdgeInsets.only(bottom: 24, right: 16),
                  child: FloatingActionButton.extended(
                    onPressed: selectedIndexes.isEmpty ? null : _deleteSelected,
                    backgroundColor:
                        selectedIndexes.isEmpty
                            ? Colors.grey
                            : const Color(0xFFFFA724),
                    label: const Text(
                      '삭제',
                      style: TextStyle(color: Colors.white),
                    ),
                    icon: const Icon(Icons.delete, color: Colors.white),
                  ),
                )
                : Padding(
                  padding: const EdgeInsets.only(bottom: 24, right: 16),
                  child: FloatingActionButton(
                    onPressed: _addNewSchedule,
                    backgroundColor: Colors.white,
                    shape: const CircleBorder(),
                    child: const Icon(Icons.edit, color: Color(0xFFFFA724)),
                  ),
                ),
      ),
    );
  }
}
