import 'package:flutter/material.dart';
import 'package:mapmoa/schedule/map_select_page.dart';
import 'package:mapmoa/widgets/custom_top_nav_bar.dart';

class MemoWritePage extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  const MemoWritePage({super.key, this.initialData});

  @override
  State<MemoWritePage> createState() => _MemoWritePageState();
}

class _MemoWritePageState extends State<MemoWritePage> {
  late TextEditingController _locationController;
  late TextEditingController _memoController;
  Color _selectedColor = Colors.red;
  bool _showColorPicker = false;

  double? latitude;
  double? longitude;

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
    _locationController = TextEditingController(text: widget.initialData?['location'] ?? '');
    _memoController = TextEditingController(text: widget.initialData?['memo'] ?? '');

    final savedColor = widget.initialData?['color'];
    if (savedColor is Color) {
      _selectedColor = savedColor;
    } else if (savedColor is String) {
      _selectedColor = stringToColor(savedColor);
    }

    latitude = _parseDouble(widget.initialData?['latitude']);
    longitude = _parseDouble(widget.initialData?['longitude']);
  }

  double? _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is String) return double.tryParse(value);
    return null;
  }

  Color stringToColor(String colorStr) {
    switch (colorStr) {
      case 'red':
        return Colors.red;
      case 'orange':
        return Colors.orange;
      case 'yellow':
        return Colors.yellow;
      case 'green':
        return Colors.green;
      case 'blue':
        return Colors.blue;
      case 'purple':
        return Colors.purple;
      default:
        return Colors.blue;
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

  Future<void> _selectLocationFromMap() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MapSelectPage()),
    );

    if (result != null && result['latitude'] != null && result['longitude'] != null) {
      setState(() {
        latitude = result['latitude'];
        longitude = result['longitude'];
        _locationController.text = result['address'] ?? '선택한 위치';
      });
    }
  }

  void _submitMemo() {
    if (_locationController.text.trim().isEmpty || _memoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 100, left: 80, right: 80),
          content: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Center(
              child: Text('일정 작성을 완료해주세요.', style: TextStyle(color: Colors.white, fontSize: 14)),
            ),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final Map<String, dynamic> dataToReturn = {
      'location': _locationController.text.trim(),
      'memo': _memoController.text.trim(),
      'color': colorToString(_selectedColor),
      'latitude': latitude,
      'longitude': longitude,
    };

    Navigator.pop(context, dataToReturn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          CustomTopBar(
            title: isEditMode ? '일정 수정' : '일정 작성',
            onBack: () => Navigator.pop(context),
            rightText: isEditMode ? '수정 완료' : '완료',
            onRightPressed: _submitMemo,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  const SizedBox(height: 30),
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
                            onPressed: _selectLocationFromMap,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
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
                  if (_showColorPicker)
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: availableColors.map((color) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedColor = color;
                                _showColorPicker = false;
                              });
                            },
                            child: CircleAvatar(backgroundColor: color, radius: 12),
                          );
                        }).toList(),
                      ),
                    ),
                  const SizedBox(height: 12),
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
    );
  }
}