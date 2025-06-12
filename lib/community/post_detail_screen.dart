import 'package:flutter/material.dart';
import 'package:mapmoa/api/article_service.dart';
import 'package:mapmoa/api/comment_service.dart';
import 'package:mapmoa/api/auth_service.dart';

class PostDetailScreen extends StatefulWidget {
  final Map<String, dynamic> article;

  const PostDetailScreen({super.key, required this.article});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final _commentController = TextEditingController();
  final _articleService = ArticleService();
  final _commentService = CommentService();
  final _authService = AuthService();
  List<Map<String, dynamic>> _comments = [];
  bool _isLoading = false;
  bool _isLiked = false;
  int _likeCount = 0;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.article['isLiked'] ?? false;
    _likeCount = widget.article['likeCount'] ?? 0;
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    try {
      setState(() => _isLoading = true);
      final comments = await _commentService.getCommentsByArticleId(widget.article['id']);
      setState(() {
        _comments = comments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('댓글을 불러오는데 실패했습니다: $e');
    }
  }

  Future<void> _toggleLike() async {
    try {
      if (_isLiked) {
        await _articleService.unlikeArticle(widget.article['id']);
        setState(() {
          _isLiked = false;
          _likeCount--;
        });
      } else {
        await _articleService.likeArticle(widget.article['id']);
        setState(() {
          _isLiked = true;
          _likeCount++;
        });
      }
    } catch (e) {
      _showSnackBar('좋아요 처리에 실패했습니다: $e');
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.isEmpty) return;

    try {
      setState(() => _isLoading = true);
      await _commentService.createComment(
        articleId: widget.article['id'],
        content: _commentController.text,
      );
      _commentController.clear();
      await _loadComments();
    } catch (e) {
      _showSnackBar('댓글 작성에 실패했습니다: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteComment(int commentId) async {
    try {
      await _commentService.deleteComment(commentId);
      await _loadComments();
    } catch (e) {
      _showSnackBar('댓글 삭제에 실패했습니다: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          '게시글',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      // 작성자 정보
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: widget.article['author']?['profileImage'] != null
                                ? NetworkImage(widget.article['author']['profileImage'])
                                : null,
                            child: widget.article['author']?['profileImage'] == null
                                ? const Icon(Icons.person, color: Colors.grey)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.article['author']?['name'] ?? '익명',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  _formatDate(widget.article['createdAt']),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // 게시글 내용
                      Text(
                        widget.article['title'] ?? '',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.article['content'] ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 좋아요 버튼
                      Row(
                        children: [
                          IconButton(
                            onPressed: _toggleLike,
                            icon: Icon(
                              _isLiked ? Icons.favorite : Icons.favorite_border,
                              color: _isLiked ? const Color(0xFFFFA724) : Colors.grey,
                            ),
                          ),
                          Text(
                            '$_likeCount',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 32),

                      // 댓글 목록
                      const Text(
                        '댓글',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ..._comments.map((comment) => _buildCommentItem(comment)),
                    ],
                  ),
                ),

                // 댓글 입력
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: const InputDecoration(
                            hintText: '댓글을 입력하세요',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _isLoading ? null : _addComment,
                        icon: const Icon(Icons.send, color: Color(0xFFFFA724)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCommentItem(Map<String, dynamic> comment) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.grey[200],
            backgroundImage: comment['author']?['profileImage'] != null
                ? NetworkImage(comment['author']['profileImage'])
                : null,
            child: comment['author']?['profileImage'] == null
                ? const Icon(Icons.person, color: Colors.grey, size: 16)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment['author']?['name'] ?? '익명',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(comment['createdAt']),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment['content'] ?? '',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          if (comment['author']?['id'] == _authService.getCurrentUser()?['id'])
            IconButton(
              onPressed: () => _deleteComment(comment['id']),
              icon: const Icon(Icons.delete_outline, size: 16),
              color: Colors.grey,
            ),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    final date = DateTime.parse(dateStr);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}일 전';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }
}