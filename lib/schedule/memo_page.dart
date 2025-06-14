import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mapmoa/schedule/solo_write.dart';
import 'package:mapmoa/schedule/shared_write.dart';
import 'package:mapmoa/schedule/memo_write_page.dart';
import 'package:mapmoa/schedule/shared_memo_write_page.dart';
import 'package:mapmoa/widgets/custom_bottom_nav_bar.dart';
import 'package:mapmoa/api/schedule_service.dart';
import 'package:mapmoa/api/auth_service.dart';
import 'package:mapmoa/widgets/custom_schedule_button.dart';

class MemoPage extends StatefulWidget {
  const MemoPage({super.key});

  @override
  State<MemoPage> createState() => _MemoPageState();
}

class _MemoPageState extends State<MemoPage> {
  final ScheduleService _scheduleService = ScheduleService();
  final AuthService _authService = AuthService();

  bool isPersonalSelected = true;
  bool isSelecting = false;
  Set<int> selectedIndexes = {};
  String? _highlightedMenuItem;

  List<Map<String, dynamic>> _personalSchedules = [];
  List<Map<String, dynamic>> _sharedSchedules = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _checkLoginAndLoadSchedules();
  }

  Future<void> _checkLoginAndLoadSchedules() async {
    try {
      // 로그인 상태 확인
      final isLoggedIn = await _authService.isLoggedIn();
      print('앱 시작 - 로그인 상태: $isLoggedIn');

      if (!isLoggedIn) {
        print('로그인이 필요합니다. 로그인 페이지로 이동합니다.');
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
        return;
      }

      // 로그인된 경우 일정 로딩
      await _loadSchedules();
    } catch (e) {
      print('로그인 상태 확인 실패: $e');
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  Future<void> _loadSchedules() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      // 토큰 만료 확인
      final needsReLogin = await _authService.needsReLogin();
      if (needsReLogin) {
        // 로그인 페이지로 리다이렉트
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
        return;
      }

      // 현재 사용자 정보 가져오기
      final userData = await _authService.getCurrentUser();
      print(userData);
      final userId = userData['id'] as int;

      // 사용자의 모든 일정 가져오기
      final allSchedules = await _scheduleService.getAllSchedulesByUser(userId);

      // 개인 일정과 공유 일정 분리
      final personalSchedules = <Map<String, dynamic>>[];
      final sharedSchedules = <Map<String, dynamic>>[];

      for (final schedule in allSchedules) {
        final scheduleMap = {
          'id': schedule['id'],
          'memo': schedule['memo'] ?? schedule['title'] ?? '',
          'location': schedule['location'] ?? '',
          'color': schedule['color'] ?? 'blue',
          'latitude': schedule['latitude'],
          'longitude': schedule['longitude'],
          'isShared': schedule['isShared'] ?? false,
          'createdAt': schedule['createdAt'],
        };

        if (scheduleMap['isShared'] == true) {
          sharedSchedules.add(scheduleMap);
        } else {
          personalSchedules.add(scheduleMap);
        }
      }

      setState(() {
        _personalSchedules = personalSchedules;
        _sharedSchedules = sharedSchedules;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });

      // 토큰 만료 에러인 경우 로그인 페이지로 리다이렉트
      if (e.toString().contains('토큰이 만료되었습니다') ||
          e.toString().contains('다시 로그인해주세요')) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      }

      print('일정 로딩 실패: $e');
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

  Future<void> _addNewMemo() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MemoWritePage()),
    );
    if (result == true) {
      // 새 일정 추가 후 목록 새로고침
      await _loadSchedules();
    }
  }

  Future<void> _addNewSharedMemo() async {
    // 공유 일정 생성 페이지로 이동
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SharedMemoWritePage()),
    );
    if (result == true) {
      // 새 일정 추가 후 목록 새로고침
      await _loadSchedules();
    }
  }

  Future<void> _editMemo(int index) async {
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

    final currentList =
        isPersonalSelected ? _personalSchedules : _sharedSchedules;
    final currentMemo = currentList[index];

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) =>
                isPersonalSelected
                    ? MemoWritePage(
                      initialData: {
                        'id': currentMemo['id'],
                        'index': index,
                        'location': currentMemo['location'],
                        'memo': currentMemo['memo'],
                        'color': currentMemo['color'],
                        'latitude': currentMemo['latitude'],
                        'longitude': currentMemo['longitude'],
                      },
                    )
                    : SharedMemoWritePage(
                      initialData: {
                        'id': currentMemo['id'],
                        'index': index,
                        'location': currentMemo['location'],
                        'memo': currentMemo['memo'],
                        'color': currentMemo['color'],
                        'latitude': currentMemo['latitude'],
                        'longitude': currentMemo['longitude'],
                      },
                    ),
      ),
    );

    if (result == true) {
      // 일정 수정 후 목록 새로고침
      await _loadSchedules();
    }
  }

  void _toggleSelectMode() {
    final currentList =
        isPersonalSelected ? _personalSchedules : _sharedSchedules;
    if (currentList.isEmpty) {
      _showToast("삭제할 일정이 없습니다!");
      return;
    }

    setState(() {
      isSelecting = !isSelecting;
      selectedIndexes.clear();
    });
  }

  Future<void> _deleteSelected() async {
    try {
      final currentList =
          isPersonalSelected ? _personalSchedules : _sharedSchedules;
      final userData = await _authService.getCurrentUser();
      final userId = userData['id'] as int;

      for (final index in selectedIndexes) {
        if (index < currentList.length) {
          final scheduleId = currentList[index]['id'] as int;
          await _scheduleService.deleteSchedule(scheduleId, userId);
        }
      }

      setState(() {
        isSelecting = false;
        selectedIndexes.clear();
      });

      // 삭제 후 목록 새로고침
      await _loadSchedules();
      _showToast("일정이 삭제되었습니다!");
    } catch (e) {
      _showToast("일정 삭제에 실패했습니다: $e");
    }
  }

  Future<void> _deleteAll() async {
    try {
      final currentList =
          isPersonalSelected ? _personalSchedules : _sharedSchedules;
      final userData = await _authService.getCurrentUser();
      final userId = userData['id'] as int;

      for (final schedule in currentList) {
        final scheduleId = schedule['id'] as int;
        await _scheduleService.deleteSchedule(scheduleId, userId);
      }

      setState(() {
        isSelecting = false;
        selectedIndexes.clear();
      });

      // 삭제 후 목록 새로고침
      await _loadSchedules();
      _showToast("모든 일정이 삭제되었습니다!");
    } catch (e) {
      _showToast("일정 삭제에 실패했습니다: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            toolbarHeight: 80,
            leadingWidth: 0,
            titleSpacing: 0,
            title: Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.black, size: 24),
                const SizedBox(width: 8),
                Text(
                  isPersonalSelected ? '개인일정3' : '공유일정',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    Icons.person,
                    color:
                        isPersonalSelected
                            ? const Color(0xFFFFA724)
                            : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      isPersonalSelected = true;
                      isSelecting = false;
                      selectedIndexes.clear();
                    });
                  },
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: Icon(
                    Icons.groups,
                    color:
                        !isPersonalSelected
                            ? const Color(0xFFFFA724)
                            : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      isPersonalSelected = false;
                      isSelecting = false;
                      selectedIndexes.clear();
                    });
                  },
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: Colors.white,
                  onSelected: (value) {
                    setState(() {
                      _highlightedMenuItem = value;
                    });
                    if (value == 'delete_selected') {
                      _toggleSelectMode();
                    } else if (value == 'delete_all') {
                      _deleteAll();
                    }
                  },
                  itemBuilder:
                      (context) => [
                        PopupMenuItem(
                          value: 'delete_selected',
                          child: Center(
                            child: Text(
                              '삭제하기',
                              style: TextStyle(
                                color:
                                    _highlightedMenuItem == 'delete_selected'
                                        ? const Color(0xFFFF9900)
                                        : Colors.black,
                              ),
                            ),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete_all',
                          child: Center(
                            child: Text(
                              '모두삭제',
                              style: TextStyle(
                                color:
                                    _highlightedMenuItem == 'delete_all'
                                        ? const Color(0xFFFF9900)
                                        : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(40, 0, 40, 0),
        child: GestureDetector(
          onTap: () {
            if (isSelecting) {
              setState(() {
                isSelecting = false;
                selectedIndexes.clear();
              });
            }
          },
          child: Transform.translate(
            offset: const Offset(0, -18),
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
                            onPressed: _loadSchedules,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFA724),
                            ),
                            child: const Text('다시 시도'),
                          ),
                        ],
                      ),
                    )
                    : isPersonalSelected
                    ? SoloWritePage(
                      memos: _personalSchedules,
                      onMemoTap: _editMemo,
                      isSelecting: isSelecting,
                      selectedIndexes: selectedIndexes,
                    )
                    : SharedWritePage(
                      memos: _sharedSchedules,
                      onMemoTap: _editMemo,
                      isSelecting: isSelecting,
                      selectedIndexes: selectedIndexes,
                    ),
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 24, right: 40),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child:
              isSelecting
                  ? CustomScheduleButton.fromType(
                    type: ScheduleButtonType.delete,
                    enabled: selectedIndexes.isNotEmpty,
                    onTap: _deleteSelected,
                  )
                  : Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: FloatingActionButton(
                      onPressed:
                          isPersonalSelected ? _addNewMemo : _addNewSharedMemo,
                      backgroundColor: Colors.white,
                      elevation: 0,
                      shape: const CircleBorder(),
                      child: Icon(
                        isPersonalSelected ? Icons.edit : Icons.group_add,
                        color: const Color(0xFFFFA724),
                      ),
                    ),
                  ),
        ),
      ),
    );
  }
}
