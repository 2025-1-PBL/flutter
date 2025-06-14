import 'package:flutter/material.dart';
import '../widgets/custom_top_nav_bar.dart';
import '../api/article_service.dart';

class PostDetailScreen extends StatefulWidget {
  final Map<String, dynamic> post;

  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final ArticleService _articleService = ArticleService();
  bool _isLiked = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Stack(
        children: [
          // 초록색 상단 배경
          Container(height: screenHeight * 0.2, color: const Color(0xFF316954)),
          Column(
            children: [
              CustomTopBar(
                title: '게시물',
                onBack: () => Navigator.pop(context),
                backgroundColor: Colors.transparent,
                titleColor: Colors.white,
                backIconColor: Colors.white,
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(40, 30, 40, 20),
                  children: [
                    // 좋아요/조회/북마크 박스
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          const Icon(
                            Icons.remove_red_eye,
                            color: Color(0xFFFFA724),
                          ),
                          const Text('0'),
                          GestureDetector(
                            onTap: _isLoading ? null : _toggleLike,
                            child: Icon(
                              _isLiked ? Icons.favorite : Icons.favorite_border,
                              color: const Color(0xFFFFA724),
                            ),
                          ),
                          Text('${widget.post['likes'] ?? 0}'),
                          const Icon(Icons.bookmark, color: Color(0xFFFFA724)),
                          const Text('0'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 본문 박스
                    Container(
                      padding: const EdgeInsets.all(20),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '제목',
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.post['title'],
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Divider(
                            thickness: 0.5,
                            color: Color(0xFF316954),
                          ),
                          const SizedBox(height: 10),

                          const Text(
                            '위치',
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.post['location'] ?? '위치 정보 없음',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFFBDBDBD),
                            ),
                          ),
                          const SizedBox(height: 20),

                          const Text(
                            '내용',
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.post['content'] ?? '내용이 없습니다.',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // 작성자 정보
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '작성자: ${widget.post['author'] ?? '익명'}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                widget.post['date'] ?? '',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _toggleLike() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final articleId = widget.post['id'] as int;

      if (_isLiked) {
        // 좋아요 취소
        await _articleService.dislikeArticle(articleId);
      } else {
        // 좋아요 추가
        await _articleService.likeArticle(articleId);
      }

      setState(() {
        _isLiked = !_isLiked;
        widget.post['likes'] =
            (_isLiked ? 1 : -1) + (widget.post['likes'] ?? 0);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isLiked ? '좋아요를 눌렀습니다.' : '좋아요를 취소했습니다.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF4CAF50),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('좋아요 처리에 실패했습니다: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
