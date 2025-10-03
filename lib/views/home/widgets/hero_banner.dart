import 'package:flutter/material.dart';

import 'package:steam_games/core/constants/gaps.dart';
import 'package:steam_games/core/constants/sizes.dart';
import 'package:steam_games/data/models/game_model.dart';
import 'package:steam_games/utils/price_utils.dart';
import 'package:steam_games/widgets/game_async_image.dart';

class HeroBanner extends StatelessWidget {
  const HeroBanner({super.key, required this.game, required this.onTap});

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
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Sizes.size20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: GameAsyncImage(
                imageUrl: game.headerImage,
                borderRadius: BorderRadius.circular(Sizes.size20),
              ),
            ),
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Sizes.size20),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
            ),
            // Content
            Positioned(
              left: Sizes.size20,
              right: Sizes.size20,
              bottom: Sizes.size20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
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
                        '-${game.discountPercent}% OFF',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  Gaps.v8,
                  Text(
                    game.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  Gaps.v8,
                  Row(
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
                        Gaps.h8,
                        Text(
                          originalPriceText,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 14,
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
