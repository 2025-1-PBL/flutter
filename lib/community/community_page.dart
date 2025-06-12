import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import 'write_post.dart';
import 'post_detail_screen.dart'; // 상세 페이지 import
import 'package:mapmoa/api/article_service.dart';
import 'package:mapmoa/api/auth_service.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final _articleService = ArticleService();
  final _authService = AuthService();
  List<Map<String, dynamic>> _articles = [];
  bool _isLoading = true;
  int _currentPage = 0;
  final int _pageSize = 10;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadArticles();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (!_isLoading && _hasMore) {
        _loadMoreArticles();
      }
    }
  }

  Future<void> _loadArticles() async {
    try {
      setState(() => _isLoading = true);
      final articles = await _articleService.getAllArticles(page: 0, size: _pageSize);
      setState(() {
        _articles = articles;
        _currentPage = 0;
        _hasMore = articles.length == _pageSize;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('게시글을 불러오는데 실패했습니다: $e');
    }
  }

  Future<void> _loadMoreArticles() async {
    if (_isLoading || !_hasMore) return;

    try {
      setState(() => _isLoading = true);
      final nextPage = _currentPage + 1;
      final articles = await _articleService.getAllArticles(page: nextPage, size: _pageSize);
      
      setState(() {
        _articles.addAll(articles);
        _currentPage = nextPage;
        _hasMore = articles.length == _pageSize;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('게시글을 불러오는데 실패했습니다: $e');
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

  Future<void> _addNewPost() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const WritePostScreen()),
    );
    if (result == true) {
      await _loadArticles();
    }
  }

  Future<void> _viewPostDetail(int index) async {
    final article = _articles[index];
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PostDetailScreen(article: article),
      ),
    );
    await _loadArticles(); // 댓글이나 좋아요가 변경되었을 수 있으므로 새로고침
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          '커뮤니티',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.grey),
            onPressed: _loadArticles,
          ),
        ],
      ),
      body: _isLoading && _articles.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadArticles,
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.only(bottom: 100),
                itemCount: _articles.length + (_hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _articles.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final article = _articles[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    child: GestureDetector(
                      onTap: () => _viewPostDetail(index),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
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
                                  radius: 20,
                                  backgroundColor: Colors.grey[200],
                                  backgroundImage: article['author']?['profileImage'] != null
                                      ? NetworkImage(article['author']['profileImage'])
                                      : null,
                                  child: article['author']?['profileImage'] == null
                                      ? const Icon(Icons.person, color: Colors.grey)
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        article['author']?['name'] ?? '익명',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        _formatDate(article['createdAt']),
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
                            const SizedBox(height: 12),
                            Text(
                              article['title'] ?? '',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              article['content'] ?? '',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(Icons.favorite,
                                    color: Colors.grey[400], size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  '${article['likeCount'] ?? 0}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Icon(Icons.comment,
                                    color: Colors.grey[400], size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  '${article['commentCount'] ?? 0}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewPost,
        backgroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.edit, color: Color(0xFFFFA724)),
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