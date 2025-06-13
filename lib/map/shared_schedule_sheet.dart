import 'package:flutter/material.dart';
import 'package:mapmoa/schedule/shared_write.dart';
import 'package:mapmoa/schedule/memo_data.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart'; // NLatLng 사용을 위한 import

class SharedScheduleSheet extends StatelessWidget {
  final bool showMarkers;
  final Function(bool) onToggleMarkers;
  final Function(NLatLng) onMemoTap;

  const SharedScheduleSheet({
    super.key,
    required this.showMarkers,
    required this.onToggleMarkers,
    required this.onMemoTap,
  });

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
            color: Color(0xFFF9FAFB),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Icon(Icons.drag_handle, color: Colors.grey),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '👥  공유 일정',
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
                const SizedBox(height: 12),
                Expanded(
                  child: SharedWritePage(
                    memos: sharedMemos,
                    onMemoTap: (index) {
                      final memo = sharedMemos[index];
                      debugPrint('공유 메모 탭: lat=${memo['latitude']}, lng=${memo['longitude']}, color=${memo['color']}');
                      if (memo['latitude'] is double && memo['longitude'] is double) {
                        onMemoTap(NLatLng(memo['latitude'], memo['longitude']));
                      }
                    },
                    isSelecting: false,
                    selectedIndexes: {},
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}