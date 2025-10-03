import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:steam_games/core/constants/gaps.dart';
import 'package:steam_games/core/constants/sizes.dart';
import 'package:steam_games/data/models/game_model.dart';
import 'package:steam_games/utils/price_utils.dart';
import 'package:steam_games/widgets/game_async_image.dart';

class GameSection extends StatelessWidget {
  const GameSection({
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
          SizedBox(
            height: 280,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: games.length,
              separatorBuilder: (_, __) => Gaps.h16,
              itemBuilder: (context, index) {
                final game = games[index];
                return SizedBox(
                  width: 320,
                  child: _GameCard(game: game, onTap: () => onGameTap(game)),
                );
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
    final finalPriceAmount = PriceUtils.parseToInt(game.finalPrice) ?? 0;
    final originalPriceAmount = PriceUtils.parseToInt(game.originalPrice) ?? 0;
    final finalPriceText = game.isFree || finalPriceAmount == 0
        ? 'FREE'
        : PriceUtils.formatAmount(finalPriceAmount);
    final originalPriceText = originalPriceAmount > 0
        ? PriceUtils.formatAmount(originalPriceAmount)
        : null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Sizes.size16),
      child: Container(
        height: 280,
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
            // Badges
            Positioned(
              top: Sizes.size12,
              right: Sizes.size12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (game.discountPercent > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Sizes.size10,
                        vertical: Sizes.size6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade600,
                        borderRadius: BorderRadius.circular(Sizes.size8),
                      ),
                      child: Text(
                        '-${game.discountPercent}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (game.isComingSoon)
              Positioned(
                top: Sizes.size12,
                left: Sizes.size12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Sizes.size10,
                    vertical: Sizes.size6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(Sizes.size8),
                  ),
                  child: const Text(
                    'UPCOMING',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            // Content on blur
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
                              Colors.black.withOpacity(0.35),
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
            Positioned(
              left: Sizes.size16,
              right: Sizes.size16,
              bottom: Sizes.size16,
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
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  Gaps.v8,
                  if (game.genres.isNotEmpty)
                    Wrap(
                      spacing: Sizes.size6,
                      runSpacing: Sizes.size4,
                      children: game.genres
                          .take(2)
                          .map(
                            (genre) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: Sizes.size8,
                                vertical: Sizes.size4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(
                                  Sizes.size6,
                                ),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                genre,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  Gaps.v10,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Price
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            finalPriceText,
                            style: TextStyle(
                              color: game.isFree ? Colors.green : Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (game.discountPercent > 0 &&
                              originalPriceText != null) ...[
                            Gaps.v2,
                            Text(
                              originalPriceText,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 13,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ],
                      ),
                      // Rating & Players
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (game.ratingScore != null)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 16,
                                  color: Colors.amber.shade400,
                                ),
                                Gaps.h4,
                                Text(
                                  game.ratingScore!.toStringAsFixed(1),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          if (game.playerCount != null) ...[
                            Gaps.v4,
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.people_outline,
                                  size: 16,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                                Gaps.h4,
                                Text(
                                  game.playerCount!,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
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
