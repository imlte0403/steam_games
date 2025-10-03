import 'package:steam_games/data/models/game_model.dart';
import 'package:steam_games/data/services/steam_api_service.dart';

class GameRepository {
  GameRepository(this._apiService);

  final SteamApiService _apiService;

  /// Featured 게임 목록 가져오기
  Future<List<GameModel>> getFeaturedGames() async {
    try {
      final data = await _apiService.getFeaturedCategories();
      final List<GameModel> games = [];

      // Specials (할인 중인 게임)
      if (data['specials'] != null && data['specials']['items'] != null) {
        final specials = data['specials']['items'] as List;
        for (final item in specials.take(10)) {
          final game = _parseGameFromFeatured(item as Map<String, dynamic>);
          if (game != null) games.add(game);
        }
      }

      // New Releases (신작)
      if (data['new_releases'] != null &&
          data['new_releases']['items'] != null) {
        final newReleases = data['new_releases']['items'] as List;
        for (final item in newReleases.take(10)) {
          final game = _parseGameFromFeatured(item as Map<String, dynamic>);
          if (game != null) games.add(game);
        }
      }

      // Top Sellers (인기작)
      if (data['top_sellers'] != null && data['top_sellers']['items'] != null) {
        final topSellers = data['top_sellers']['items'] as List;
        for (final item in topSellers.take(10)) {
          final game = _parseGameFromFeatured(item as Map<String, dynamic>);
          if (game != null) games.add(game);
        }
      }

      return games;
    } catch (e) {
      throw Exception('Failed to fetch featured games: $e');
    }
  }

  /// 게임 상세 정보 가져오기
  Future<GameModel?> getGameDetails(String appId) async {
    try {
      final data = await _apiService.getAppDetails(appId);
      return _parseGameFromDetails(data);
    } catch (e) {
      return null;
    }
  }

  /// Featured 데이터에서 GameModel 파싱
  GameModel? _parseGameFromFeatured(Map<String, dynamic> data) {
    try {
      final appId = data['id']?.toString() ?? '';
      final name = data['name']?.toString() ?? 'Unknown Game';
      final headerImage =
          data['header_image']?.toString() ??
          data['large_capsule_image']?.toString() ??
          '';

      final discountPercent = data['discount_percent']?.toInt() ?? 0;
      final currency = data['currency']?.toString();
      final originalPrice = data['original_price']?.toString() ?? '0';
      final finalPrice = data['final_price']?.toString() ?? '0';

      // 가격 포맷팅 (센트 단위를 원화로 변환)
      final formattedOriginalPrice = _formatPrice(
        originalPrice,
        currency: currency,
      );
      final formattedFinalPrice = _formatPrice(finalPrice, currency: currency);

      return GameModel(
        appId: appId,
        name: name,
        headerImage: headerImage,
        screenshots: [headerImage],
        description: data['short_description']?.toString() ?? '',
        releaseDate: '',
        releaseYear: DateTime.now().year.toString(),
        developers: [],
        publishers: [],
        genres: [],
        tags: [],
        originalPrice: formattedOriginalPrice,
        discountPercent: discountPercent,
        finalPrice: formattedFinalPrice,
        isFree: finalPrice == '0',
        supportedLanguages: '',
        platforms: _parsePlatforms(data['platforms']),
        categories: [],
        steamDeckCompatibility: 'Unknown',
        controllerSupport: 'Unknown',
        metacriticScore: null,
        hasDLC: false,
        isComingSoon: false,
        reviewScore: 'No Reviews',
        totalPositive: 0,
        totalNegative: 0,
        totalReviews: 0,
        ratingScore: _generateRandomRating(),
        playerCount: _generateRandomPlayerCount(),
      );
    } catch (e) {
      return null;
    }
  }

  /// 상세 데이터에서 GameModel 파싱
  GameModel? _parseGameFromDetails(Map<String, dynamic> data) {
    try {
      final appId = data['steam_appid']?.toString() ?? '';
      final name = data['name']?.toString() ?? 'Unknown Game';
      final headerImage = data['header_image']?.toString() ?? '';

      final priceData = data['price_overview'];
      final isFree = data['is_free'] == true;
      final discountPercent = priceData?['discount_percent']?.toInt() ?? 0;
      final currency = priceData?['currency']?.toString();
      final originalPriceRaw = priceData?['initial']?.toString();
      final finalPriceRaw = priceData?['final']?.toString();
      final originalPriceFormatted = priceData?['initial_formatted']
          ?.toString();
      final finalPriceFormatted = priceData?['final_formatted']?.toString();

      final originalPrice =
          originalPriceFormatted ??
          _formatPrice(originalPriceRaw ?? '0', currency: currency);
      final finalPrice =
          finalPriceFormatted ??
          (isFree
              ? 'Free to Play'
              : _formatPrice(finalPriceRaw ?? '0', currency: currency));

      final screenshots = <String>[];
      if (data['screenshots'] != null) {
        for (final screenshot in data['screenshots'] as List) {
          screenshots.add(screenshot['path_thumbnail']?.toString() ?? '');
        }
      }

      final genres = <String>[];
      if (data['genres'] != null) {
        for (final genre in data['genres'] as List) {
          genres.add(genre['description']?.toString() ?? '');
        }
      }

      return GameModel(
        appId: appId,
        name: name,
        headerImage: headerImage,
        screenshots: screenshots.isEmpty ? [headerImage] : screenshots,
        description: data['short_description']?.toString() ?? '',
        releaseDate: data['release_date']?['date']?.toString() ?? '',
        releaseYear: _extractYear(
          data['release_date']?['date']?.toString() ?? '',
        ),
        developers: List<String>.from(data['developers'] ?? []),
        publishers: List<String>.from(data['publishers'] ?? []),
        genres: genres,
        tags: [],
        originalPrice: originalPrice,
        discountPercent: discountPercent,
        finalPrice: finalPrice,
        isFree: isFree,
        supportedLanguages: data['supported_languages']?.toString() ?? '',
        platforms: _parsePlatforms(data['platforms']),
        categories: _parseCategories(data['categories']),
        steamDeckCompatibility: 'Unknown',
        controllerSupport: data['controller_support']?.toString() ?? 'Unknown',
        metacriticScore: data['metacritic']?['score']?.toInt(),
        hasDLC: (data['dlc'] as List?)?.isNotEmpty ?? false,
        isComingSoon: data['release_date']?['coming_soon'] == true,
        reviewScore: 'No Reviews',
        totalPositive: 0,
        totalNegative: 0,
        totalReviews: 0,
        ratingScore: _generateRandomRating(),
        playerCount: _generateRandomPlayerCount(),
      );
    } catch (e) {
      return null;
    }
  }

  List<String> _parsePlatforms(dynamic platformsData) {
    final platforms = <String>[];
    if (platformsData == null) return platforms;

    final data = platformsData as Map<String, dynamic>;
    if (data['windows'] == true) platforms.add('Windows');
    if (data['mac'] == true) platforms.add('Mac');
    if (data['linux'] == true) platforms.add('Linux');

    return platforms;
  }

  List<String> _parseCategories(dynamic categoriesData) {
    if (categoriesData == null) return [];
    final categories = <String>[];
    for (final category in categoriesData as List) {
      categories.add(category['description']?.toString() ?? '');
    }
    return categories;
  }

  String _formatPrice(String price, {String? currency}) {
    try {
      // 이미 포맷팅된 가격인 경우 그대로 반환
      if (price.contains('₩') || price.toLowerCase() == 'free') {
        return price;
      }

      // 빈 값이거나 0인 경우
      if (price.isEmpty || price == '0') return 'Free';

      final numericPriceRaw = price
          .replaceAll(',', '')
          .replaceAll(RegExp(r'[^0-9.]'), '');
      if (numericPriceRaw.isEmpty) return 'Free';

      final parsed = double.tryParse(numericPriceRaw);
      if (parsed == null) return price;

      double amount = parsed;

      // Steam Featured API는 통화의 최소 단위(센트 등)로 값을 내려주므로 KRW인 경우 100으로 나눠준다.
      final currencyLower = currency?.toLowerCase();
      if (currencyLower != null && currencyLower.contains('kr')) {
        amount = amount / 100;
      }

      final won = amount.round();
      if (won == 0) return 'Free';

      // 천 단위 콤마만 추가
      return '₩${won.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
    } catch (e) {
      return price;
    }
  }

  String _extractYear(String dateString) {
    try {
      final parts = dateString.split(' ');
      if (parts.length >= 3) {
        return parts.last;
      }
      return DateTime.now().year.toString();
    } catch (e) {
      return DateTime.now().year.toString();
    }
  }

  // 임시 데이터 생성 헬퍼
  double _generateRandomRating() {
    final ratings = [3.5, 3.8, 4.0, 4.2, 4.5, 4.6, 4.7, 4.8, 4.9];
    ratings.shuffle();
    return ratings.first;
  }

  String _generateRandomPlayerCount() {
    final counts = [
      '1K+',
      '5K+',
      '10K+',
      '50K+',
      '100K+',
      '250K+',
      '500K+',
      '1M+',
    ];
    counts.shuffle();
    return counts.first;
  }
}
