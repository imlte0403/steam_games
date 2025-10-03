class ApiConstants {
  // Steam API 키는 환경변수로 관리
  static const String steamApiKey = String.fromEnvironment(
    'STEAM_API_KEY',
    defaultValue: '',
  );

  // Steam API Endpoints
  static const String steamBaseUrl = 'https://api.steampowered.com';
  static const String steamStoreBaseUrl = 'https://store.steampowered.com/api';

  // API Endpoints
  static String getFeaturedGames() => '$steamStoreBaseUrl/featured';
  static String getFeaturedCategories() => '$steamStoreBaseUrl/featuredcategories';
  static String getAppDetails(String appId) => '$steamStoreBaseUrl/appdetails?appids=$appId';

  // 인기 게임 가져오기 (Steam Spy API 대안)
  static const String steamSpyBaseUrl = 'https://steamspy.com/api.php';
  static String getTopGames({int page = 0}) => '$steamSpyBaseUrl?request=top100in2weeks&page=$page';
}
