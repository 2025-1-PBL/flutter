import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SearchService {
  final Dio _dio = Dio();
  final String _baseUrl = 'http://127.0.0.1:8080/api';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // 요청 전에 토큰을 헤더에 추가하는 함수
  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.read(key: 'accessToken');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // 사용자 이름으로 검색
  Future<List<dynamic>> searchUsersByName(String name) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '$_baseUrl/users/search',
        queryParameters: {'name': name},
        options: Options(headers: headers),
      );
      
      debugPrint("▶︎ [SearchService] 사용자 이름 검색 성공: ${response.data}");
      return response.data;
    } catch (e) {
      debugPrint("▶︎ [SearchService] 사용자 이름 검색 실패: $e");
      throw Exception('사용자 검색에 실패했습니다: $e');
    }
  }

  // 게시글 제목으로 검색
  Future<List<dynamic>> searchArticlesByTitle(String keyword, {int page = 0, int size = 10}) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '$_baseUrl/articles/search/title',
        queryParameters: {
          'keyword': keyword,
          'page': page,
          'size': size
        },
        options: Options(headers: headers),
      );
      
      debugPrint("▶︎ [SearchService] 게시글 제목 검색 성공: ${response.data}");
      return response.data;
    } catch (e) {
      debugPrint("▶︎ [SearchService] 게시글 제목 검색 실패: $e");
      throw Exception('게시글 검색에 실패했습니다: $e');
    }
  }

  // 주변 게시글 검색
  Future<List<dynamic>> findArticlesNearby(double latitude, double longitude, double radius) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '$_baseUrl/articles/nearby',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'radius': radius,
        },
        options: Options(headers: headers),
      );
      
      debugPrint("▶︎ [SearchService] 주변 게시글 검색 성공: ${response.data}");
      return response.data;
    } catch (e) {
      debugPrint("▶︎ [SearchService] 주변 게시글 검색 실패: $e");
      throw Exception('주변 게시글 검색에 실패했습니다: $e');
    }
  }

  // 주변 일정 검색
  Future<List<dynamic>> findSchedulesNearby(double latitude, double longitude, double radius) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '$_baseUrl/schedules/nearby',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'radius': radius,
        },
        options: Options(headers: headers),
      );
      
      debugPrint("▶︎ [SearchService] 주변 일정 검색 성공: ${response.data}");
      return response.data;
    } catch (e) {
      debugPrint("▶︎ [SearchService] 주변 일정 검색 실패: $e");
      throw Exception('주변 일정 검색에 실패했습니다: $e');
    }
  }

  // 통합 검색 (사용자, 게시글, 일정 등)
  Future<Map<String, dynamic>> searchAll(String query) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '$_baseUrl/search',
        queryParameters: {'query': query},
        options: Options(headers: headers),
      );
      
      debugPrint("▶︎ [SearchService] 통합 검색 성공: ${response.data}");
      return response.data;
    } catch (e) {
      debugPrint("▶︎ [SearchService] 통합 검색 실패: $e");
      throw Exception('통합 검색에 실패했습니다: $e');
    }
  }
}