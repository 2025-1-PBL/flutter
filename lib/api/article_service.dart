import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'config.dart';
import 'auth_service.dart';

class ArticleService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final AuthService _authService = AuthService();

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

  // 토큰 만료 여부 확인
  bool _isTokenExpired(DioException e) {
    return e.response?.statusCode == 401 ||
        e.response?.statusCode == 403 ||
        e.message?.contains('만료된 JWT 토큰') == true ||
        e.message?.contains('유효한 JWT 토큰이 없습니다') == true;
  }

  // API 호출 시 토큰 만료 처리
  Future<T> _handleApiCall<T>(Future<T> Function() apiCall) async {
    try {
      return await apiCall();
    } catch (e) {
      if (e is DioException) {
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data;

        print('API 호출 실패 - 상태 코드: $statusCode');
        print('API 호출 실패 - 응답 데이터: $responseData');

        // 토큰 만료 에러 처리
        if (_isTokenExpired(e)) {
          try {
            await _authService.refreshToken();
            // 갱신 성공 시 새로운 토큰으로 다시 시도
            return await apiCall();
          } catch (refreshError) {
            throw Exception('토큰이 만료되었습니다. 다시 로그인해주세요.');
          }
        }

        // 서버 에러 처리 (500, 502, 503 등)
        if (statusCode != null && statusCode >= 500) {
          String errorMessage = '서버 오류가 발생했습니다.';

          // 백엔드에서 구체적인 에러 메시지가 있는 경우
          if (responseData != null && responseData is Map) {
            final message = responseData['message'] ?? responseData['error'];
            if (message != null) {
              errorMessage = message.toString();
            }
          }

          // 500 에러의 경우 백엔드 문제임을 명시
          if (statusCode == 500) {
            errorMessage = '서버 내부 오류가 발생했습니다. 백엔드 개발팀에 문의해주세요.';
          }

          throw Exception(errorMessage);
        }

        // 기타 HTTP 에러 처리
        if (statusCode != null) {
          String errorMessage = '요청 처리 중 오류가 발생했습니다.';

          if (responseData != null && responseData is Map) {
            final message = responseData['message'] ?? responseData['error'];
            if (message != null) {
              errorMessage = message.toString();
            }
          }

          throw Exception(errorMessage);
        }
      }

      // 기타 예외 처리
      throw Exception('게시글 처리 중 오류가 발생했습니다: ${e.toString()}');
    }
  }

  // 모든 게시글 조회 (페이징)
  Future<Map<String, dynamic>> getAllArticles({
    int page = 0,
    int size = 10,
  }) async {
    return await _handleApiCall(() async {
      final headers = await _getHeaders();
      final response = await _dio.get(
        ApiConfig.articleUrl,
        queryParameters: {'page': page, 'size': size},
        options: Options(headers: headers),
      );
      return response.data;
    });
  }

  // 게시글 상세 조회
  Future<Map<String, dynamic>> getArticleById(int articleId) async {
    return await _handleApiCall(() async {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '${ApiConfig.articleUrl}/$articleId',
        options: Options(headers: headers),
      );
      return response.data;
    });
  }

  // 게시글 작성
  Future<Map<String, dynamic>> createArticle(
    Map<String, dynamic> articleData,
  ) async {
    return await _handleApiCall(() async {
      final headers = await _getHeaders();
      final response = await _dio.post(
        ApiConfig.articleUrl,
        data: articleData,
        options: Options(headers: headers),
      );
      return response.data;
    });
  }

  // 게시글 수정
  Future<Map<String, dynamic>> updateArticle(
    int articleId,
    Map<String, dynamic> articleData,
  ) async {
    return await _handleApiCall(() async {
      final headers = await _getHeaders();
      final response = await _dio.put(
        '${ApiConfig.articleUrl}/$articleId',
        data: articleData,
        options: Options(headers: headers),
      );
      return response.data;
    });
  }

  // 게시글 삭제
  Future<void> deleteArticle(int articleId) async {
    return await _handleApiCall(() async {
      final headers = await _getHeaders();
      await _dio.delete(
        '${ApiConfig.articleUrl}/$articleId',
        options: Options(headers: headers),
      );
    });
  }

  // 게시글 좋아요
  Future<Map<String, dynamic>> likeArticle(int articleId) async {
    return await _handleApiCall(() async {
      final headers = await _getHeaders();
      final response = await _dio.post(
        '${ApiConfig.articleUrl}/$articleId/like',
        options: Options(headers: headers),
      );
      return response.data;
    });
  }

  // 게시글 싫어요
  Future<Map<String, dynamic>> dislikeArticle(int articleId) async {
    return await _handleApiCall(() async {
      final headers = await _getHeaders();
      final response = await _dio.post(
        '${ApiConfig.articleUrl}/$articleId/dislike',
        options: Options(headers: headers),
      );
      return response.data;
    });
  }

  // 주변 게시글 찾기
  Future<List<dynamic>> findArticlesNearby(
    double latitude,
    double longitude,
    double radius,
  ) async {
    return await _handleApiCall(() async {
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
    });
  }

  // 제목으로 게시글 검색
  Future<Map<String, dynamic>> searchArticlesByTitle(
    String keyword, {
    int page = 0,
    int size = 10,
  }) async {
    return await _handleApiCall(() async {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '${ApiConfig.articleUrl}/search/title',
        queryParameters: {'keyword': keyword, 'page': page, 'size': size},
        options: Options(headers: headers),
      );
      return response.data;
    });
  }

  // 내용으로 게시글 검색
  Future<Map<String, dynamic>> searchArticlesByContent(
    String keyword, {
    int page = 0,
    int size = 10,
  }) async {
    return await _handleApiCall(() async {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '${ApiConfig.articleUrl}/search/content',
        queryParameters: {'keyword': keyword, 'page': page, 'size': size},
        options: Options(headers: headers),
      );
      return response.data;
    });
  }
}
