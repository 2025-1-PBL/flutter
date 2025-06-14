import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CommentService {
  final Dio _dio = Dio();
  final String _baseUrl = 'http://127.0.0.1:8080/api/comments';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // 헤더 가져오기
  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.read(key: 'token');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // 게시글 댓글 관련 메서드

  // 게시글의 댓글 목록 조회 (페이징)
  Future<Map<String, dynamic>> getArticleComments(
    int articleId, {
    int page = 0,
    int size = 10,
    int? currentUserId,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '$_baseUrl/articles/$articleId',
        queryParameters: {
          'page': page,
          'size': size,
          if (currentUserId != null) 'currentUserId': currentUserId,
        },
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      throw Exception('댓글 목록을 불러오는데 실패했습니다: $e');
    }
  }

  // 게시글에 새 댓글 작성
  Future<Map<String, dynamic>> createArticleComment(
    int articleId,
    Map<String, dynamic> commentData,
    int userId,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.post(
        '$_baseUrl/articles/$articleId',
        data: commentData,
        queryParameters: {'userId': userId},
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      throw Exception('댓글 작성에 실패했습니다: $e');
    }
  }

  // 게시글 댓글 수정
  Future<Map<String, dynamic>> updateArticleComment(
    int commentId,
    Map<String, dynamic> commentData,
    int userId,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.put(
        '$_baseUrl/articles/$commentId',
        data: commentData,
        queryParameters: {'userId': userId},
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      if (e.toString().contains('403')) {
        throw Exception('댓글을 수정할 권한이 없습니다.');
      }
      throw Exception('댓글 수정에 실패했습니다: $e');
    }
  }

  // 게시글 댓글 삭제
  Future<void> deleteArticleComment(int commentId, int userId) async {
    try {
      final headers = await _getHeaders();
      await _dio.delete(
        '$_baseUrl/articles/$commentId',
        queryParameters: {'userId': userId},
        options: Options(headers: headers),
      );
    } catch (e) {
      if (e.toString().contains('403')) {
        throw Exception('댓글을 삭제할 권한이 없습니다.');
      }
      throw Exception('댓글 삭제에 실패했습니다: $e');
    }
  }

  // 일정 댓글 관련 메서드

  // 일정의 댓글 목록 조회
  Future<List<dynamic>> getScheduleComments(int scheduleId) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '$_baseUrl/schedules/$scheduleId',
        options: Options(headers: headers),
      );
      return response.data as List<dynamic>;
    } catch (e) {
      throw Exception('댓글 목록을 불러오는데 실패했습니다: $e');
    }
  }

  // 일정에 새 댓글 작성
  Future<Map<String, dynamic>> createScheduleComment(
    int scheduleId,
    Map<String, dynamic> commentData,
    int userId,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.post(
        '$_baseUrl/schedules/$scheduleId',
        data: commentData,
        queryParameters: {'userId': userId},
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      if (e.toString().contains('403')) {
        throw Exception('공유되지 않은 일정에는 댓글을 작성할 수 없습니다.');
      }
      throw Exception('댓글 작성에 실패했습니다: $e');
    }
  }

  // 일정 댓글 수정
  Future<Map<String, dynamic>> updateScheduleComment(
    int commentId,
    Map<String, dynamic> commentData,
    int userId,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.put(
        '$_baseUrl/schedules/$commentId',
        data: commentData,
        queryParameters: {'userId': userId},
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      if (e.toString().contains('403')) {
        throw Exception('댓글을 수정할 권한이 없습니다.');
      }
      throw Exception('댓글 수정에 실패했습니다: $e');
    }
  }

  // 일정 댓글 삭제
  Future<void> deleteScheduleComment(int commentId, int userId) async {
    try {
      final headers = await _getHeaders();
      await _dio.delete(
        '$_baseUrl/schedules/$commentId',
        queryParameters: {'userId': userId},
        options: Options(headers: headers),
      );
    } catch (e) {
      if (e.toString().contains('403')) {
        throw Exception('댓글을 삭제할 권한이 없습니다.');
      }
      throw Exception('댓글 삭제에 실패했습니다: $e');
    }
  }
}
