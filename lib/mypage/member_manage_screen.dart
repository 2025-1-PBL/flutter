import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/custom_top_nav_bar.dart';

class MemberManageScreen extends StatefulWidget {
  const MemberManageScreen({super.key});

  @override
  State<MemberManageScreen> createState() => _MemberManageScreenState();
}

class _MemberManageScreenState extends State<MemberManageScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final List<String> friends = ['김ㅇㅇ', '김ㅇㅇ', '김ㅇㅇ', '김ㅇㅇ'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
      body: Container(
        color: const Color(0xFFF9FAFB),
        child: Column(
          children: [
            CustomTopBar(
              title: '공유 멤버 관리',
              actionIcon: Icons.person_add_alt_1,
              onAction: () {
                print('친구 추가 아이콘 클릭됨');
              },
            ),
            const SizedBox(height: 20),
            Theme(
              data:
              Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: PreferredSize(
                preferredSize: const Size.fromHeight(kToolbarHeight),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      indicatorColor: const Color(0xFFFFA724),
                      indicatorWeight: 2.5,
                      labelColor: const Color(0xFFFFA724),
                      unselectedLabelColor: Colors.grey,
                      labelStyle: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                      unselectedLabelStyle: const TextStyle(fontSize: 18),
                      tabs: const [
                        Tab(text: '친구'),
                        Tab(text: '요청'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildFriendTab(),
                  const Center(child: Text('요청 목록')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchBar(),
          const SizedBox(height: 30),
          Text('${friends.length}명',
              style: const TextStyle(fontSize: 18, color: Colors.black)),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: friends.length,
              separatorBuilder: (_, __) =>
              const Divider(color: Color(0xFFE0E0E0)),
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(friends[index]),
                  trailing:
                  const Icon(Icons.delete_outline, color: Colors.grey),
                  onTap: () {},
                );
              },
            ),
          ),
        ],
      ),
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
          hintText: '친구의 닉네임을 검색하세요.',
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
        onChanged: (query) {
          // 검색 필터링 로직 추가 가능
        },
      ),
    );
  }
}
