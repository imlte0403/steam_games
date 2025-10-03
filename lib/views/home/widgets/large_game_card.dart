import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:steam_games/core/constants/gaps.dart';
import 'package:steam_games/core/constants/sizes.dart';
import 'package:steam_games/data/models/game_model.dart';
import 'package:steam_games/utils/price_utils.dart';
import 'package:steam_games/widgets/game_async_image.dart';

class LargeGameCard extends StatelessWidget {
  const LargeGameCard({super.key, required this.game, required this.onTap});

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
      borderRadius: BorderRadius.circular(Sizes.size20),
      child: Container(
        width: 240,
        height: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Sizes.size20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Full Background Image
            Positioned.fill(
              child: GameAsyncImage(
                imageUrl: game.headerImage,
                borderRadius: BorderRadius.circular(Sizes.size20),
              ),
            ),
            // Blur overlay on bottom
            Positioned.fill(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: FractionallySizedBox(
                  heightFactor: 0.4,
                  widthFactor: 1,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(Sizes.size20),
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.3),
                              Colors.black.withOpacity(0.85),
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
              top: Sizes.size12,
              right: Sizes.size12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (game.discountPercent > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Sizes.size12,
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
                  if (game.isFree)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Sizes.size12,
                        vertical: Sizes.size6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(Sizes.size8),
                      ),
                      child: const Text(
                        'FREE',
                        style: TextStyle(
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
                    horizontal: Sizes.size12,
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
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                  Gaps.v12,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        finalPriceText,
                        style: TextStyle(
                          color: game.isFree ? Colors.green : Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (game.discountPercent > 0 &&
                          originalPriceText != null) ...[
                        Gaps.v4,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
