import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:steam_games/data/models/game_model.dart';
import 'package:steam_games/providers/game_providers.dart';

final gameDetailProvider = FutureProvider.autoDispose.family<GameModel, String>(
  (ref, appId) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final game = ref.read(gameByIdProvider(appId));
    if (game == null) {
      throw StateError('Game $appId not found');
    }
    return game;
  },
);
