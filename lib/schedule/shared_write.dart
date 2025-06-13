import 'package:flutter/material.dart';

const String defaultProfileUrl = 'https://cdn-icons-png.flaticon.com/512/847/847969.png';

Color stringToColor(dynamic color) {
  if (color is Color) return color;
  if (color is! String) return Colors.grey;

  switch (color) {
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
      return Colors.grey;
  }
}

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
      padding: const EdgeInsets.only(top: 20, bottom: 100),
      itemCount: widget.memos.length,
      itemBuilder: (context, index) {
        final item = widget.memos[index];
        final isSelected = widget.selectedIndexes.contains(index);
        final List<Map<String, dynamic>> comments = List<Map<String, dynamic>>.from(item['comments'] ?? []);
        _controllers.putIfAbsent(index, () => TextEditingController());

        final String profileUrl = item['profileUrl'] ?? defaultProfileUrl;
        final Color iconColor = stringToColor(item['color']);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: GestureDetector(
            onTap: () => widget.onMemoTap(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFFF59D) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
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
                      Icon(Icons.place, color: iconColor, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item['location'] ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF767676),
                          ),
                        ),
                      ),
                      if (widget.isSelecting)
                        Icon(
                          isSelected
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: isSelected ? const Color(0xFFFFA724) : Colors.grey,
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    item['memo'] ?? '',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const Divider(height: 10),
                  ...comments.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final comment = entry.value;
                    final String commentProfileUrl = comment['profileUrl'] ?? defaultProfileUrl;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundImage: NetworkImage(commentProfileUrl),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              comment['text'] ?? '',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                comments.removeAt(idx);
                                item['comments'] = comments;
                              });
                            },
                            child: const Icon(Icons.close, size: 20, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controllers[index],
                          style: const TextStyle(fontSize: 14),
                          decoration: const InputDecoration(
                            hintText: '댓글 입력...',
                            hintStyle: TextStyle(fontSize: 14),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 0),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF767676)),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF767676)),
                            ),
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