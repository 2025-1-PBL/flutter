import 'package:flutter/material.dart';

class ScheduleListPage extends StatelessWidget {
  final List<Map<String, dynamic>> schedules;
  final Function(int) onScheduleTap;
  final bool isSelecting;
  final Set<int> selectedIndexes;

  const ScheduleListPage({
    super.key,
    required this.schedules,
    required this.onScheduleTap,
    this.isSelecting = false,
    this.selectedIndexes = const {},
  });

  @override
  Widget build(BuildContext context) {
    if (schedules.isEmpty) {
      return const Center(
        child: Text(
          '일정이 없습니다',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: schedules.length,
      itemBuilder: (context, index) {
        final schedule = schedules[index];
        final isSelected = selectedIndexes.contains(index);

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: InkWell(
            onTap: () => onScheduleTap(index),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color:
                      isSelected ? const Color(0xFFFFA724) : Colors.transparent,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Color(schedule['color'] ?? 0xFFFFA724),
                          shape: BoxShape.circle,
                        ),
                      ),
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
                        Icon(
                          isSelected
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          color:
                              isSelected
                                  ? const Color(0xFFFFA724)
                                  : Colors.grey,
                        ),
                    ],
                  ),
                  if (schedule['description'] != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      schedule['description'],
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                  if (schedule['location'] != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          schedule['location']['name'] ?? '위치 정보 없음',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (schedule['members'] != null &&
                      (schedule['members'] as List).isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.people, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          '${(schedule['members'] as List).length}명 참여',
                          style: const TextStyle(
                            fontSize: 14,
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
