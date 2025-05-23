import 'package:flutter/material.dart';
import 'package:mapmoa/schedule/shared_write.dart';
import 'package:mapmoa/schedule/memo_data.dart';

class SharedScheduleSheet extends StatelessWidget {
  const SharedScheduleSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final sharedMemos = getSharedMemos();

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
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
                '👥 공유 일정',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: SharedWritePage(
                  memos: sharedMemos,
                  onMemoTap: (index) {
                    debugPrint('공유 메모 탭: $index');
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
