import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:steam_games/core/constants/gaps.dart';
import 'package:steam_games/core/constants/sizes.dart';
import 'package:steam_games/data/models/game_model.dart';
import 'package:steam_games/utils/price_utils.dart';
import 'package:steam_games/widgets/game_async_image.dart';

class GameGridSection extends StatelessWidget {
  const GameGridSection({
    super.key,
    required this.title,
    required this.games,
    required this.onGameTap,
    this.leadingEmoji,
  });

  final String title;
  final List<GameModel> games;
  final ValueChanged<GameModel> onGameTap;
  final String? leadingEmoji;

  String _getIconForTitle(String title) {
    if (title.contains('Popular')) return '🔥';
    if (title.contains('Discounted')) return '💰';
    if (title.contains('Free')) return '🆓';
    if (title.contains('New') || title.contains('Upcoming')) return '✨';
    return '🎮';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              leadingEmoji ?? _getIconForTitle(title),
              style: const TextStyle(fontSize: 24),
            ),
            Gaps.h8,
            Text(title, style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
        Gaps.v16,
        if (games.isEmpty)
          const _EmptySection()
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: Sizes.size12,
              mainAxisSpacing: Sizes.size12,
            ),
            itemCount: games.length > 6 ? 6 : games.length,
            itemBuilder: (context, index) {
              final game = games[index];
              return _GridGameCard(game: game, onTap: () => onGameTap(game));
            },
          ),
      ],
    );
  }
}

class _GridGameCard extends StatelessWidget {
  const _GridGameCard({required this.game, required this.onTap});

  final GameModel game;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final finalPriceAmount = PriceUtils.parseToInt(game.finalPrice) ?? 0;
    final finalPriceText = game.isFree || finalPriceAmount == 0
        ? 'FREE'
        : PriceUtils.formatAmount(finalPriceAmount);
    final originalPriceAmount = PriceUtils.parseToInt(game.originalPrice) ?? 0;
    final originalPriceText = originalPriceAmount > 0
        ? PriceUtils.formatAmount(originalPriceAmount)
        : null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Sizes.size16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Sizes.size16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Full Background Image
            Positioned.fill(
              child: GameAsyncImage(
                imageUrl: game.headerImage,
                borderRadius: BorderRadius.circular(Sizes.size16),
              ),
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: FractionallySizedBox(
                  heightFactor: 0.4,
                  widthFactor: 1,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(Sizes.size16),
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.3),
                              Colors.black.withOpacity(0.8),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Badges
            Positioned(
              top: Sizes.size8,
              right: Sizes.size8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (game.discountPercent > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Sizes.size8,
                        vertical: Sizes.size4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade600,
                        borderRadius: BorderRadius.circular(Sizes.size6),
                      ),
                      child: Text(
                        '-${game.discountPercent}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  if (game.isFree)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Sizes.size8,
                        vertical: Sizes.size4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(Sizes.size6),
                      ),
                      child: const Text(
                        'FREE',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Content on blur
            Positioned(
              left: Sizes.size12,
              right: Sizes.size12,
              bottom: Sizes.size12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    game.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  Gaps.v6,
                  Row(
                    children: [
                      Text(
                        finalPriceText,
                        style: TextStyle(
                          color: game.isFree ? Colors.green : Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (game.discountPercent > 0 &&
                          originalPriceText != null) ...[
                        Gaps.h6,
                        Expanded(
                          child: Text(
                            originalPriceText,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              decoration: TextDecoration.lineThrough,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
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
