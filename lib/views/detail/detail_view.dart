import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:steam_games/core/constants/gaps.dart';
import 'package:steam_games/core/constants/sizes.dart';
import 'package:steam_games/data/models/game_model.dart';
import 'package:steam_games/views/detail/detail_view_model.dart';

class DetailView extends ConsumerWidget {
  const DetailView({super.key, required this.appId});

  final String appId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (appId.isEmpty) {
      return const Scaffold(body: Center(child: Text('Missing game id.')));
    }
    final gameAsync = ref.watch(gameDetailProvider(appId));

    return Scaffold(
      body: gameAsync.when(
        data: (game) => _DetailContent(game: game),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _DetailError(
          message: error.toString(),
          onRetry: () async {
            ref.invalidate(gameDetailProvider(appId));
            await ref.read(gameDetailProvider(appId).future);
          },
        ),
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({required this.game});

  final GameModel game;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: Sizes.size260,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(game.name),
            background: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(game.headerImage, fit: BoxFit.cover),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black54],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              tooltip: 'Open in Steam',
              onPressed: () => _showStoreSnackBar(context),
              icon: const Icon(Icons.open_in_new),
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(Sizes.size16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PriceSection(game: game),
                Gaps.v16,
                _TagSection(title: 'Genres', values: game.genres),
                Gaps.v12,
                _TagSection(title: 'Tags', values: game.tags),
                Gaps.v24,
                Text(
                  'About this game',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Gaps.v8,
                Text(
                  game.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Gaps.v24,
                _ScreenshotCarousel(screenshots: game.screenshots),
                Gaps.v24,
                _DetailGrid(game: game),
                Gaps.v24,
                _ReviewSection(game: game),
                Gaps.v24,
                _SupportInfo(game: game),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PriceSection extends StatelessWidget {
  const _PriceSection({required this.game});

  final GameModel game;

  @override
  Widget build(BuildContext context) {
    final priceStyle = Theme.of(context).textTheme.headlineSmall;
    return Row(
      children: [
        Text(game.isFree ? 'Free to Play' : game.finalPrice, style: priceStyle),
        Gaps.h12,
        if (game.discountPercent > 0)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Sizes.size8,
              vertical: Sizes.size4,
            ),
            decoration: BoxDecoration(
              color: Colors.green.shade700,
              borderRadius: BorderRadius.circular(Sizes.size6),
            ),
            child: Text(
              '-${game.discountPercent}%',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        Gaps.h8,
        if (!game.isFree && game.discountPercent > 0)
          Text(
            game.originalPrice,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              decoration: TextDecoration.lineThrough,
            ),
          ),
      ],
    );
  }
}

class _TagSection extends StatelessWidget {
  const _TagSection({required this.title, required this.values});

  final String title;
  final List<String> values;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        Gaps.v8,
        Wrap(
          spacing: Sizes.size8,
          runSpacing: Sizes.size8,
          children: values.map((value) => Chip(label: Text(value))).toList(),
        ),
      ],
    );
  }
}

class _ScreenshotCarousel extends StatelessWidget {
  const _ScreenshotCarousel({required this.screenshots});

  final List<String> screenshots;

  @override
  Widget build(BuildContext context) {
    if (screenshots.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Screenshots', style: Theme.of(context).textTheme.titleMedium),
        Gaps.v12,
        SizedBox(
          height: Sizes.size200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: screenshots.length,
            separatorBuilder: (_, __) => Gaps.h16,
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(Sizes.size16),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(screenshots[index], fit: BoxFit.cover),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DetailGrid extends StatelessWidget {
  const _DetailGrid({required this.game});

  final GameModel game;

  @override
  Widget build(BuildContext context) {
    final entries = <_DetailEntry>[
      _DetailEntry('Release date', game.releaseDate),
      _DetailEntry('Developers', game.developers.join(', ')),
      _DetailEntry('Publishers', game.publishers.join(', ')),
      _DetailEntry('Platforms', game.platforms.join(', ')),
      _DetailEntry('Categories', game.categories.join(', ')),
      _DetailEntry('Languages', game.supportedLanguages),
      _DetailEntry('Steam Deck', game.steamDeckCompatibility),
      _DetailEntry('Controller', game.controllerSupport),
      _DetailEntry('DLC available', game.hasDLC ? 'Yes' : 'No'),
      _DetailEntry('Coming soon', game.isComingSoon ? 'Yes' : 'No'),
      _DetailEntry(
        'Metacritic',
        game.metacriticScore != null ? '${game.metacriticScore}' : 'N/A',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Game details', style: Theme.of(context).textTheme.titleMedium),
        Gaps.v12,
        ...entries.map((entry) => _DetailRow(entry: entry)),
      ],
    );
  }
}

class _DetailEntry {
  const _DetailEntry(this.label, this.value);

  final String label;
  final String value;
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.entry});

  final _DetailEntry entry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Sizes.size4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: Sizes.size120,
            child: Text(
              entry.label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              entry.value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewSection extends StatelessWidget {
  const _ReviewSection({required this.game});

  final GameModel game;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Community reviews',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Gaps.v8,
        Row(
          children: [
            Icon(Icons.thumb_up_alt_outlined, color: Colors.green.shade600),
            Gaps.h8,
            Text('${game.totalPositive} positive'),
          ],
        ),
        Gaps.v6,
        Row(
          children: [
            Icon(Icons.thumb_down_alt_outlined, color: Colors.red.shade600),
            Gaps.h8,
            Text('${game.totalNegative} negative'),
          ],
        ),
        Gaps.v6,
        Text('Overall: ${game.reviewScore} (${game.totalReviews} reviews)'),
      ],
    );
  }
}

class _SupportInfo extends StatelessWidget {
  const _SupportInfo({required this.game});

  final GameModel game;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Support', style: Theme.of(context).textTheme.titleMedium),
        Gaps.v8,
        Wrap(
          spacing: Sizes.size12,
          runSpacing: Sizes.size8,
          children: [
            _SupportChip(
              label: 'Single-player',
              enabled: game.categories.contains('Single-player'),
            ),
            _SupportChip(
              label: 'Multi-player',
              enabled: game.categories.contains('Multi-player'),
            ),
            _SupportChip(
              label: 'Online Co-op',
              enabled: game.categories.contains('Online Co-op'),
            ),
            _SupportChip(
              label: 'Controller',
              enabled: game.controllerSupport != 'None',
            ),
          ],
        ),
      ],
    );
  }
}

class _SupportChip extends StatelessWidget {
  const _SupportChip({required this.label, required this.enabled});

  final String label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(
        enabled ? Icons.check_circle : Icons.cancel,
        color: enabled ? Colors.green.shade600 : Colors.red.shade400,
        size: Sizes.size18,
      ),
      label: Text(label),
      backgroundColor: enabled
          ? Theme.of(context).colorScheme.primaryContainer
          : Theme.of(context).colorScheme.surfaceContainerHigh,
    );
  }
}

class _DetailError extends StatelessWidget {
  const _DetailError({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Failed to load game\n$message', textAlign: TextAlign.center),
          Gaps.v12,
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          Gaps.v12,
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Back'),
          ),
        ],
      ),
    );
  }
}

void _showStoreSnackBar(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Steam Store launch will be added later.')),
  );
}
