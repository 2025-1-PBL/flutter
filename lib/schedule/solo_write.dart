import 'package:flutter/material.dart';

class ScheduleListPage extends StatelessWidget {
  final List<Map<String, dynamic>> schedules;
  final Function(int) onScheduleTap;
  final bool isSelecting;
  final Set<int> selectedIndexes;
  final bool isShared;

  const ScheduleListPage({
    super.key,
    required this.schedules,
    required this.onScheduleTap,
    required this.isSelecting,
    required this.selectedIndexes,
    this.isShared = false,
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
    if (schedules.isEmpty) {
      return const Center(
        child: Text('등록된 일정이 없습니다.', style: TextStyle(fontSize: 16, color: Colors.grey)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: schedules.length,
      itemBuilder: (context, index) {
        final schedule = schedules[index];
        final isSelected = selectedIndexes.contains(index);
        final iconColor = _stringToColor(schedule['color']);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: GestureDetector(
            onTap: () => onScheduleTap(index),
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
                      Icon(Icons.location_on, color: iconColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          schedule['title'] ?? '제목 없음',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (isSelecting)
                        Checkbox(
                          value: isSelected,
                          onChanged: (value) => onScheduleTap(index),
                          activeColor: const Color(0xFFFFA724),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    schedule['description'] ?? '내용 없음',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  if (isShared && schedule['members'] != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.people, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '${schedule['members'].length}명 참여 중',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
