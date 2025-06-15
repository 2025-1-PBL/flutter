import 'package:flutter/material.dart';
import 'package:mapmoa/schedule/map_select_page.dart';
import 'package:mapmoa/widgets/custom_top_nav_bar.dart';
import 'package:mapmoa/api/schedule_service.dart';
import 'package:mapmoa/api/auth_service.dart';

class MemoWritePage extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  const MemoWritePage({super.key, this.initialData});

  @override
  State<MemoWritePage> createState() => _MemoWritePageState();
}

class _MemoWritePageState extends State<MemoWritePage> {
  final ScheduleService _scheduleService = ScheduleService();
  final AuthService _authService = AuthService();

  late TextEditingController _locationController;
  late TextEditingController _memoController;
  Color _selectedColor = Colors.red;
  bool _showColorPicker = false;
  bool _isLoading = false;

  double? latitude;
  double? longitude;

  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  bool _dateEnabled = true;
  bool _timeEnabled = true;

  bool get isEditMode => widget.initialData != null;

  final List<Color> availableColors = [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.purple,
  ];

  @override
  void initState() {
    super.initState();
    _locationController = TextEditingController(
      text: widget.initialData?['location'] ?? '',
    );
    _memoController = TextEditingController(
      text: widget.initialData?['memo'] ?? '',
    );

    final savedColor = widget.initialData?['color'];
    if (savedColor is Color) {
      _selectedColor = savedColor;
    } else if (savedColor is String) {
      _selectedColor = stringToColor(savedColor);
    }

    latitude = _parseDouble(widget.initialData?['latitude']);
    longitude = _parseDouble(widget.initialData?['longitude']);

    _checkLoginStatus();
  }

  @override
  void dispose() {
    _locationController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  double? _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is String) return double.tryParse(value);
    return null;
  }

  Color stringToColor(String colorStr) {
    switch (colorStr) {
      case 'red': return Colors.red;
      case 'orange': return Colors.orange;
      case 'yellow': return Colors.yellow;
      case 'green': return Colors.green;
      case 'blue': return Colors.blue;
      case 'purple': return Colors.purple;
      default: return Colors.blue;
    }
  }

  String colorToString(Color color) {
    if (color == Colors.red) return 'red';
    if (color == Colors.orange) return 'orange';
    if (color == Colors.yellow) return 'yellow';
    if (color == Colors.green) return 'green';
    if (color == Colors.blue) return 'blue';
    if (color == Colors.purple) return 'purple';
    return 'blue';
  }

  String get selectedDateText {
    if (selectedDate == null) return '오늘';
    return '${selectedDate!.year}년 ${selectedDate!.month}월 ${selectedDate!.day}일';
  }

  String get selectedTimeText {
    if (selectedTime == null) return '오후 3:00';
    final hour = selectedTime!.hourOfPeriod;
    final minute = selectedTime!.minute.toString().padLeft(2, '0');
    final period = selectedTime!.period == DayPeriod.am ? '오전' : '오후';
    return '$period $hour:$minute';
  }
// 여기다
  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFFA724), // 노란색
              onPrimary: Colors.white, // 선택된 날짜 글씨 색
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? const TimeOfDay(hour: 15, minute: 0),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              dialogBackgroundColor: Colors.white,
              colorScheme: const ColorScheme.light(
                primary: Color(0xFFFFA724),
                onPrimary: Colors.black,
                onSurface: Colors.black,
              ),
              textTheme: const TextTheme(
                bodyMedium: TextStyle(color: Colors.black),
                labelLarge: TextStyle(color: Colors.black),
                titleLarge: TextStyle(color: Colors.black),
              ),
              timePickerTheme: TimePickerThemeData(
                dialHandColor: Color(0xFFFFA724),
                dialBackgroundColor: Colors.white,
                entryModeIconColor: Color(0xFFFFA724),
                dialTextColor: MaterialStateColor.resolveWith((states) => Colors.black),
                hourMinuteTextColor: Colors.black,
                hourMinuteColor: Colors.transparent,
                dayPeriodTextColor: MaterialStateColor.resolveWith((states) => Colors.black),
                dayPeriodColor: MaterialStateColor.resolveWith((states) {
                  return states.contains(MaterialState.selected)
                      ? Color(0xFFFFA724) // 선택된 AM/PM 배경
                      : Colors.transparent; // 비선택 상태는 투명
                }),
              ),
            ),
            child: child!,
          );
        }
    );
    if (picked != null) setState(() => selectedTime = picked);
  }

  Widget _buildBoxWithoutSwitch({
    required IconData icon,
    required String label,
    required String valueText,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Color(0xFFFFA724)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 14, color: Colors.black)),
                  Text(valueText, style: const TextStyle(fontSize: 14, color: Colors.black)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectLocationFromMap() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MapSelectPage()),
    );

    if (result != null &&
        result['latitude'] != null &&
        result['longitude'] != null) {
      setState(() {
        latitude = result['latitude'];
        longitude = result['longitude'];
        _locationController.text = result['address'] ?? '선택한 위치';
      });
    }
  }

  Future<void> _submitMemo() async {
    if (_locationController.text.trim().isEmpty ||
        _memoController.text.trim().isEmpty) {
      _showErrorSnackBar('일정 작성을 완료해주세요.');
      return;
    }

    if (latitude == null || longitude == null) {
      _showErrorSnackBar('위치를 선택해주세요.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
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
      print('사용자 정보 조회 시작');
      final userData = await _authService.getCurrentUser();
      print('사용자 정보 조회 성공: ${userData['id']}');
      final userId = userData['id'] as int;

      final scheduleData = {
        'title': _memoController.text.trim(),
        'memo': _memoController.text.trim(),
        'location': _locationController.text.trim(),
        'color': colorToString(_selectedColor),
        'latitude': latitude,
        'longitude': longitude,
        'isShared': false, // 기본적으로 개인 일정
        'date': _dateEnabled && selectedDate != null
            ? selectedDate!.toIso8601String()
            : null,
        'time': _timeEnabled && selectedTime != null
            ? '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}'
            : null,
      };

      if (isEditMode) {
        // 일정 수정
        final scheduleId = widget.initialData!['id'] as int;
        print('일정 수정 시작: $scheduleId');
        await _scheduleService.updateSchedule(scheduleId, userId, scheduleData);
        print('일정 수정 완료');
        _showSuccessSnackBar('일정이 수정되었습니다.');
      } else {
        // 새 일정 생성
        print('일정 생성 시작');
        await _scheduleService.createSchedule(userId, scheduleData);
        print('일정 생성 완료');
        _showSuccessSnackBar('일정이 생성되었습니다.');
      }

      Navigator.pop(context, true); // 성공 시 true 반환
    } catch (e) {
      // 토큰 만료 에러인 경우 로그인 페이지로 리다이렉트
      if (e.toString().contains('토큰이 만료되었습니다') ||
          e.toString().contains('다시 로그인해주세요')) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
        return;
      }

      print("$e");
      _showErrorSnackBar('일정 ${isEditMode ? '수정' : '생성'}에 실패했습니다: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkLoginStatus() async {
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      print('메모 작성 페이지 - 로그인 상태: $isLoggedIn');

      if (!isLoggedIn) {
        print('로그인이 필요합니다. 로그인 페이지로 이동합니다.');
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    } catch (e) {
      print('로그인 상태 확인 실패: $e');
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    _showCustomToast(message, Colors.red);
  }

  void _showSuccessSnackBar(String message) {
    _showCustomToast(message, Colors.green);
  }

  void _showCustomToast(String message, Color color) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder:
          (context) => Positioned(
            bottom: 100,
            left: 20,
            right: 20,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Center(
                  child: Text(
                    message,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ),
            ),
          ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Stack(
        children: [
          Column(
            children: [
              CustomTopBar(
                title: isEditMode ? '일정 수정' : '일정 작성',
                onBack: () => Navigator.pop(context),
                rightText: isEditMode ? '수정 완료' : '완료',
                onRightPressed: _isLoading ? null : _submitMemo,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      const SizedBox(height: 30),

                      _buildBoxWithoutSwitch(
                        icon: Icons.calendar_today,
                        label: '날짜',
                        valueText: selectedDateText,
                        onTap: () => _pickDate(context),
                      ),

                      const SizedBox(height: 12),

                      _buildBoxWithoutSwitch(
                        icon: Icons.access_time,
                        label: '시간',
                        valueText: selectedTimeText,
                        onTap: () => _pickTime(context),
                      ),

                      const SizedBox(height: 12),

                      // ✅ 장소 입력 박스
                      Container(
                        height: 60,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.place_outlined, color: _selectedColor),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _locationController,
                                readOnly: true,
                                style: const TextStyle(fontSize: 16),
                                decoration: const InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(vertical: 0),
                                  border: InputBorder.none,
                                  hintText: '장소를 선택하세요.',
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: IconButton(
                                icon: const Icon(Icons.map, color: Color(0xFFFFA724)),
                                onPressed: _isLoading ? null : _selectLocationFromMap,
                              ),
                            ),
                            GestureDetector(
                              onTap: _isLoading
                                  ? null
                                  : () {
                                setState(() {
                                  _showColorPicker = !_showColorPicker;
                                });
                              },
                              child: CircleAvatar(
                                backgroundColor: _selectedColor,
                                radius: 10,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 🎨 색상 선택 박스
                      if (_showColorPicker)
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: availableColors.map((color) {
                              return GestureDetector(
                                onTap: _isLoading
                                    ? null
                                    : () {
                                  setState(() {
                                    _selectedColor = color;
                                    _showColorPicker = false;
                                  });
                                },
                                child: CircleAvatar(
                                  backgroundColor: color,
                                  radius: 12,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      const SizedBox(height: 12),

                      // ✅ 메모 입력 박스
                      Container(
                        height: 60,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.note_outlined, color: Color(0xFFFFA724)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: _memoController,
                                maxLines: null,
                                enabled: !_isLoading,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: '메모를 입력하세요.',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFFFFA724)),
              ),
            ),
        ],
      ),
    );
  }
}
