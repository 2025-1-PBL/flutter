import 'package:flutter/material.dart';
import '../widgets/custom_top_nav_bar.dart';
import '../notification/notificationService.dart';
import '../api/notification_service.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<NotificationItem> notifications = [];
  bool isLoading = true;
  final LocalNotificationService _localNotificationService =
      LocalNotificationService();
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  // 알림 목록 가져오기
  Future<void> fetchNotifications() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await _notificationService.getUserNotifications();
      print('알림 페이지 응답 데이터: $response'); // 응답 데이터 확인

      setState(() {
        notifications =
            response
                .map((json) {
                  print('알림 아이템 JSON: $json'); // 각 알림 아이템 데이터 확인
                  return NotificationItem.fromJson(json);
                })
                .where((notification) => !notification.isRead) // 읽지 않은 알림만 필터링
                .toList();
        isLoading = false;
      });
    } catch (e) {
      print('알림 목록 가져오기 실패: $e');
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('알림을 불러오는데 실패했습니다: $e')));
      }
    }
  }

  // 수동으로 새 알림 확인
  Future<void> checkNewNotifications() async {
    try {
      await _localNotificationService.checkNotificationsManually();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('새 알림을 확인했습니다.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('알림 확인에 실패했습니다: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // 테스트 알림 표시
  Future<void> showTestNotification() async {
    try {
      await _localNotificationService.showTestNotification();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('테스트 알림을 표시했습니다.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('테스트 알림 표시에 실패했습니다: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // 알림 읽음 처리
  Future<void> markAsRead(int notificationId) async {
    try {
      await _notificationService.markAsRead(notificationId);
      // 읽음 처리 후 목록 새로고침
      await fetchNotifications();
    } catch (e) {
      print('알림 읽음 처리 실패: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('읽음 처리에 실패했습니다: $e')));
      }
    }
  }

  // 모든 알림 읽음 처리
  Future<void> markAllAsRead() async {
    try {
      await _notificationService.markAllAsRead();
      // 모두 읽음 처리 후 목록 새로고침
      await fetchNotifications();
    } catch (e) {
      print('모든 알림 읽음 처리 실패: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('모두 읽음 처리에 실패했습니다: $e')));
      }
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
              IconButton(
                icon: const Icon(Icons.done_all),
                onPressed: markAllAsRead,
                tooltip: '모두 읽음 처리',
              ),
            ],
          ),

          // 나머지 아래 내용은 마진 40
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child:
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : notifications.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.notifications_none,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              '알림이 없습니다.',
                              style: TextStyle(color: Colors.grey),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: checkNewNotifications,
                              child: const Text('새 알림 확인'),
                            ),
                          ],
                        ),
                      )
                      : RefreshIndicator(
                        onRefresh: fetchNotifications,
                        child: ListView.separated(
                          padding: const EdgeInsets.only(top: 20, bottom: 20),
                          itemCount: notifications.length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (context, index) {
                            final notification = notifications[index];
                            return ListTile(
                              contentPadding: EdgeInsets.zero, // 내부 여백 제거
                              leading: CircleAvatar(
                                backgroundColor:
                                    notification.isRead
                                        ? Colors.grey
                                        : const Color(0xFFFFA724),
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
                                      notification.isRead
                                          ? FontWeight.normal
                                          : FontWeight.bold,
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
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              trailing:
                                  notification.isRead
                                      ? null
                                      : Container(
                                        width: 10,
                                        height: 10,
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                              onTap: () {
                                markAsRead(notification.id);
                                // 알림 타입에 따라 적절한 화면으로 이동
                                _navigateToNotificationTarget(notification);
                              },
                            );
                          },
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }

  // 알림 클릭 시 해당 화면으로 이동
  void _navigateToNotificationTarget(NotificationItem notification) {
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
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'NEW_COMMENT':
        return Icons.comment;
      case 'NEW_ARTICLE':
        return Icons.article;
      case 'SCHEDULE_REMINDER':
        return Icons.schedule;
      default:
        return Icons.notifications;
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
}

// 알림 데이터 모델
class NotificationItem {
  final int id;
  final String title;
  final String message;
  final String type;
  final int referenceId;
  final DateTime createdAt;
  final bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.referenceId,
    required this.createdAt,
    required this.isRead,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      type: json['type'],
      referenceId: json['referenceId'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      isRead: json['read'] ?? false,
    );
  }

  NotificationItem copyWith({
    int? id,
    String? title,
    String? message,
    String? type,
    int? referenceId,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      referenceId: referenceId ?? this.referenceId,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}
