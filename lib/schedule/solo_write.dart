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
    if (color is Color) return color;
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
          return Colors.red;
      }
    }
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    if (memos.isEmpty) {
      return const Center(
        child: Text(
          '등록된 메모가 없습니다.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 20, bottom: 100),
      itemCount: memos.length,
      itemBuilder: (context, index) {
        final item = memos[index];
        final isSelected = selectedIndexes.contains(index);
        final iconColor = _stringToColor(item['color']);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: GestureDetector(
            onTap: () => onMemoTap(index),
            child: Container(
              height: 80,
              margin: const EdgeInsets.symmetric(horizontal: 0),
              padding: const EdgeInsets.symmetric(horizontal: 25),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFFF59D) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.place, color: iconColor, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['location'] ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF767676),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['memo'] ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (isSelecting)
                    Icon(
                      isSelected
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color:
                      isSelected ? const Color(0xFFFFA724) : Colors.grey,
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