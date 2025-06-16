import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/custom_top_nav_bar.dart';
import '../schedule/map_select_page.dart';
import '../api/article_service.dart';
import '../api/auth_service.dart';

class WritePostScreen extends StatefulWidget {
  final Map<String, dynamic>? post; // 수정할 게시글 데이터

  const WritePostScreen({super.key, this.post});

  @override
  State<WritePostScreen> createState() => _WritePostScreenState();
}

class _WritePostScreenState extends State<WritePostScreen> {
  final ArticleService _articleService = ArticleService();
  final AuthService _authService = AuthService();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<XFile> _images = [];

  String? _selectedAddress; // 위치 주소 저장 변수
  bool _isSubmitting = false;
  bool get isEditMode => widget.post != null; // 수정 모드 여부

  bool get isFormValid =>
      _titleController.text.trim().isNotEmpty &&
      _contentController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_updateState);
    _contentController.addListener(_updateState);

    // 수정 모드일 경우 기존 데이터 설정
    if (isEditMode) {
      _titleController.text = widget.post!['title'] ?? '';
      _contentController.text = widget.post!['content'] ?? '';
      _selectedAddress = widget.post!['location'];
    }
  }

  void _updateState() => setState(() {});

  Future<void> _pickImages() async {
    final List<XFile> selectedImages = await _picker.pickMultiImage(
      imageQuality: 60,
    );

    if (selectedImages.isNotEmpty) {
      setState(() {
        final newImages =
            selectedImages
                .where((img) => !_images.any((exist) => exist.path == img.path))
                .toList();
        _images.addAll(newImages);
        if (_images.length > 10) {
          _images = _images.sublist(0, 10);
        }
      });
    }
  }

  Future<void> _submitPost() async {
    if (!isFormValid) return;

    try {
      setState(() {
        _isSubmitting = true;
      });

      // 현재 사용자 정보 가져오기
      final userData = await _authService.getCurrentUser();
      final userId = userData['id'] as int;

      // 게시글 데이터 준비
      final articleData = {
        'title': _titleController.text.trim(),
        'content': _contentController.text.trim(),
        'location': _selectedAddress ?? '',
        'authorId': userId,
      };

      if (isEditMode) {
        // 게시글 수정
        await _articleService.updateArticle(widget.post!['id'], articleData);
        if (!mounted) return;
        Navigator.of(context).pop(true);
      } else {
        // 새 게시글 작성
        await _articleService.createArticle(articleData);
        if (!mounted) return;
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditMode ? '게시글 수정에 실패했습니다: $e' : '게시글 작성에 실패했습니다: $e',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

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
            title: isEditMode ? '게시물 수정' : '게시물 작성',
            onBack: () => Navigator.pop(context),
            onAction: isFormValid ? _submitPost : null,
            actionText: isEditMode ? '수정 완료' : '작성 완료',
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: ListView(
                padding: const EdgeInsets.only(top: 32, bottom: 20),
                children: [
                  const Text(
                    '제목',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: _inputDecoration(),
                    child: TextField(
                      controller: _titleController,
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                      decoration: const InputDecoration(
                        hintText: '20자 이내의 한문/영문/숫자',
                        hintStyle: TextStyle(
                          fontSize: 16,
                          color: Color(0xFFBDBDBD),
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 이미지 추가
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: _pickImages,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0E0E0),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 32,
                                color: Colors.white,
                              ),
                            ),
                            Positioned(
                              bottom: 4,
                              child: Text(
                                '${_images.length}/10',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFBDBDBD),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children:
                                _images.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final img = entry.value;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Stack(
                                      alignment: Alignment.bottomCenter,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Image.file(
                                            File(img.path),
                                            width: 72,
                                            height: 72,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        if (index == 0)
                                          Container(
                                            width: 72,
                                            height: 25,
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(
                                                0.5,
                                              ),
                                              borderRadius:
                                                  const BorderRadius.only(
                                                    bottomLeft: Radius.circular(
                                                      8,
                                                    ),
                                                    bottomRight:
                                                        Radius.circular(8),
                                                  ),
                                            ),
                                            alignment: Alignment.center,
                                            child: const Text(
                                              '대표이미지',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    '내용',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: _inputDecoration(),
                    child: TextField(
                      controller: _contentController,
                      style: const TextStyle(fontSize: 16, color: Colors.black),
                      maxLines: 12,
                      decoration: const InputDecoration.collapsed(
                        hintText: '내용을 입력하세요',
                        hintStyle: TextStyle(
                          fontSize: 16,
                          color: Color(0xFFBDBDBD),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Text(
                    '위치',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MapSelectPage(),
                        ),
                      );

                      if (result != null && result['address'] != null) {
                        setState(() {
                          _selectedAddress = result['address'];
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: _inputDecoration(),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _selectedAddress ?? '위치 설정',
                              style: TextStyle(
                                color:
                                    _selectedAddress != null
                                        ? Colors.black
                                        : const Color(0xFFBDBDBD),
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis, // ✅ 길면 말줄임
                              maxLines: 1,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.chevron_right),
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

  BoxDecoration _inputDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF2B1D1D).withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}
