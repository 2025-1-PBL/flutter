import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'config.dart';

class BrandService {
  final Dio _dio = Dio();
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
        ApiConfig.brandUrl,
        options: Options(headers: headers),
      );
      return response.data as List<dynamic>;
    } catch (e) {
      throw Exception('브랜드 목록을 불러오는데 실패했습니다: $e');
    }
  }

  // 브랜드 페이징 조회
  Future<Map<String, dynamic>> getBrandsWithPaging({
    int page = 0,
    int size = 10,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '${ApiConfig.brandUrl}/page',
        queryParameters: {'page': page, 'size': size},
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
        '${ApiConfig.brandUrl}/search',
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
        '${ApiConfig.brandUrl}/$brandId',
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      throw Exception('브랜드 정보를 불러오는데 실패했습니다: $e');
    }
  }

  // 브랜드 생성
  Future<Map<String, dynamic>> createBrand(
    Map<String, dynamic> brandData,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.post(
        ApiConfig.brandUrl,
        data: brandData,
        options: Options(headers: headers),
      );
      return response.data;
    } catch (e) {
      throw Exception('브랜드 생성에 실패했습니다: $e');
    }
  }

  // 브랜드 정보 수정
  Future<Map<String, dynamic>> updateBrand(
    int brandId,
    Map<String, dynamic> brandData,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.put(
        '${ApiConfig.brandUrl}/$brandId',
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
        '${ApiConfig.brandUrl}/$brandId',
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
        ApiConfig.baseUrl + '/brands/$brandId/franchises',
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
        ApiConfig.baseUrl + '/brands/$brandId/franchises',
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
        ApiConfig.baseUrl + '/franchises/$franchiseId',
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
        ApiConfig.baseUrl + '/franchises/$franchiseId',
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
        ApiConfig.baseUrl + '/franchises/$franchiseId',
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
        ApiConfig.baseUrl + '/franchises/nearby',
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
        ApiConfig.baseUrl + '/brands/$brandId/events',
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
        ApiConfig.baseUrl + '/brands/$brandId/events',
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
        ApiConfig.baseUrl + '/events/$eventId',
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
        ApiConfig.baseUrl + '/events/$eventId',
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
        ApiConfig.baseUrl + '/events/$eventId',
        options: Options(headers: headers),
      );
    } catch (e) {
      throw Exception('이벤트 삭제에 실패했습니다: $e');
    }
  }
}
