library event_list_sheet;

import 'package:flutter/material.dart';

/// ✅ 외부에서 불러올 수 있게 전역에 선언
final List<Map<String, dynamic>> dummyEvents = [
  {
    'tag': 'bhc',
    'logoUrl': 'https://example.com/bhc_logo.png',
    'title': 'BHC (비에이치씨)',
    'period': '25.03.15 ~ 25.04.10',
    'description': 'New bhc 앱 첫 주문 프로모션!\n첫 주문 시 최대 6천원 할인 (bhc App)',
    'latitude': 37.5665,
    'longitude': 126.9780,
  },
  {
    'tag': 'olive',
    'logoUrl': 'https://example.com/oliveyoung_logo.png',
    'title': 'OLIVE YOUNG (올리브영)',
    'period': '25.03.01 ~ 25.03.31',
    'description': '신학기 페스티벌\n최대 60% 품목 할인',
    'latitude': 37.5700,
    'longitude': 126.9820,
  },
];

class EventListSheet extends StatelessWidget {
  final bool showEvents;
  final Function(bool) onToggleEvents;

  const EventListSheet({
    super.key,
    this.showEvents = true,
    required this.onToggleEvents,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.3,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
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
                      '🛍️  이벤트 목록',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 10),
                    Transform.scale(
                      scale: 0.9,
                      child: Switch(
                        value: showEvents,
                        onChanged: onToggleEvents,
                        activeColor: const Color(0xFFFFA724),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  itemCount: dummyEvents.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final event = dummyEvents[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 6),
                      child: Card(
                        color: const Color(0xFFBDC3C7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                        shadowColor: Colors.orangeAccent.withOpacity(0.3),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  event['logoUrl'] ?? '',
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 70,
                                    height: 70,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.image_not_supported, size: 40),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      event['title'] ?? '',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      event['period'] ?? '',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      event['description'] ?? '',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontSize: 15,
                                        height: 1.4,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
