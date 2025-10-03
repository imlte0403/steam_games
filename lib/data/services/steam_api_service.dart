import 'package:dio/dio.dart';
import 'package:steam_games/core/constants/api_constants.dart';

class SteamApiService {
  SteamApiService() : _dio = Dio() {
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
  }

  final Dio _dio;

  /// Featured 게임 가져오기 (Steam Store API)
  Future<Map<String, dynamic>> getFeaturedGames() async {
    try {
      final response = await _dio.get(ApiConstants.getFeaturedGames());
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to load featured games: $e');
    }
  }

  /// Featured Categories 가져오기
  Future<Map<String, dynamic>> getFeaturedCategories() async {
    try {
      final response = await _dio.get(ApiConstants.getFeaturedCategories());
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to load featured categories: $e');
    }
  }

  /// 특정 게임 상세 정보 가져오기
  Future<Map<String, dynamic>> getAppDetails(String appId) async {
    try {
      final response = await _dio.get(ApiConstants.getAppDetails(appId));
      final data = response.data as Map<String, dynamic>;

      if (data[appId] != null && data[appId]['success'] == true) {
        return data[appId]['data'] as Map<String, dynamic>;
      }
      throw Exception('App not found or failed to load');
    } catch (e) {
      throw Exception('Failed to load app details: $e');
    }
  }

  /// 인기 게임 Top 100 가져오기 (SteamSpy API)
  Future<Map<String, dynamic>> getTopGames({int page = 0}) async {
    try {
      final response = await _dio.get(ApiConstants.getTopGames(page: page));
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to load top games: $e');
    }
  }

  /// 여러 게임의 상세 정보를 병렬로 가져오기
  Future<List<Map<String, dynamic>>> getMultipleAppDetails(List<String> appIds) async {
    try {
      final futures = appIds.map((appId) => getAppDetails(appId));
      final results = await Future.wait(
        futures,
        eagerError: false,
      );
      return results;
    } catch (e) {
      throw Exception('Failed to load multiple app details: $e');
    }
  }
}
