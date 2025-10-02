import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:steam_games/data/mock/mock_games.dart';
import 'package:steam_games/data/models/game_model.dart';

final gameListProvider = Provider<List<GameModel>>((ref) => mockGames);

final gameByIdProvider = Provider.family<GameModel?, String>((ref, appId) {
  final games = ref.watch(gameListProvider);
  for (final game in games) {
    if (game.appId == appId) {
      return game;
    }
  }
  return null;
});
