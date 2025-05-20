import 'package:flutter/material.dart';

const String defaultProfileUrl = 'https://cdn-icons-png.flaticon.com/512/847/847969.png';

class SharedWritePage extends StatefulWidget {
  final List<Map<String, dynamic>> memos;
  final Function(int) onMemoTap;
  final bool isSelecting;
  final Set<int> selectedIndexes;

  const SharedWritePage({
    super.key,
    required this.memos,
    required this.onMemoTap,
    required this.isSelecting,
    required this.selectedIndexes,
  });

  @override
  State<SharedWritePage> createState() => _SharedWritePageState();
}

class _SharedWritePageState extends State<SharedWritePage> {
  final Map<int, TextEditingController> _controllers = {};

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.memos.isEmpty) {
      return const Center(
        child: Text('등록된 메모가 없습니다.', style: TextStyle(fontSize: 16, color: Colors.grey)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: widget.memos.length,
      itemBuilder: (context, index) {
        final item = widget.memos[index];
        final isSelected = widget.selectedIndexes.contains(index);
        final List<Map<String, dynamic>> comments = List<Map<String, dynamic>>.from(item['comments'] ?? []);

        _controllers.putIfAbsent(index, () => TextEditingController());

        final String profileUrl = item['profileUrl'] ?? defaultProfileUrl;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: GestureDetector(
            onTap: () => widget.onMemoTap(index),
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
                      CircleAvatar(
                        radius: 16,
                        backgroundImage: NetworkImage(profileUrl),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.place, color: item['color'] ?? Colors.red),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item['location'] ?? '',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      if (widget.isSelecting)
                        Icon(
                          isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                          color: isSelected ? const Color(0xFFFFA724) : Colors.grey,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item['memo'] ?? '',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const Divider(height: 30),
                  ...comments.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final comment = entry.value;
                    final String commentProfileUrl = comment['profileUrl'] ?? defaultProfileUrl;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundImage: NetworkImage(commentProfileUrl),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              comment['text'] ?? '',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                comments.removeAt(idx);
                                item['comments'] = comments;
                              });
                            },
                            child: const Icon(Icons.close, size: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controllers[index],
                          decoration: const InputDecoration(
                            hintText: '댓글 입력...',
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, size: 20, color: Color(0xFFFFA724)),
                        onPressed: () {
                          final text = _controllers[index]?.text.trim();
                          if (text != null && text.isNotEmpty) {
                            setState(() {
                              comments.add({
                                'text': text,
                                'profileUrl': defaultProfileUrl,
                              });
                              item['comments'] = comments;
                              _controllers[index]?.clear();
                            });
                          }
                        },
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
