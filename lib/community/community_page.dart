import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../api/article_service.dart';
import '../api/auth_service.dart';
import 'write_post.dart';
import 'post_detail_screen.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final ArticleService _articleService = ArticleService();
  final AuthService _authService = AuthService();

  bool isCardView = true;
  String selectedSort = '최신순';
  bool isFabPressed = false;
  bool _isLoading = true;
  String _errorMessage = '';
  String _userName = '사용자'; // 사용자 이름 저장 변수

  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> posts = [];
  List<Map<String, dynamic>> filteredPosts = [];

  Color get fabColor =>
      isFabPressed ? const Color(0xFFFFA724) : const Color(0xFF316954);

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadArticles();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadUserInfo() async {
    try {
      final userData = await _authService.getCurrentUser();
      setState(() {
        _userName = userData['name'] ?? '사용자';
      });
    } catch (e) {
      print('사용자 정보 로딩 실패: $e');
      // 에러가 발생해도 기본값 사용
    }
  }

  Future<void> _loadArticles() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      // 모든 게시글 가져오기
      final response = await _articleService.getAllArticles(page: 0, size: 50);
      final articles = response['content'] as List<dynamic>;

      // 데이터 형식 변환
      final convertedPosts =
          articles.map((article) {
            final createdAt = article['createdAt'] ?? '';
            String formattedDate = '';

            if (createdAt is String && createdAt.isNotEmpty) {
              try {
                final date = DateTime.parse(createdAt);
                formattedDate =
                    '${date.year.toString().substring(2)}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
              } catch (e) {
                formattedDate = createdAt;
              }
            }

            return {
              'id': article['id'],
              'title': article['title'] ?? '',
              'content': article['content'] ?? '',
              'location': article['location'] ?? '',
              'likes': article['likeCount'] ?? 0,
              'date': formattedDate,
              'author': article['author'] ?? '',
              'createdAt': article['createdAt'],
            };
          }).toList();

      setState(() {
        posts = convertedPosts;
        filteredPosts = convertedPosts;
        _isLoading = false;
      });

      // 정렬 적용
      _onSortChanged(selectedSort);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      print('게시글 로딩 실패: $e');

      // 사용자에게 더 명확한 메시지 표시
      if (mounted) {
        String userMessage = '게시글을 불러오는데 실패했습니다.';

        if (e.toString().contains('서버 내부 오류')) {
          userMessage = '서버에 일시적인 문제가 발생했습니다. 잠시 후 다시 시도해주세요.';
        } else if (e.toString().contains('토큰이 만료')) {
          userMessage = '로그인이 만료되었습니다. 다시 로그인해주세요.';
        } else if (e.toString().contains('500')) {
          userMessage = '서버 오류가 발생했습니다. 백엔드 개발팀에 문의해주세요.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userMessage),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _onSearchChanged() async {
    String searchText = _searchController.text.trim();

    if (searchText.isEmpty) {
      // 검색어가 없으면 전체 목록 표시
      setState(() {
        filteredPosts = posts;
      });
      _onSortChanged(selectedSort);
    } else {
      // 검색어가 있으면 API로 검색
      try {
        setState(() {
          _isLoading = true;
        });

        final response = await _articleService.searchArticlesByTitle(
          searchText,
          page: 0,
          size: 50,
        );
        final articles = response['content'] as List<dynamic>;

        final searchResults =
            articles.map((article) {
              final createdAt = article['createdAt'] ?? '';
              String formattedDate = '';

              if (createdAt is String && createdAt.isNotEmpty) {
                try {
                  final date = DateTime.parse(createdAt);
                  formattedDate =
                      '${date.year.toString().substring(2)}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
                } catch (e) {
                  formattedDate = createdAt;
                }
              }

              return {
                'id': article['id'],
                'title': article['title'] ?? '',
                'content': article['content'] ?? '',
                'location': article['location'] ?? '',
                'likes': article['likeCount'] ?? 0,
                'date': formattedDate,
                'author': article['author'] ?? '',
                'createdAt': article['createdAt'],
              };
            }).toList();

        setState(() {
          filteredPosts = searchResults;
          _isLoading = false;
        });

        _onSortChanged(selectedSort);
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        print('검색 실패: $e');
      }
    }
  }

  void _onSortChanged(String sort) {
    setState(() {
      selectedSort = sort;
      if (sort == '최신순') {
        filteredPosts.sort((a, b) {
          final dateA = a['createdAt'] ?? '';
          final dateB = b['createdAt'] ?? '';
          if (dateA is String && dateB is String) {
            try {
              final dateTimeA = DateTime.parse(dateA);
              final dateTimeB = DateTime.parse(dateB);
              return dateTimeB.compareTo(dateTimeA);
            } catch (e) {
              return dateB.compareTo(dateA);
            }
          }
          return 0;
        });
      } else if (sort == '좋아요순') {
        filteredPosts.sort((a, b) {
          final likesA = a['likes'] ?? 0;
          final likesB = b['likes'] ?? 0;
          return (likesB as int).compareTo(likesA as int);
        });
      } else if (sort == '거리순') {
        filteredPosts.sort((a, b) {
          final locationA = a['location'] ?? '';
          final locationB = b['location'] ?? '';
          return locationA.compareTo(locationB);
        });
      }
    });
  }

  // 새로고침 기능
  Future<void> _refreshData() async {
    await _loadArticles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            const SizedBox(height: 25),
            _buildSearchBar(),
            const SizedBox(height: 20),
            _buildTraceCard(),
            const SizedBox(height: 20),
            _buildSortButtons(),
            const SizedBox(height: 5),
            const SizedBox(height: 5),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(color: Color(0xFFFFA724)),
                ),
              )
            else if (_errorMessage.isNotEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        '데이터를 불러오는데 실패했습니다',
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _loadArticles,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFA724),
                        ),
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                ),
              )
            else if (filteredPosts.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    '게시글이 없습니다.',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ),
              )
            else
              _buildVerticalCategoryList(),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 24, right: 40),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: () async {
              setState(() => isFabPressed = true);
              await Future.delayed(const Duration(milliseconds: 300));
              if (!mounted) return;
              setState(() => isFabPressed = false);
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WritePostScreen()),
              );

              // 게시글 작성 후 새로고침
              if (mounted && result == true) {
                await _loadArticles();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('게시글이 작성되었습니다.'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Color(0xFF4CAF50),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            backgroundColor: fabColor,
            elevation: 0,
            shape: const CircleBorder(),
            child: const Icon(Icons.edit, color: Colors.white),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 3),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF316954), width: 2)),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search, color: Color(0xFF316954)),
          hintText: '',
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          filled: false,
          fillColor: Colors.transparent,
        ),
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildTraceCard() => Container(
    height: 42,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF2B1D1D).withAlpha(13),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text('$_userName 님의 흔적을 확인하세요'),
          const Spacer(),
          const Icon(Icons.person, size: 28),
          const SizedBox(width: 12),
          const Icon(Icons.favorite, size: 25),
          const SizedBox(width: 12),
          const Icon(Icons.bookmark, size: 25),
        ],
      ),
    ),
  );

  Widget _buildSortButtons() {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2B1D1D).withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children:
            ['최신순', '좋아요순', '거리순'].map((sort) {
              final isSelected = selectedSort == sort;
              return GestureDetector(
                onTap: () => _onSortChanged(sort),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    sort,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color:
                          isSelected ? const Color(0xFFFFA724) : Colors.black87,
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildHorizontalCardList() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: SizedBox(
      height: 360,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: filteredPosts.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final post = filteredPosts[index];
          final isLast = index == filteredPosts.length - 1;

          return Container(
            width: 250,
            margin: EdgeInsets.only(
              left: index == 0 ? 0 : 10,
              right: isLast ? 40 : 0,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PostDetailScreen(post: post),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 170,
                    decoration: BoxDecoration(
                      color: const Color(0xFF316954),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              post['date'],
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  size: 20,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  post['location'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          post['title'],
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const Icon(
                              Icons.favorite,
                              size: 20,
                              color: Color(0xFFFFA724),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${post['likes']}',
                              style: const TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),
  );

  Widget _buildVerticalCategoryList() => ListView.separated(
    physics: const NeverScrollableScrollPhysics(),
    shrinkWrap: true,
    itemCount: filteredPosts.length,
    separatorBuilder:
        (context, index) =>
            const Divider(thickness: 0.5, color: Color(0xFFE0E0E0)),
    itemBuilder: (context, index) {
      final post = filteredPosts[index];
      return InkWell(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PostDetailScreen(post: post)),
          );

          // 게시물이 삭제되었거나 수정되었다면 목록 새로고침
          if (result == true) {
            await _loadArticles();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('게시글이 수정되었습니다.'),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Color(0xFF4CAF50),
                duration: Duration(seconds: 2),
              ),
            );
          } else if (result != null && result['deleted'] == true) {
            setState(() {
              final deletedId = result['articleId'];
              posts.removeWhere((p) => p['id'] == deletedId);
              filteredPosts.removeWhere((p) => p['id'] == deletedId);
            });
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post['title'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      post['location'],
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: const [
                  Icon(Icons.favorite, color: Color(0xFF316954), size: 20),
                  SizedBox(height: 8),
                  Icon(Icons.bookmark, color: Color(0xFF316954), size: 20),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
