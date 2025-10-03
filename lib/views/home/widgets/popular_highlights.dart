import 'package:flutter/material.dart';

import 'package:steam_games/core/constants/gaps.dart';
import 'package:steam_games/data/models/game_model.dart';
import 'package:steam_games/views/home/widgets/hero_banner.dart';
import 'package:steam_games/views/home/widgets/large_game_card.dart';

class PopularHighlights extends StatelessWidget {
  const PopularHighlights({
    super.key,
    required this.games,
    required this.onGameTap,
  });

  final List<GameModel> games;
  final ValueChanged<GameModel> onGameTap;

  @override
  Widget build(BuildContext context) {
    final heroGame = games.first;
    final remaining = games.length > 1
        ? games.skip(1).take(10).toList()
        : const <GameModel>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HeroBanner(game: heroGame, onTap: () => onGameTap(heroGame)),
        if (remaining.isNotEmpty) ...[
          Gaps.v24,
          Text(
            '🔥 Popular Games',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Gaps.v16,
          SizedBox(
            height: 280,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: remaining.length,
              separatorBuilder: (_, __) => Gaps.h16,
              itemBuilder: (context, index) {
                final game = remaining[index];
                return LargeGameCard(game: game, onTap: () => onGameTap(game));
              },
            ),
          ),
        ],
      ],
    );
  }
}
