import 'package:flutter/material.dart';
import '../widgets/custom_top_nav_bar.dart';

class WritePostScreen extends StatefulWidget {
  const WritePostScreen({super.key});

  @override
  State<WritePostScreen> createState() => _WritePostScreenState();
}

class _WritePostScreenState extends State<WritePostScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  bool get isFormValid =>
      _titleController.text.trim().isNotEmpty &&
          _contentController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_updateState);
    _contentController.addListener(_updateState);
  }

  void _updateState() => setState(() {});

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          CustomTopBar(
            title: '게시물 작성',
            onBack: () => Navigator.pop(context),
            onAction: isFormValid ? () => Navigator.pop(context) : null,
            actionText: '작성 완료',
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: ListView(
                padding: const EdgeInsets.only(top: 32, bottom: 20),
                children: [
                  const Text('제목',
                      style: TextStyle(fontSize: 16, color: Colors.black)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2B1D1D).withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _titleController,
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                      decoration: const InputDecoration(
                        hintText: '20자 이내의 한문/영문/숫자',
                        hintStyle:
                        TextStyle(fontSize: 16, color: Color(0xFFBDBDBD)),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E0E0),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.camera_alt,
                            size: 32, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      const Text('0/10',
                          style:
                          TextStyle(fontSize: 16, color: Color(0xFFBDBDBD))),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('내용',
                      style: TextStyle(fontSize: 16, color: Colors.black)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2B1D1D).withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _contentController,
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                      maxLines: 12,
                      decoration: const InputDecoration.collapsed(
                        hintText: '내용을 입력하세요',
                        hintStyle:
                        TextStyle(fontSize: 16, color: Color(0xFFBDBDBD)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('위치',
                      style: TextStyle(fontSize: 16, color: Colors.black)),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () {
                      // 위치 설정 페이지 이동
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2B1D1D).withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('위치 설정',
                              style: TextStyle(
                                  color: Color(0xFFBDBDBD), fontSize: 16)),
                          Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}