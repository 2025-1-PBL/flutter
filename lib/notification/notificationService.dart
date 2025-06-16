import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/notification_service.dart';
import 'package:geolocator/geolocator.dart';

class LocalNotificationService {
  static final LocalNotificationService _instance =
      LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final NotificationService _notificationService = NotificationService();

  Timer? _pollingTimer;
  int _lastNotificationId = 0;
  bool _isInitialized = false;

  // 위치 업데이트 및 알림 요청
  Future<void> updateLocationAndCheckNotifications() async {
    try {
      // 위치 권한 확인
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('위치 권한이 거부되었습니다.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('위치 권한이 영구적으로 거부되었습니다.');
        return;
      }

      // 현재 위치 가져오기
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // 위치 업데이트 및 알림 요청
      await _notificationService.updateLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        proximityRadius: 0.5, // 500m 반경
      );

      print('위치 업데이트 및 알림 요청 완료: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      print('위치 업데이트 실패: $e');
    }
  }

  // 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 로컬 알림 플러그인 초기화
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );

      const InitializationSettings initializationSettings =
          InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
          );

      final bool? initialized = await _flutterLocalNotificationsPlugin
          .initialize(
            initializationSettings,
            onDidReceiveNotificationResponse: _onNotificationTapped,
          );

      if (initialized == true) {
        // Android 알림 채널 생성
        const AndroidNotificationChannel channel = AndroidNotificationChannel(
          'general_notifications',
          '일반 알림',
          importance: Importance.high,
        );

        await _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.createNotificationChannel(channel);

        _isInitialized = true;
        print('로컬 알림 서비스 초기화 완료');
      } else {
        print('로컬 알림 서비스 초기화 실패');
      }
    } catch (e) {
      print('로컬 알림 서비스 초기화 오류: $e');
      // 초기화 실패해도 앱은 계속 실행되도록 함
    }
  }

  // 알림 폴링 시작 (주기적으로 알림 조회)
  void startPolling({Duration interval = const Duration(minutes: 5)}) {
    stopPolling(); // 기존 타이머 정리

    _pollingTimer = Timer.periodic(interval, (timer) async {
      await updateLocationAndCheckNotifications(); // 위치 업데이트 및 알림 요청
      await _checkForNewNotifications(); // 새로운 알림 확인
    });

    print('알림 폴링 시작 - ${interval.inMinutes}분 간격');
  }

  // 알림 폴링 중지
  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    print('알림 폴링 중지');
  }

  // 새로운 알림 확인
  Future<void> _checkForNewNotifications() async {
    try {
      // 읽지 않은 알림 조회
      final unreadNotifications =
          await _notificationService.getUnreadNotifications();

      // 새로운 알림 필터링 (마지막으로 확인한 ID보다 큰 것들)
      final newNotifications =
          unreadNotifications.where((notification) {
            final id = notification['id'] as int;
            return id > _lastNotificationId;
          }).toList();

      if (newNotifications.isNotEmpty) {
        print('새로운 알림 ${newNotifications.length}개 발견');

        // 각 알림에 대해 로컬 알림 표시
        for (final notification in newNotifications) {
          await _showLocalNotification(notification);

          // 마지막 알림 ID 업데이트
          final id = notification['id'] as int;
          if (id > _lastNotificationId) {
            _lastNotificationId = id;
          }
        }
      }
    } catch (e) {
      print('알림 확인 중 오류: $e');
    }
  }

  // 로컬 알림 표시
  Future<void> _showLocalNotification(Map<String, dynamic> notification) async {
    try {
      final id = notification['id'] as int;
      final title = notification['title'] ?? '새 알림';
      final message = notification['message'] ?? '';
      final type = notification['type'] ?? '';
      final referenceId = notification['referenceId'] ?? 0;

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
            'general_notifications',
            '일반 알림',
            importance: Importance.high,
            priority: Priority.high,
            showWhen: true,
          );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
      );

      await _flutterLocalNotificationsPlugin.show(
        id,
        title,
        message,
        platformChannelSpecifics,
        payload: '{"type": "$type", "referenceId": $referenceId}',
      );

      print('로컬 알림 표시: $title - $message');
    } catch (e) {
      print('로컬 알림 표시 실패: $e');
    }
  }

  // 알림 클릭 처리
  void _onNotificationTapped(NotificationResponse response) {
    try {
      if (response.payload != null) {
        final payload = response.payload!;
        print('알림 클릭됨: $payload');

        // 여기서 알림 타입에 따라 적절한 화면으로 이동하는 로직을 추가할 수 있습니다
        // 예: Navigator.pushNamed(context, '/notifications');
      }
    } catch (e) {
      print('알림 클릭 처리 실패: $e');
    }
  }

  // 수동으로 알림 확인
  Future<void> checkNotificationsManually() async {
    await updateLocationAndCheckNotifications(); // 위치 업데이트 및 알림 요청
    await _checkForNewNotifications(); // 새로운 알림 확인
  }

  // 알림 권한 요청
  Future<bool> requestPermission() async {
    try {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      if (androidImplementation != null) {
        // Android 13 이상에서는 권한 요청이 필요하지 않음
        // 대신 알림 채널이 생성되어 있는지 확인
        return true;
      }
      return false;
    } catch (e) {
      print('알림 권한 요청 실패: $e');
      return false;
    }
  }

  // 테스트 알림 표시
  Future<void> showTestNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'general_notifications',
          '일반 알림',
          importance: Importance.high,
          priority: Priority.high,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      999,
      '테스트 알림',
      '이것은 테스트 알림입니다.',
      platformChannelSpecifics,
    );
  }

  // 서비스 정리
  void dispose() {
    stopPolling();
    _isInitialized = false;
  }
}
