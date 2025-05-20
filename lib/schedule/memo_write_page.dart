import 'package:flutter/material.dart';

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
    _selectedColor = widget.initialData?['color'] ?? Colors.red;
    latitude = widget.initialData?['latitude'];
    longitude = widget.initialData?['longitude'];
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

    Navigator.pop(context, {
      'location': _locationController.text.trim(),
      'memo': _memoController.text.trim(),
      'color': _selectedColor,
      'latitude': latitude,
      'longitude': longitude,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFFA724)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditMode ? '일정 수정' : '일정 작성',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _submitMemo,
            child: Text(
              isEditMode ? '수정 완료' : '완료',
              style: const TextStyle(color: Color(0xFFFFA724), fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 장소 입력
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(Icons.place_outlined, color: _selectedColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: '장소를 입력하세요.',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showColorPicker = !_showColorPicker;
                      });
                    },
                    child: CircleAvatar(
                      backgroundColor: _selectedColor,
                      radius: 10,
                      child: const SizedBox.shrink(),
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
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)
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

            // 메모 입력
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
    );
  }
}
