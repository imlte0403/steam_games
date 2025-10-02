import 'package:flutter/material.dart';

import 'package:steam_games/core/constants/gaps.dart';
import 'package:steam_games/core/constants/sizes.dart';
import 'package:steam_games/data/models/game_model.dart';

class GameSection extends StatelessWidget {
  const GameSection({
    super.key,
    required this.title,
    required this.games,
    required this.onGameTap,
  });

  final String title;
  final List<GameModel> games;
  final ValueChanged<GameModel> onGameTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            Text(
              '${games.length} items',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
        Gaps.v12,
        if (games.isEmpty)
          const _EmptySection()
        else
          SizedBox(
            height: Sizes.size220,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: games.length,
              separatorBuilder: (_, __) => Gaps.h16,
              itemBuilder: (context, index) {
                final game = games[index];
                return _GameCard(game: game, onTap: () => onGameTap(game));
              },
            ),
          ),
      ],
    );
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({required this.game, required this.onTap});

  final GameModel game;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Sizes.size16),
      child: Ink(
        width: Sizes.size160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Sizes.size16),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(
                top: const Radius.circular(Sizes.size16),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(game.headerImage, fit: BoxFit.cover),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(Sizes.size12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Gaps.v8,
                  Text(
                    game.isFree ? 'Free to Play' : game.finalPrice,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (game.discountPercent > 0) ...[
                    Gaps.v4,
                    Text(
                      '-${game.discountPercent}% · ${game.originalPrice}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptySection extends StatelessWidget {
  const _EmptySection();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Sizes.size120,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Sizes.size16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Text(
        'No data available',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}
