import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CommentService {
  final Dio _dio = Dio();
  final String _baseUrl = 'http://127.0.0.1:8080/api/comments';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // 요청 전에 토큰을 헤더에 추가하는 함수
  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.read(key: 'accessToken');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // 게시글의 댓글 목록 조회 (페이징)
  Future<dynamic> getArticleComments(int articleId, {int page = 0, int size = 10}) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '$_baseUrl/articles/$articleId',
        queryParameters: {
          'page': page,
          'size': size,
        },
        options: Options(headers: headers),
      );
      debugPrint("▶︎ [CommentService] 게시글 댓글 목록 조회 성공: ${response.data}");
      return response.data;
    } catch (e) {
      debugPrint("▶︎ [CommentService] 게시글 댓글 목록 조회 실패: $e");
      throw Exception('게시글 댓글 목록을 불러오는데 실패했습니다: $e');
    }
  }

  // 게시글에 새 댓글 작성
  Future<dynamic> createArticleComment(int articleId, Map<String, dynamic> commentData) async {
    try {
      final headers = await _getHeaders();
      final userId = await _getUserId();
      
      final response = await _dio.post(
        '$_baseUrl/articles/$articleId?userId=$userId',
        data: commentData,
        options: Options(headers: headers),
      );
      debugPrint("▶︎ [CommentService] 게시글 댓글 작성 성공: ${response.data}");
      return response.data;
    } catch (e) {
      debugPrint("▶︎ [CommentService] 게시글 댓글 작성 실패: $e");
      throw Exception('댓글 작성에 실패했습니다: $e');
    }
  }

  // 게시글 댓글 수정
  Future<dynamic> updateArticleComment(int commentId, Map<String, dynamic> commentData) async {
    try {
      final headers = await _getHeaders();
      final userId = await _getUserId();
      
      final response = await _dio.put(
        '$_baseUrl/articles/$commentId?userId=$userId',
        data: commentData,
        options: Options(headers: headers),
      );
      debugPrint("▶︎ [CommentService] 게시글 댓글 수정 성공: ${response.data}");
      return response.data;
    } catch (e) {
      debugPrint("▶︎ [CommentService] 게시글 댓글 수정 실패: $e");
      if (e is DioException && e.response?.statusCode == 403) {
        throw Exception('댓글을 수정할 권한이 없습니다');
      }
      throw Exception('댓글 수정에 실패했습니다: $e');
    }
  }

  // 게시글 댓글 삭제
  Future<void> deleteArticleComment(int commentId) async {
    try {
      final headers = await _getHeaders();
      final userId = await _getUserId();
      
      await _dio.delete(
        '$_baseUrl/articles/$commentId?userId=$userId',
        options: Options(headers: headers),
      );
      debugPrint("▶︎ [CommentService] 게시글 댓글 삭제 성공");
    } catch (e) {
      debugPrint("▶︎ [CommentService] 게시글 댓글 삭제 실패: $e");
      if (e is DioException && e.response?.statusCode == 403) {
        throw Exception('댓글을 삭제할 권한이 없습니다');
      }
      throw Exception('댓글 삭제에 실패했습니다: $e');
    }
  }

  // 일정의 댓글 목록 조회
  Future<List<dynamic>> getScheduleComments(int scheduleId) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '$_baseUrl/schedules/$scheduleId',
        options: Options(headers: headers),
      );
      debugPrint("▶︎ [CommentService] 일정 댓글 목록 조회 성공: ${response.data}");
      return response.data as List<dynamic>;
    } catch (e) {
      debugPrint("▶︎ [CommentService] 일정 댓글 목록 조회 실패: $e");
      throw Exception('일정 댓글 목록을 불러오는데 실패했습니다: $e');
    }
  }

  // 일정에 새 댓글 작성
  Future<dynamic> createScheduleComment(int scheduleId, Map<String, dynamic> commentData) async {
    try {
      final headers = await _getHeaders();
      final userId = await _getUserId();
      
      final response = await _dio.post(
        '$_baseUrl/schedules/$scheduleId?userId=$userId',
        data: commentData,
        options: Options(headers: headers),
      );
      debugPrint("▶︎ [CommentService] 일정 댓글 작성 성공: ${response.data}");
      return response.data;
    } catch (e) {
      debugPrint("▶︎ [CommentService] 일정 댓글 작성 실패: $e");
      if (e is DioException && e.response?.statusCode == 403) {
        throw Exception('공유되지 않은 일정에는 댓글을 작성할 수 없습니다');
      }
      throw Exception('댓글 작성에 실패했습니다: $e');
    }
  }

  // 일정 댓글 수정
  Future<dynamic> updateScheduleComment(int commentId, Map<String, dynamic> commentData) async {
    try {
      final headers = await _getHeaders();
      final userId = await _getUserId();
      
      final response = await _dio.put(
        '$_baseUrl/schedules/$commentId?userId=$userId',
        data: commentData,
        options: Options(headers: headers),
      );
      debugPrint("▶︎ [CommentService] 일정 댓글 수정 성공: ${response.data}");
      return response.data;
    } catch (e) {
      debugPrint("▶︎ [CommentService] 일정 댓글 수정 실패: $e");
      if (e is DioException && e.response?.statusCode == 403) {
        throw Exception('댓글을 수정할 권한이 없습니다');
      }
      throw Exception('댓글 수정에 실패했습니다: $e');
    }
  }

  // 일정 댓글 삭제
  Future<void> deleteScheduleComment(int commentId) async {
    try {
      final headers = await _getHeaders();
      final userId = await _getUserId();
      
      await _dio.delete(
        '$_baseUrl/schedules/$commentId?userId=$userId',
        options: Options(headers: headers),
      );
      debugPrint("▶︎ [CommentService] 일정 댓글 삭제 성공");
    } catch (e) {
      debugPrint("▶︎ [CommentService] 일정 댓글 삭제 실패: $e");
      if (e is DioException && e.response?.statusCode == 403) {
        throw Exception('댓글을 삭제할 권한이 없습니다');
      }
      throw Exception('댓글 삭제에 실패했습니다: $e');
    }
  }

  // 현재 사용자 ID 가져오기 (인증된 사용자)
  Future<int> _getUserId() async {
    try {
      final token = await _storage.read(key: 'userId');
      if (token == null) {
        throw Exception('사용자 ID를 찾을 수 없습니다. 다시 로그인해주세요.');
      }
      return int.parse(token);
    } catch (e) {
      debugPrint("▶︎ [CommentService] 사용자 ID 조회 실패: $e");
      throw Exception('사용자 정보를 확인할 수 없습니다: $e');
    }
  }
}