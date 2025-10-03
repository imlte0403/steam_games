//import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:steam_games/data/models/game_model.dart';
import 'package:steam_games/providers/game_providers.dart';

class HomeSections {
  const HomeSections({
    required this.popular,
    required this.discounted,
    required this.freeToPlay,
    required this.newReleases,
  });

  final List<GameModel> popular;
  final List<GameModel> discounted;
  final List<GameModel> freeToPlay;
  final List<GameModel> newReleases;
}

final homeSectionsProvider = FutureProvider<HomeSections>((ref) async {
  // API에서 게임 목록 가져오기
  final games = await ref.watch(gameListProvider.future);

  final discounted = games.where((game) => game.discountPercent > 0).toList();
  final freeToPlay = games.where((game) => game.isFree).toList();
  final newReleases = games
      .where((game) => int.tryParse(game.releaseYear) != null)
      .where((game) => int.parse(game.releaseYear) >= 2023 || game.isComingSoon)
      .toList();

  return HomeSections(
    popular: games,
    discounted: discounted,
    freeToPlay: freeToPlay,
    newReleases: newReleases,
  );
});
