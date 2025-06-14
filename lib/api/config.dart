class ApiConfig {
  // 서버 기본 URL
  static const String baseUrl = 'http://ocb.iptime.org:8080/api';

  // 개별 서비스별 URL (필요시 사용)
  static const String authUrl = baseUrl;
  static const String scheduleUrl = '$baseUrl/schedules';
  static const String userUrl = '$baseUrl/users';
  static const String sharedScheduleUrl = '$baseUrl/shared-schedules';
  static const String notificationUrl = '$baseUrl/notifications';
  static const String commentUrl = '$baseUrl/comments';
  static const String brandUrl = '$baseUrl/brands';
  static const String articleUrl = '$baseUrl/articles';

  // 타임아웃 설정
  static const int connectTimeout = 30000; // 30초
  static const int receiveTimeout = 30000; // 30초

  // 재시도 횟수
  static const int maxRetries = 3;
}
