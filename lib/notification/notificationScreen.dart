import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationItem> notifications = [];
  bool isLoading = true;

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
      // 서버에서 알림 목록 가져오기 (NotificationController의 getNotifications 엔드포인트)
      // 실제 구현은 사용 중인 HTTP 클라이언트에 따라 다름
      setState(() {
        // notifications = 응답 데이터 변환
        isLoading = false;
      });
    } catch (e) {
      print('알림 목록 가져오기 실패: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // 알림 읽음 처리
  Future<void> markAsRead(int notificationId) async {
    try {
      // 서버에 읽음 처리 요청 (NotificationController의 markAsRead 엔드포인트)
      // 성공 시 UI 업데이트
      setState(() {
        // 해당 알림 상태 업데이트
      });
    } catch (e) {
      print('알림 읽음 처리 실패: $e');
    }
  }

  // 모든 알림 읽음 처리
  Future<void> markAllAsRead() async {
    try {
      // 서버에 모든 알림 읽음 처리 요청 (NotificationController의 markAllAsRead 엔드포인트)
      // 성공 시 UI 업데이트
      setState(() {
        // 모든 알림 상태 업데이트
      });
    } catch (e) {
      print('모든 알림 읽음 처리 실패: $e');
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
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : notifications.isEmpty
          ? Center(child: Text('알림이 없습니다.'))
          : ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return NotificationListItem(
            notification: notification,
            onTap: () {
              markAsRead(notification.id);
              // 알림 타입에 따라 적절한 화면으로 이동
            },
          );
        },
      ),
    );
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
    return ListTile(
      title: Text(notification.title),
      subtitle: Text(notification.message),
      trailing: notification.isRead
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
    );
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
}