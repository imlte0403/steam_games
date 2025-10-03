import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:steam_games/core/constants/gaps.dart';
import 'package:steam_games/core/constants/sizes.dart';

class ShimmerLoading extends StatelessWidget {
  const ShimmerLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView(
        padding: const EdgeInsets.all(Sizes.size20),
        children: [
          // Hero Banner Skeleton
          const _HeroBannerSkeleton(),
          Gaps.v24,
          // Popular Games Section
          const _SectionHeaderSkeleton(),
          Gaps.v16,
          SizedBox(
            height: 280,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              separatorBuilder: (_, __) => Gaps.h16,
              itemBuilder: (_, __) => const _LargeCardSkeleton(),
            ),
          ),
          Gaps.v40,
          // Discounted Picks Section
          const _SectionHeaderSkeleton(),
          Gaps.v16,
          Column(
            children: [
              const _GameCardSkeleton(),
              Gaps.v12,
              const _GameCardSkeleton(),
              Gaps.v12,
              const _GameCardSkeleton(),
            ],
          ),
          Gaps.v40,
          // Grid Section
          const _SectionHeaderSkeleton(),
          Gaps.v16,
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: Sizes.size12,
              mainAxisSpacing: Sizes.size12,
            ),
            itemCount: 6,
            itemBuilder: (_, __) => const _GridCardSkeleton(),
          ),
        ],
      ),
    );
  }
}

// Hero Banner Skeleton
class _HeroBannerSkeleton extends StatelessWidget {
  const _HeroBannerSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Sizes.size20),
      ),
    );
  }
}

// Section Header Skeleton
class _SectionHeaderSkeleton extends StatelessWidget {
  const _SectionHeaderSkeleton();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Gaps.h8,
        Container(
          width: 150,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}

// Large Card Skeleton (for Popular Games)
class _LargeCardSkeleton extends StatelessWidget {
  const _LargeCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      height: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Sizes.size20),
      ),
    );
  }
}

// Game Card Skeleton (for list view)
class _GameCardSkeleton extends StatelessWidget {
  const _GameCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Sizes.size16),
      ),
      child: Row(
        children: [
          Container(
            width: 270,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(Sizes.size16),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(Sizes.size12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Gaps.v8,
                  Container(
                    width: 100,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Gaps.v8,
                  Container(
                    width: 80,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Grid Card Skeleton
class _GridCardSkeleton extends StatelessWidget {
  const _GridCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Sizes.size16),
      ),
    );
  }
}
