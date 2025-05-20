import 'package:flutter/material.dart';
import 'package:mapmoa/schedule/solo_write.dart';
import 'package:mapmoa/schedule/memo_data.dart'; // ✅ 전역 메모 import

class PersonalScheduleSheet extends StatelessWidget {
  const PersonalScheduleSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final personalMemos = getPersonalMemos(); // ✅ 전역 메모 불러오기

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
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
              const Text(
                '📌 개인 일정',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: SoloWritePage(
                  memos: personalMemos,
                  onMemoTap: (index) {
                    debugPrint('개인 메모 탭: $index');
                  },
                  isSelecting: false,
                  selectedIndexes: {},
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
