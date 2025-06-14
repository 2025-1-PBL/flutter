import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BrandService {
  final Dio _dio = Dio();
  final String _baseUrl = 'http://127.0.0.1:8080/api/brands';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // 헤더 가져오기
  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.read(key: 'token');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // 브랜드 관련 메서드

  // 모든 브랜드 조회
  Future<List<dynamic>> getAllBrands() async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        _baseUrl,
        options: Options(headers: headers),
      );
      return response.data as List<dynamic>;
    } catch (e) {
      throw Exception('브랜드 목록을 불러오는데 실패했습니다: $e');
    }
  }

  // 브랜드 페이징 조회
  Future<Map<String, dynamic>> getBrandsByPage({
    int page = 0,
    int size = 10,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '$_baseUrl/page',
        queryParameters: {
          'page': page,
          'size': size,
        },
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      throw Exception('브랜드 목록을 불러오는데 실패했습니다: $e');
    }
  }

  // 브랜드명으로 검색
  Future<List<dynamic>> searchBrandsByName(String name) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '$_baseUrl/search',
        queryParameters: {'name': name},
        options: Options(headers: headers),
      );
      return response.data as List<dynamic>;
    } catch (e) {
      throw Exception('브랜드 검색에 실패했습니다: $e');
    }
  }

  // 브랜드 상세 조회
  Future<Map<String, dynamic>> getBrandById(int brandId) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '$_baseUrl/$brandId',
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      throw Exception('브랜드 정보를 불러오는데 실패했습니다: $e');
    }
  }

  // 브랜드 생성
  Future<Map<String, dynamic>> createBrand(Map<String, dynamic> brandData) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.post(
        _baseUrl,
        data: brandData,
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      throw Exception('브랜드 생성에 실패했습니다: $e');
    }
  }

  // 브랜드 정보 수정
  Future<Map<String, dynamic>> updateBrand(int brandId, Map<String, dynamic> brandData) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.put(
        '$_baseUrl/$brandId',
        data: brandData,
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      throw Exception('브랜드 정보 수정에 실패했습니다: $e');
    }
  }

  // 브랜드 삭제
  Future<void> deleteBrand(int brandId) async {
    try {
      final headers = await _getHeaders();
      await _dio.delete(
        '$_baseUrl/$brandId',
        options: Options(headers: headers),
      );
    } catch (e) {
      throw Exception('브랜드 삭제에 실패했습니다: $e');
    }
  }

  // 프랜차이즈 관련 메서드

  // 브랜드별 프랜차이즈 목록 조회
  Future<List<dynamic>> getFranchisesByBrandId(int brandId) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '$_baseUrl/$brandId/franchises',
        options: Options(headers: headers),
      );
      return response.data as List<dynamic>;
    } catch (e) {
      throw Exception('프랜차이즈 목록을 불러오는데 실패했습니다: $e');
    }
  }

  // 프랜차이즈 생성
  Future<Map<String, dynamic>> createFranchise(
    int brandId,
    Map<String, dynamic> franchiseData,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.post(
        '$_baseUrl/$brandId/franchises',
        data: franchiseData,
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      throw Exception('프랜차이즈 생성에 실패했습니다: $e');
    }
  }

  // 프랜차이즈 상세 조회
  Future<Map<String, dynamic>> getFranchiseById(int franchiseId) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '$_baseUrl/franchises/$franchiseId',
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      throw Exception('프랜차이즈 정보를 불러오는데 실패했습니다: $e');
    }
  }

  // 프랜차이즈 정보 수정
  Future<Map<String, dynamic>> updateFranchise(
    int franchiseId,
    Map<String, dynamic> franchiseData,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.put(
        '$_baseUrl/franchises/$franchiseId',
        data: franchiseData,
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      throw Exception('프랜차이즈 정보 수정에 실패했습니다: $e');
    }
  }

  // 프랜차이즈 삭제
  Future<void> deleteFranchise(int franchiseId) async {
    try {
      final headers = await _getHeaders();
      await _dio.delete(
        '$_baseUrl/franchises/$franchiseId',
        options: Options(headers: headers),
      );
    } catch (e) {
      throw Exception('프랜차이즈 삭제에 실패했습니다: $e');
    }
  }

  // 위치 기반 프랜차이즈 검색
  Future<List<dynamic>> searchFranchisesByLocation(
    double latitude,
    double longitude, {
    double distance = 1.0,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '$_baseUrl/franchises/nearby',
        queryParameters: {
          'lat': latitude,
          'lng': longitude,
          'distance': distance,
        },
        options: Options(headers: headers),
      );
      return response.data as List<dynamic>;
    } catch (e) {
      throw Exception('주변 프랜차이즈 검색에 실패했습니다: $e');
    }
  }

  // 이벤트 관련 메서드

  // 브랜드별 이벤트 목록 조회
  Future<List<dynamic>> getEventsByBrandId(int brandId) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '$_baseUrl/$brandId/events',
        options: Options(headers: headers),
      );
      return response.data as List<dynamic>;
    } catch (e) {
      throw Exception('이벤트 목록을 불러오는데 실패했습니다: $e');
    }
  }

  // 이벤트 생성
  Future<Map<String, dynamic>> createEvent(
    int brandId,
    Map<String, dynamic> eventData,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.post(
        '$_baseUrl/$brandId/events',
        data: eventData,
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      throw Exception('이벤트 생성에 실패했습니다: $e');
    }
  }

  // 이벤트 상세 조회
  Future<Map<String, dynamic>> getEventById(int eventId) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '$_baseUrl/events/$eventId',
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      throw Exception('이벤트 정보를 불러오는데 실패했습니다: $e');
    }
  }

  // 이벤트 정보 수정
  Future<Map<String, dynamic>> updateEvent(
    int eventId,
    Map<String, dynamic> eventData,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.put(
        '$_baseUrl/events/$eventId',
        data: eventData,
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      throw Exception('이벤트 정보 수정에 실패했습니다: $e');
    }
  }

  // 이벤트 삭제
  Future<void> deleteEvent(int eventId) async {
    try {
      final headers = await _getHeaders();
      await _dio.delete(
        '$_baseUrl/events/$eventId',
        options: Options(headers: headers),
      );
    } catch (e) {
      throw Exception('이벤트 삭제에 실패했습니다: $e');
    }
  }
}
