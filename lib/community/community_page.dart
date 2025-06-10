import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import 'write_post.dart';
import 'post_detail_screen.dart'; // 상세 페이지 import

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  bool isCardView = true;
  String selectedSort = '최신순';
  bool isFabPressed = false;

  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> posts = [
    {'title': '[스타벅스] 3월 한 달간 30% 할인', 'location': '가좌동', 'likes': 4, 'date': '25.03.27'},
    {'title': '[올리브영] 새학기 학생들을 위한 20% 할인', 'location': '가좌동', 'likes': 3, 'date': '25.03.28'},
    {'title': '[배스킨라빈스] 봄 시즌 아이스크림 할인', 'location': '가좌동', 'likes': 2, 'date': '25.03.29'},
    {'title': '[OG버거] 개강 기념 블랙페퍼 버거 할인', 'location': '가좌동', 'likes': 1, 'date': '25.03.30'},
  ];

  List<Map<String, dynamic>> filteredPosts = [];

  Color get fabColor => isFabPressed ? const Color(0xFFFFA724) : const Color(0xFF316954);

  @override
  void initState() {
    super.initState();
    filteredPosts = posts;
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    String searchText = _searchController.text.toLowerCase();
    setState(() {
      filteredPosts = posts.where((post) {
        return post['title'].toLowerCase().contains(searchText) ||
            post['location'].toLowerCase().contains(searchText);
      }).toList();
    });
  }

  void _onSortChanged(String sort) {
    setState(() {
      selectedSort = sort;
      if (sort == '최신순') {
        filteredPosts.sort((a, b) => b['date'].compareTo(a['date']));
      } else if (sort == '좋아요순') {
        filteredPosts.sort((a, b) => b['likes'].compareTo(a['likes']));
      } else if (sort == '거리순') {
        filteredPosts.sort((a, b) => a['location'].compareTo(b['location']));
      }
    });
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
            const SizedBox(height: 20),
            Row(
              children: [
                TextButton(
                  onPressed: () => setState(() => isCardView = true),
                  child: Text('카드 형식',
                      style: TextStyle(
                          color: isCardView ? const Color(0xFFFFA724) : Colors.grey,
                          fontSize: 16)),
                ),
                const Text('|'),
                TextButton(
                  onPressed: () => setState(() => isCardView = false),
                  child: Text('카테고리 형식',
                      style: TextStyle(
                          color: !isCardView ? const Color(0xFFFFA724) : Colors.grey,
                          fontSize: 16)),
                ),
              ],
            ),
            const Divider(height: 1, thickness: 1),
            const SizedBox(height: 20),
            isCardView ? _buildHorizontalCardList() : _buildVerticalCategoryList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          setState(() => isFabPressed = true);
          await Future.delayed(const Duration(milliseconds: 300));
          if (!mounted) return;
          setState(() => isFabPressed = false);

          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WritePostScreen()),
          );
        },
        backgroundColor: fabColor,
        shape: const CircleBorder(),
        child: const Icon(Icons.edit, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 3),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFF316954), // 상단 녹색 라인
            width: 2,
          ),
        ),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search, color: Color(0xFF316954)),
          hintText: '',
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
    height: 40,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF2B1D1D).withAlpha(13),
          blurRadius: 8,
          offset: const Offset(0, 2),
        )
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: const [
          Text('심슨 님의 흔적을 확인하세요'),
          Spacer(),
          Icon(Icons.person, size: 20),
          SizedBox(width: 12),
          Icon(Icons.favorite, size: 20),
          SizedBox(width: 12),
          Icon(Icons.bookmark, size: 20),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: ['최신순', '좋아요순', '거리순'].map((sort) {
          final isSelected = selectedSort == sort;
          return Expanded(
            child: GestureDetector(
              onTap: () => _onSortChanged(sort),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF2B1D1D).withAlpha(13)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Center(
                  child: Text(
                    sort,
                    style: TextStyle(
                      color: isSelected ? const Color(0xFFFFA724) : Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
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
                          top: Radius.circular(20)),
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
                            Text(post['date'],
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.grey)),
                            Row(
                              children: [
                                const Icon(Icons.location_on,
                                    size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(post['location'],
                                    style: const TextStyle(
                                        fontSize: 16, color: Colors.grey)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(post['title'],
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const Icon(Icons.favorite,
                                size: 20, color: Color(0xFFFFA724)),
                            const SizedBox(width: 4),
                            Text('${post['likes']}',
                                style: const TextStyle(fontSize: 20)),
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
    separatorBuilder: (context, index) => const Divider(thickness: 0.5, color: Color(0xFFE0E0E0)),
    itemBuilder: (context, index) {
      final post = filteredPosts[index];
      return InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PostDetailScreen(post: post),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 게시글 정보 (제목 + 위치)
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
              // 좋아요 / 북마크 아이콘
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