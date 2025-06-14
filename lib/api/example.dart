import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'user_service.dart';
import 'schedule_service.dart';
import 'shared_schedule_service.dart';
import 'article_service.dart';
import 'api/comment_service.dart';
import 'brand_service.dart';

class ApiExample extends StatelessWidget {
  // 서비스 인스턴스 생성
  final _authService = AuthService();
  final _userService = UserService();
  final _scheduleService = ScheduleService();
  final _sharedScheduleService = SharedScheduleService();
  final _articleService = ArticleService();
  final _commentService = CommentService();
  final _brandService = BrandService();

  // 1. 인증 관련 API 호출 예시
  Future<void> _authExample() async {
    // 로그인
    final loginResult = await _authService.login(
      'email@example.com',
      'password',
    );

    // 회원가입
    final signupResult = await _authService.signup({
      'email': 'new@example.com',
      'password': 'password',
      'name': '홍길동',
    });

    // 현재 사용자 정보 조회
    final currentUser = await _authService.getCurrentUser();
  }

  // 2. 사용자 관련 API 호출 예시
  Future<void> _userExample() async {
    // 이메일로 사용자 조회
    final user = await _userService.getUserByEmail('email@example.com');

    // 사용자 정보 수정
    final updatedUser = await _userService.updateUser(1, {
      'name': '새이름',
      'profileImage': 'image_url',
    });

    // 사용자 검색
    final searchResults = await _userService.searchUsersByName('홍');
  }

  // 3. 일정 관련 API 호출 예시
  Future<void> _scheduleExample() async {
    // 일정 생성
    final newSchedule = await _scheduleService.createSchedule(1, {
      'title': '미팅',
      'description': '팀 미팅',
      'startTime': '2024-03-20T14:00:00',
      'endTime': '2024-03-20T15:00:00',
      'location': {
        'latitude': 37.5665,
        'longitude': 126.9780,
        'address': '서울시 강남구',
      },
    });

    // 일정 목록 조회
    final schedules = await _scheduleService.getAllSchedulesByUser(1);

    // 주변 일정 검색
    final nearbySchedules = await _scheduleService.findSchedulesNearby(
      37.5665, // 위도
      126.9780, // 경도
      1.0, // 반경 (km)
    );
  }

  // 4. 공유 일정 관련 API 호출 예시
  Future<void> _sharedScheduleExample() async {
    // 일정 공유하기
    final sharedSchedule = await _sharedScheduleService.shareSchedule(1, 1);

    // 공유 일정에 멤버 추가
    final member = await _sharedScheduleService.addMemberToSharedSchedule(
      1, // sharedScheduleId
      2, // memberUserId
      1, // masterId
    );

    // 공유된 일정 목록 조회
    final sharedSchedules = await _sharedScheduleService
        .getSharedSchedulesForUser(1);
  }

  // 5. 게시글 관련 API 호출 예시
  Future<void> _articleExample() async {
    // 게시글 작성
    final newArticle = await _articleService.createArticle({
      'title': '제목',
      'content': '내용',
      'location': {
        'latitude': 37.5665,
        'longitude': 126.9780,
        'address': '서울시 강남구',
      },
    });

    // 게시글 목록 조회
    final articles = await _articleService.getAllArticles(page: 0, size: 10);

    // 주변 게시글 검색
    final nearbyArticles = await _articleService.findArticlesNearby(
      37.5665, // 위도
      126.9780, // 경도
      1.0, // 반경 (km)
    );
  }

  // 6. 댓글 관련 API 호출 예시
  Future<void> _commentExample() async {
    // 게시글 댓글 작성
    final newComment = await _commentService.createArticleComment(
      1, // articleId
      {'content': '댓글 내용'},
      1, // userId
    );

    // 일정 댓글 작성
    final scheduleComment = await _commentService.createScheduleComment(
      1, // scheduleId
      {'content': '댓글 내용'},
      1, // userId
    );

    // 댓글 목록 조회
    final comments = await _commentService.getArticleComments(
      1, // articleId
      page: 0,
      size: 10,
      currentUserId: 1,
    );
  }

  // 7. 브랜드 관련 API 호출 예시
  Future<void> _brandExample() async {
    // 브랜드 검색
    final brands = await _brandService.searchBrandsByName('스타벅스');

    // 주변 프랜차이즈 검색
    final nearbyFranchises = await _brandService.searchFranchisesByLocation(
      37.5665, // 위도
      126.9780, // 경도
      distance: 1.0, // 반경 (km)
    );

    // 브랜드의 이벤트 목록 조회
    final events = await _brandService.getEventsByBrandId(1);
  }

  @override
  Widget build(BuildContext context) {
    return Container(); // 실제 위젯 구현은 생략
  }
}
