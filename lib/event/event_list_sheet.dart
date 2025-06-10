library event_list_sheet;

import 'package:flutter/material.dart';
import 'event_data.dart'; // ✅ 전역 이벤트 데이터를 가져오기 위해 추가

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
                  itemCount: globalEventList.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 6), // ✅ 간격 6
                  itemBuilder: (context, index) {
                    final event = globalEventList[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 0), // ✅ 간격 제거
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
