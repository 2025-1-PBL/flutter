import 'package:flutter/material.dart';
import '../widgets/custom_top_nav_bar.dart';
import '../notification/notificationService.dart';
import '../notification/notificationManager.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final _storage = const FlutterSecureStorage();
  late NotificationManager _notificationManager;
  List<NotificationItem> _notifications = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeAndFetch();
  }

  Future<void> _initializeAndFetch() async {
    if (!mounted) return;

    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      _notificationManager = NotificationManager();
      await _notificationManager.initialize();

      if (!mounted) return;

      final notifications = await _notificationManager.getNotifications();

      if (!mounted) return;

      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsRead(int notificationId) async {
    try {
      await _notificationManager.markAsRead(notificationId);
      await _initializeAndFetch(); // 목록 새로고침
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('알림을 읽음 처리하는데 실패했습니다: $e')));
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await _notificationManager.markAllAsRead();
      await _initializeAndFetch(); // 목록 새로고침
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('모든 알림을 읽음 처리하는데 실패했습니다: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          // 상단바는 전체 폭
          CustomTopBar(
            title: '알림 목록',
            onBack: () => Navigator.pop(context),
            actions: [
              if (_notifications.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.done_all),
                  onPressed: _markAllAsRead,
                  tooltip: '모두 읽음 처리',
                ),
            ],
          ),

          // 나머지 아래 내용은 마진 40
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: _buildBody(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _initializeAndFetch,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (_notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.notifications_none, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('알림이 없습니다.', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _initializeAndFetch,
              child: const Text('새로고침'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _initializeAndFetch,
      child: ListView.separated(
        padding: const EdgeInsets.only(top: 20, bottom: 20),
        itemCount: _notifications.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return ListTile(
            contentPadding: EdgeInsets.zero, // 내부 여백 제거
            leading: CircleAvatar(
              backgroundColor:
                  notification.isRead ? Colors.grey : const Color(0xFFFFA724),
              child: Icon(
                _getNotificationIcon(notification.type),
                color: Colors.white,
                size: 20,
              ),
            ),
            title: Text(
              notification.title,
              style: TextStyle(
                fontWeight:
                    notification.isRead ? FontWeight.normal : FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.message,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(notification.createdAt),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            trailing:
                notification.isRead
                    ? null
                    : IconButton(
                      icon: const Icon(Icons.check),
                      onPressed: () => _markAsRead(notification.id),
                      tooltip: '읽음 처리',
                    ),
            onTap: () {
              _handleNotificationTap(notification);
            },
          );
        },
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'NEW_ARTICLE':
        return Icons.article;
      case 'NEW_COMMENT':
        return Icons.comment;
      case 'ARTICLE_LIKE':
        return Icons.favorite;
      case 'ARTICLE_DISLIKE':
        return Icons.thumb_down;
      case 'FRIEND_REQUEST':
        return Icons.person_add;
      case 'SCHEDULE_INVITATION':
        return Icons.event;
      case 'TEST':
        return Icons.notifications;
      case 'BLOCK_INVITATION':
        return Icons.block;
      case 'EVENT_REMINDER':
        return Icons.alarm;
      case 'SYSTEM_NOTIFICATION':
        return Icons.info;
      case 'SCHEDULE_REMINDER':
        return Icons.access_time;
      case 'LOCATION_PROXIMITY':
        return Icons.location_on;
      default:
        return Icons.notifications;
    }
  }

  void _handleNotificationTap(NotificationItem notification) {
    // 알림 타입에 따른 화면 이동 처리
    switch (notification.type) {
      case 'NEW_COMMENT':
        // 댓글이 달린 게시글로 이동
        Navigator.pushNamed(
          context,
          '/community/post/${notification.referenceId}',
        );
        break;
      case 'NEW_ARTICLE':
        // 새 게시글로 이동
        Navigator.pushNamed(
          context,
          '/community/post/${notification.referenceId}',
        );
        break;
      case 'SCHEDULE_REMINDER':
        // 일정 상세로 이동
        Navigator.pushNamed(context, '/schedule/${notification.referenceId}');
        break;
      default:
        // 기본적으로 홈으로 이동
        Navigator.pushNamed(context, '/home');
    }

    // 읽지 않은 알림이면 읽음 처리
    if (!notification.isRead) {
      _markAsRead(notification.id);
    }
  }

  String _formatDate(DateTime date) {
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

  @override
  void dispose() {
    _notificationManager.dispose();
    super.dispose();
  }
}
