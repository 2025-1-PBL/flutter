import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ArticleService {
  final Dio _dio = Dio();
  final String _baseUrl = 'http://127.0.0.1:8080/api/articles';
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  // 요청 전에 토큰을 헤더에 추가하는 함수
  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.read(key: 'accessToken');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // 모든 게시글 조회
  Future<dynamic> getAllArticles({int page = 0, int size = 10}) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '$_baseUrl',
        queryParameters: {'page': page, 'size': size},
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      throw Exception('게시글 목록을 불러오는데 실패했습니다: $e');
    }
  }

  // 게시글 상세 조회
  Future<dynamic> getArticleById(int articleId) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '$_baseUrl/$articleId',
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      throw Exception('게시글을 불러오는데 실패했습니다: $e');
    }
  }

  // 게시글 작성
  Future<dynamic> createArticle(Map<String, dynamic> articleData) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.post(
        '$_baseUrl',
        data: articleData,
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      throw Exception('게시글 작성에 실패했습니다: $e');
    }
  }

  // 게시글 수정
  Future<dynamic> updateArticle(int articleId, Map<String, dynamic> articleData) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.put(
        '$_baseUrl/$articleId',
        data: articleData,
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      throw Exception('게시글 수정에 실패했습니다: $e');
    }
  }

  // 게시글 삭제
  Future<void> deleteArticle(int articleId) async {
    try {
      final headers = await _getHeaders();
      await _dio.delete(
        '$_baseUrl/$articleId',
        options: Options(headers: headers),
      );
    } catch (e) {
      throw Exception('게시글 삭제에 실패했습니다: $e');
    }
  }

  // 게시글 좋아요
  Future<dynamic> likeArticle(int articleId) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.post(
        '$_baseUrl/$articleId/like',
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      throw Exception('좋아요 등록에 실패했습니다: $e');
    }
  }

  // 주변 게시글 찾기
  Future<List<dynamic>> findArticlesNearby(double latitude, double longitude, double radius) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '$_baseUrl/nearby',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'radius': radius,
        },
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      throw Exception('주변 게시글을 불러오는데 실패했습니다: $e');
    }
  }

}

