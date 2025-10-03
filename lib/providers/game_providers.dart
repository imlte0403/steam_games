import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:steam_games/data/models/game_model.dart';
import 'package:steam_games/data/repositories/game_repository.dart';
import 'package:steam_games/data/services/steam_api_service.dart';

// Steam API Service Provider
final steamApiServiceProvider = Provider<SteamApiService>((ref) {
  return SteamApiService();
});

// Game Repository Provider
final gameRepositoryProvider = Provider<GameRepository>((ref) {
  final apiService = ref.watch(steamApiServiceProvider);
  return GameRepository(apiService);
});

// Game List Provider (API에서 가져오기)
final gameListProvider = FutureProvider<List<GameModel>>((ref) async {
  final repository = ref.watch(gameRepositoryProvider);
  return repository.getFeaturedGames();
});

// Game By ID Provider
final gameByIdProvider = Provider.family<GameModel?, String>((ref, appId) {
  final gamesAsync = ref.watch(gameListProvider);

  return gamesAsync.when(
    data: (games) {
      for (final game in games) {
        if (game.appId == appId) {
          return game;
        }
      }
      return null;
    },
    loading: () => null,
    error: (_, __) => null,
  );
});
