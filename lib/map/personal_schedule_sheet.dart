import 'package:flutter/material.dart';
import 'package:mapmoa/schedule/solo_write.dart';
import 'package:mapmoa/schedule/memo_data.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart'; // NLatLng 타입 사용 위해 import

class PersonalScheduleSheet extends StatelessWidget {
  final bool showMarkers;
  final Function(bool) onToggleMarkers;
  final Function(NLatLng) onMemoTap;  // 추가: 위치 전달 콜백

  const PersonalScheduleSheet({
    super.key,
    required this.showMarkers,
    required this.onToggleMarkers,
    required this.onMemoTap,  // 필수 파라미터로 추가
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
                        activeColor: const Color(0xFFFFA724),
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
                    final memo = personalMemos[index];
                    // 좌표와 색상 로그 찍기 (디버그)
                    debugPrint('Tapped memo: lat=${memo['latitude']}, lng=${memo['longitude']}, color=${memo['color']}');
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
        );
      },
    );
  }
}
