import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'config.dart';

class ArticleService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.read(key: 'token');
    if (token == null) {
      throw Exception('토큰이 없습니다.');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // 모든 게시글 조회 (페이징)
  Future<Map<String, dynamic>> getAllArticles({
    int page = 0,
    int size = 10,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        ApiConfig.articleUrl,
        queryParameters: {'page': page, 'size': size},
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      throw Exception('게시글 목록을 불러오는데 실패했습니다: $e');
    }
  }

  // 게시글 상세 조회
  Future<Map<String, dynamic>> getArticleById(int articleId) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '${ApiConfig.articleUrl}/$articleId',
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      throw Exception('게시글을 불러오는데 실패했습니다: $e');
    }
  }

  // 게시글 작성
  Future<Map<String, dynamic>> createArticle(
    Map<String, dynamic> articleData,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.post(
        ApiConfig.articleUrl,
        data: articleData,
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      throw Exception('게시글 작성에 실패했습니다: $e');
    }
  }

  // 게시글 수정
  Future<Map<String, dynamic>> updateArticle(
    int articleId,
    Map<String, dynamic> articleData,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.put(
        '${ApiConfig.articleUrl}/$articleId',
        data: articleData,
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 403) {
          throw Exception('게시글을 수정할 권한이 없습니다.');
        }
        if (e.response?.statusCode == 404) {
          throw Exception('게시글을 찾을 수 없습니다.');
        }
      }
      throw Exception('게시글 수정에 실패했습니다: $e');
    }
  }

  // 게시글 삭제
  Future<void> deleteArticle(int articleId) async {
    try {
      final headers = await _getHeaders();
      await _dio.delete(
        '${ApiConfig.articleUrl}/$articleId',
        options: Options(headers: headers),
      );
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 403) {
          throw Exception('게시글을 삭제할 권한이 없습니다.');
        }
        if (e.response?.statusCode == 404) {
          throw Exception('게시글을 찾을 수 없습니다.');
        }
      }
      throw Exception('게시글 삭제에 실패했습니다: $e');
    }
  }

  // 게시글 좋아요
  Future<Map<String, dynamic>> likeArticle(int articleId) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.post(
        '${ApiConfig.articleUrl}/$articleId/like',
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 404) {
          throw Exception('게시글을 찾을 수 없습니다.');
        }
      }
      throw Exception('좋아요 등록에 실패했습니다: $e');
    }
  }

  // 게시글 싫어요
  Future<Map<String, dynamic>> dislikeArticle(int articleId) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.post(
        '${ApiConfig.articleUrl}/$articleId/dislike',
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 404) {
          throw Exception('게시글을 찾을 수 없습니다.');
        }
      }
      throw Exception('싫어요 등록에 실패했습니다: $e');
    }
  }

  // 주변 게시글 찾기
  Future<List<dynamic>> findArticlesNearby(
    double latitude,
    double longitude,
    double radius,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '${ApiConfig.articleUrl}/nearby',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'radius': radius,
        },
        options: Options(headers: headers),
      );
      return response.data as List<dynamic>;
    } catch (e) {
      throw Exception('주변 게시글을 불러오는데 실패했습니다: $e');
    }
  }

  // 제목으로 게시글 검색
  Future<Map<String, dynamic>> searchArticlesByTitle(
    String keyword, {
    int page = 0,
    int size = 10,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '${ApiConfig.articleUrl}/search/title',
        queryParameters: {'keyword': keyword, 'page': page, 'size': size},
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      throw Exception('게시글 검색에 실패했습니다: $e');
    }
  }

  // 내용으로 게시글 검색
  Future<Map<String, dynamic>> searchArticlesByContent(
    String keyword, {
    int page = 0,
    int size = 10,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '${ApiConfig.articleUrl}/search/content',
        queryParameters: {'keyword': keyword, 'page': page, 'size': size},
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      throw Exception('게시글 검색에 실패했습니다: $e');
    }
  }
}
