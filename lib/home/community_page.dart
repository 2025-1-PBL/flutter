import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({Key? key}) : super(key: key);

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  bool isCardView = true;
  String selectedSort = '최신순';

  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> posts = [
    {'title': '[스타벅스] 3월 한 달간 30% 할인', 'location': '가좌동', 'likes': 4, 'date': '25.03.27'},
    {'title': '[올리브영] 새학기 학생들을 위한 20% 할인', 'location': '가좌동', 'likes': 3, 'date': '25.03.28'},
    {'title': '[배스킨라빈스] 봄 시즌 아이스크림 할인', 'location': '가좌동', 'likes': 2, 'date': '25.03.29'},
    {'title': '[OG버거] 개강 기념 블랙페퍼 버거 할인', 'location': '가좌동', 'likes': 1, 'date': '25.03.30'},
  ];

  List<Map<String, dynamic>> filteredPosts = [];

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

  void _showSortPopup() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        backgroundColor: Color(0xFFF9FAFB),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SizedBox(
          width: 390,
          height: 200,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 42),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('정렬 기준', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 12,
                    runSpacing: 12,
                    children: ['최신순', '좋아요순', '거리순'].map((sort) {
                      return GestureDetector(
                        onTap: () {
                          _onSortChanged(sort);
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2B1D1D).withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            sort,
                            style: TextStyle(
                              color: selectedSort == sort ? const Color(0xFFFFA724) : Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
            const SizedBox(height: 60),
            _buildSearchBar(),
            const SizedBox(height: 16),
            _buildTraceCard(),
            const SizedBox(height: 16),
            _buildSortButtons(),
            const SizedBox(height: 16),
            Row(
              children: [
                TextButton(
                  onPressed: () => setState(() => isCardView = true),
                  child: Text('카드 형식', style: TextStyle(color: isCardView ? const Color(0xFFFFA724) : Colors.grey, fontSize: 18)),
                ),
                const Text('|'),
                TextButton(
                  onPressed: () => setState(() => isCardView = false),
                  child: Text('카테고리 형식', style: TextStyle(color: !isCardView ? const Color(0xFFFFA724) : Colors.grey, fontSize: 18)),
                ),
              ],
            ),
            const Divider(height: 1, thickness: 1),
            const SizedBox(height: 30),
            isCardView ? _buildHorizontalCardList() : _buildVerticalCategoryList(),
          ],
        ),
      ),
      floatingActionButton: Transform.translate(
        offset: const Offset(-60, -15), // 왼쪽(-X), 위쪽(-Y)으로 이동
        child: FloatingActionButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WritePostScreen())),
          backgroundColor: const Color(0xFF316954),
          shape: const CircleBorder(),
          child: const Icon(Icons.edit, color: Colors.white),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 3),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      width: 350,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2B1D1D).withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search, color: Color(0xFFBDBDBD)),
          hintText: '검색어를 입력하세요.',
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
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
            borderSide: const BorderSide(color: Color(0xFFFFA724)),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildTraceCard() => Container(
    height: 40,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [BoxShadow(color: const Color(0xFF2B1D1D).withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Text('심슨 님의 흔적을 확인하세요'),
          const Spacer(),
          const Icon(Icons.person, size: 20),
          const SizedBox(width: 12),
          const Icon(Icons.favorite, size: 20),
          const SizedBox(width: 12),
          const Icon(Icons.bookmark, size: 20),
        ],
      ),
    ),
  );

  Widget _buildSortButtons() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      _buildSortButton(icon: Icons.filter_list, label: ''),
      _buildSortButton(label: '최신순'),
      _buildSortButton(label: '좋아요순'),
      _buildSortButton(label: '거리순'),
    ],
  );

  Widget _buildSortButton({IconData? icon, String label = ''}) => GestureDetector(
    onTap: () => label.isNotEmpty ? _onSortChanged(label) : _showSortPopup(),
    child: Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: const Color(0xFF2B1D1D).withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Center(
        child: icon != null ? Icon(icon, size: 20, color: Colors.black87) : Text(label, style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w500)),
      ),
    ),
  );

  Widget _buildHorizontalCardList() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: SizedBox(
      height: 420,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: filteredPosts.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final post = filteredPosts[index];
          final isLast = index == filteredPosts.length - 1;

          return Container(
            width: 300,
            margin: EdgeInsets.only(
              left: index == 0 ? 0 : 10,
              right: isLast ? 40 : 0,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 210,
                  decoration: BoxDecoration(
                    color: Color(0xFF316954),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                              const Icon(Icons.location_on, size: 16, color: Colors.grey),
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
                          color: Colors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const Icon(Icons.favorite, size: 20, color: Colors.orange),
                          const SizedBox(width: 4),
                          Text(
                            '${post['likes']}',
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ),
  );


  Widget _buildVerticalCategoryList() => ListView.builder(
    physics: const NeverScrollableScrollPhysics(),
    shrinkWrap: true,
    itemCount: filteredPosts.length,
    itemBuilder: (context, index) {
      final post = filteredPosts[index];
      return Padding(
        padding: const EdgeInsets.only(bottom: 30),
        child: ListTile(
          tileColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text(post['title']),
          subtitle: Text(post['location']),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.favorite_border),
              const SizedBox(width: 4),
              Text('${post['likes']}'),
            ],
          ),
        ),
      );
    },
  );
}

class WritePostScreen extends StatelessWidget {
  const WritePostScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      Scaffold(
        appBar: AppBar(title: const Text('글 작성')),
        body: const Center(child: Text('글 작성 페이지')),
      );
}