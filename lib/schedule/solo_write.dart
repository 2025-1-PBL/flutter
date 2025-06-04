import 'package:flutter/material.dart';

class SoloWritePage extends StatelessWidget {
  final List<Map<String, dynamic>> memos;
  final Function(int) onMemoTap;
  final bool isSelecting;
  final Set<int> selectedIndexes;

  const SoloWritePage({
    super.key,
    required this.memos,
    required this.onMemoTap,
    required this.isSelecting,
    required this.selectedIndexes,
  });

  Color _stringToColor(dynamic color) {
    if (color is Color) return color; // 이미 Color 타입이면 그대로
    if (color is String) {
      switch (color.toLowerCase()) {
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
          return Colors.red; // 기본 색상
      }
    }
    return Colors.red; // 기본 색상
  }

  @override
  Widget build(BuildContext context) {
    if (memos.isEmpty) {
      return const Center(
        child: Text('등록된 메모가 없습니다.', style: TextStyle(fontSize: 16, color: Colors.grey)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 20, bottom: 100), //상단여백
      itemCount: memos.length,
      itemBuilder: (context, index) {
        final item = memos[index];
        final isSelected = selectedIndexes.contains(index);
        final iconColor = _stringToColor(item['color']);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 6), //좌우여백
          child: GestureDetector(
            onTap: () => onMemoTap(index),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFFF3E0) : const Color(0xFFEEEEEE),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2B1D1D).withAlpha(13),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.place, color: iconColor),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item['location'] ?? '',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      if (isSelecting)
                        Icon(
                          isSelected
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: isSelected
                              ? const Color(0xFFFFA724)
                              : Colors.grey,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item['memo'] ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
