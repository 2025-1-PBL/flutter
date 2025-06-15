import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationItem> notifications = [];
  bool isLoading = true;
  final Dio _dio = Dio();

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
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (authToken == null) {
        throw Exception('인증 토큰이 없습니다.');
      }

      _dio.options.headers['Authorization'] = 'Bearer $authToken';

      final response = await _dio.get(
        'http://ocb.iptime.org:8080/api/notifications',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        setState(() {
          notifications =
              data.map((json) => NotificationItem.fromJson(json)).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      print('알림 목록 가져오기 실패: $e');
      setState(() {
        isLoading = false;
      });

      // 에러 메시지 표시
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('알림을 불러오는데 실패했습니다: $e')));
    }
  }

  // 알림 읽음 처리
  Future<void> markAsRead(int notificationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (authToken == null) {
        throw Exception('인증 토큰이 없습니다.');
      }

      _dio.options.headers['Authorization'] = 'Bearer $authToken';

      await _dio.put(
        'http://ocb.iptime.org:8080/api/notifications/$notificationId/read',
      );

      // UI 업데이트
      setState(() {
        final index = notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          notifications[index] = notifications[index].copyWith(isRead: true);
        }
      });
    } catch (e) {
      print('알림 읽음 처리 실패: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('읽음 처리에 실패했습니다: $e')));
    }
  }

  // 모든 알림 읽음 처리
  Future<void> markAllAsRead() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (authToken == null) {
        throw Exception('인증 토큰이 없습니다.');
      }

      _dio.options.headers['Authorization'] = 'Bearer $authToken';

      await _dio.put('http://ocb.iptime.org:8080/api/notifications/read-all');

      // UI 업데이트
      setState(() {
        notifications =
            notifications.map((n) => n.copyWith(isRead: true)).toList();
      });
    } catch (e) {
      print('모든 알림 읽음 처리 실패: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('모두 읽음 처리에 실패했습니다: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('알림'),
        actions: [
          IconButton(
            icon: Icon(Icons.done_all),
            onPressed: markAllAsRead,
            tooltip: '모두 읽음 처리',
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: fetchNotifications,
            tooltip: '새로고침',
          ),
        ],
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : notifications.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text('알림이 없습니다.', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: fetchNotifications,
                child: ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return NotificationListItem(
                      notification: notification,
                      onTap: () {
                        markAsRead(notification.id);
                        // 알림 타입에 따라 적절한 화면으로 이동
                        _navigateToNotificationTarget(notification);
                      },
                    );
                  },
                ),
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
}

// 알림 목록 아이템 위젯
class NotificationListItem extends StatelessWidget {
  final NotificationItem notification;
  final VoidCallback onTap;

  const NotificationListItem({
    Key? key,
    required this.notification,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: notification.isRead ? Colors.grey : Colors.blue,
          child: Icon(
            _getNotificationIcon(notification.type),
            color: Colors.white,
          ),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight:
                notification.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.message),
            SizedBox(height: 4),
            Text(
              _formatDate(notification.createdAt),
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing:
            notification.isRead
                ? null
                : Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
        onTap: onTap,
      ),
    );
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
      isRead: json['isRead'] ?? false,
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
