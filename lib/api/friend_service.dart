import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class FriendService {
  final Dio _dio = Dio();
  final String _baseUrl = 'http://127.0.0.1:8080/api/friends';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // 요청 전에 토큰을 헤더에 추가하는 함수
  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.read(key: 'accessToken');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // 친구 요청 보내기
  Future<Map<String, dynamic>> sendFriendRequest(int friendId) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.post(
        '$_baseUrl/request',
        data: {'friendId': friendId},
        options: Options(headers: headers),
      );
      
      debugPrint("▶︎ [FriendService] 친구 요청 보내기 성공: ${response.data}");
      return response.data;
    } catch (e) {
      debugPrint("▶︎ [FriendService] 친구 요청 보내기 실패: $e");
      throw Exception('친구 요청 보내기에 실패했습니다: $e');
    }
  }

  // 친구 요청 수락
  Future<Map<String, dynamic>> acceptFriendRequest(int requestId) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.put(
        '$_baseUrl/accept/$requestId',
        options: Options(headers: headers),
      );
      
      debugPrint("▶︎ [FriendService] 친구 요청 수락 성공: ${response.data}");
      return response.data;
    } catch (e) {
      debugPrint("▶︎ [FriendService] 친구 요청 수락 실패: $e");
      throw Exception('친구 요청 수락에 실패했습니다: $e');
    }
  }

  // 친구 요청 거절
  Future<Map<String, dynamic>> rejectFriendRequest(int requestId) async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.put(
        '$_baseUrl/reject/$requestId',
        options: Options(headers: headers),
      );
      
      debugPrint("▶︎ [FriendService] 친구 요청 거절 성공: ${response.data}");
      return response.data;
    } catch (e) {
      debugPrint("▶︎ [FriendService] 친구 요청 거절 실패: $e");
      throw Exception('친구 요청 거절에 실패했습니다: $e');
    }
  }

  // 친구 삭제
  Future<void> deleteFriend(int friendId) async {
    try {
      final headers = await _getHeaders();
      await _dio.delete(
        '$_baseUrl/$friendId',
        options: Options(headers: headers),
      );
      
      debugPrint("▶︎ [FriendService] 친구 삭제 성공");
    } catch (e) {
      debugPrint("▶︎ [FriendService] 친구 삭제 실패: $e");
      throw Exception('친구 삭제에 실패했습니다: $e');
    }
  }

  // 나의 친구 목록 조회
  Future<List<dynamic>> getFriendList() async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '$_baseUrl',
        options: Options(headers: headers),
      );
      
      debugPrint("▶︎ [FriendService] 친구 목록 조회 성공: ${response.data}");
      return response.data;
    } catch (e) {
      debugPrint("▶︎ [FriendService] 친구 목록 조회 실패: $e");
      throw Exception('친구 목록을 불러오는데 실패했습니다: $e');
    }
  }

  // 받은 친구 요청 조회
  Future<List<dynamic>> getReceivedFriendRequests() async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '$_baseUrl/requests/received',
        options: Options(headers: headers),
      );
      
      debugPrint("▶︎ [FriendService] 받은 친구 요청 조회 성공: ${response.data}");
      return response.data;
    } catch (e) {
      debugPrint("▶︎ [FriendService] 받은 친구 요청 조회 실패: $e");
      throw Exception('받은 친구 요청 목록을 불러오는데 실패했습니다: $e');
    }
  }

  // 보낸 친구 요청 조회
  Future<List<dynamic>> getSentFriendRequests() async {
    try {
      final headers = await _getHeaders();
      final response = await _dio.get(
        '$_baseUrl/requests/sent',
        options: Options(headers: headers),
      );
      
      debugPrint("▶︎ [FriendService] 보낸 친구 요청 조회 성공: ${response.data}");
      return response.data;
    } catch (e) {
      debugPrint("▶︎ [FriendService] 보낸 친구 요청 조회 실패: $e");
      throw Exception('보낸 친구 요청 목록을 불러오는데 실패했습니다: $e');
    }
  }
}