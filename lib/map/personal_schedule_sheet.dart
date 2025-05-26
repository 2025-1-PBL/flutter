import 'package:flutter/material.dart';
import 'package:mapmoa/schedule/solo_write.dart';
import 'package:mapmoa/schedule/memo_data.dart';

class PersonalScheduleSheet extends StatelessWidget {
  final bool showMarkers;
  final Function(bool) onToggleMarkers;

  const PersonalScheduleSheet({
    super.key,
    required this.showMarkers,
    required this.onToggleMarkers,
  });

  @override
  Widget build(BuildContext context) {
    final personalMemos = getPersonalMemos();

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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '👤 개인 일정',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 10),
                    Transform.scale(
                      scale: 0.9,
                      child: Switch(
                      value: showMarkers,
                      onChanged: onToggleMarkers,
                      activeColor: Color(0xFFFFA724),
                     ),
                    ),
                  ],
                ),
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
