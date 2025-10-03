import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:steam_games/core/constants/gaps.dart';
import 'package:steam_games/core/constants/sizes.dart';
import 'package:steam_games/data/models/game_model.dart';
import 'package:steam_games/utils/price_utils.dart';
import 'package:steam_games/views/detail/detail_view_model.dart';
import 'package:steam_games/widgets/game_async_image.dart';

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
    final theme = Theme.of(context);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          stretch: true,
          expandedHeight: Sizes.size260,
          leading: IconButton(
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back),
          ),
          flexibleSpace: FlexibleSpaceBar(
            stretchModes: const [
              StretchMode.zoomBackground,
              StretchMode.fadeTitle,
            ],
            titlePadding: const EdgeInsetsDirectional.only(
              start: Sizes.size16,
              end: Sizes.size16,
              bottom: Sizes.size16,
            ),
            title: _HeaderTitle(game: game),
            background: _HeaderHero(game: game),
          ),
          actions: [
            IconButton(
              tooltip: 'Open in Steam',
              onPressed: () => _showStoreSnackBar(context),
              icon: const Icon(Icons.open_in_new),
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.all(Sizes.size16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PriceSection(game: game),
                    Gaps.v12,
                    Wrap(
                      spacing: Sizes.size8,
                      runSpacing: Sizes.size8,
                      children: [
                        _FactChip(icon: Icons.event, label: game.releaseDate),
                        if (game.metacriticScore != null)
                          _FactChip(
                            icon: Icons.star_rate_rounded,
                            label: 'Metacritic ${game.metacriticScore}',
                          ),
                        if (game.isFree)
                          const _FactChip(
                            icon: Icons.card_giftcard,
                            label: 'Free to Play',
                          ),
                        if (game.discountPercent > 0)
                          _FactChip(
                            icon: Icons.local_fire_department,
                            label: '${game.discountPercent}% off',
                          ),
                        if (game.steamDeckCompatibility.isNotEmpty)
                          _FactChip(
                            icon: Icons.gamepad_outlined,
                            label: game.steamDeckCompatibility,
                          ),
                      ],
                    ),
                    Gaps.v16,
                    FilledButton.icon(
                      onPressed: () => _showStoreSnackBar(context),
                      icon: const Icon(Icons.shopping_bag_outlined),
                      label: const Text('View on Steam Store'),
                    ),
                  ],
                ),
              ),
              Gaps.v16,
              if (game.genres.isNotEmpty)
                _SectionCard(
                  title: 'Genres',
                  child: _TagSection(values: game.genres),
                ),
              if (game.tags.isNotEmpty) ...[
                Gaps.v16,
                _SectionCard(
                  title: 'Popular Tags',
                  child: _TagSection(values: game.tags, dense: true),
                ),
              ],
              Gaps.v16,
              _SectionCard(
                title: 'About this game',
                child: Text(
                  game.description,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              if (game.screenshots.isNotEmpty) ...[
                Gaps.v16,
                _SectionCard(
                  title: 'Screenshots',
                  padding: EdgeInsets.zero,
                  child: _ScreenshotCarousel(screenshots: game.screenshots),
                ),
              ],
              Gaps.v16,
              _SectionCard(
                title: 'Game details',
                child: _DetailGrid(game: game),
              ),
              Gaps.v16,
              _SectionCard(
                title: 'Community reviews',
                child: _ReviewSection(game: game),
              ),
              Gaps.v16,
              _SectionCard(
                title: 'Support & modes',
                child: _SupportInfo(game: game),
              ),
            ]),
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
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.headlineMedium?.copyWith(
      fontWeight: FontWeight.bold,
    );
    final finalPriceAmount = PriceUtils.parseToInt(game.finalPrice) ?? 0;
    final finalPriceText = game.isFree || finalPriceAmount == 0
        ? 'Free to Play'
        : PriceUtils.formatAmount(finalPriceAmount);
    final originalPriceAmount = PriceUtils.parseToInt(game.originalPrice) ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(finalPriceText, style: titleStyle),
            if (!game.isFree &&
                game.discountPercent > 0 &&
                originalPriceAmount > 0) ...[
              Gaps.h12,
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Sizes.size8,
                  vertical: Sizes.size4,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(Sizes.size6),
                ),
                child: Text(
                  '-${game.discountPercent}%',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        if (!game.isFree &&
            game.discountPercent > 0 &&
            originalPriceAmount > 0) ...[
          Gaps.v4,
          Text(
            PriceUtils.formatAmount(originalPriceAmount),
            style: theme.textTheme.bodyMedium?.copyWith(
              decoration: TextDecoration.lineThrough,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

class _TagSection extends StatelessWidget {
  const _TagSection({required this.values, this.dense = false});

  final List<String> values;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final textStyle = dense
        ? theme.textTheme.labelSmall
        : theme.textTheme.labelMedium;
    final spacing = dense ? Sizes.size6 : Sizes.size8;

    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: values
          .map(
            (value) => Chip(
              label: Text(value, style: textStyle),
              padding: const EdgeInsets.symmetric(
                horizontal: Sizes.size12,
                vertical: Sizes.size4,
              ),
            ),
          )
          .toList(),
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

    return SizedBox(
      height: Sizes.size220,
      child: ListView.separated(
        padding: const EdgeInsets.all(Sizes.size16),
        scrollDirection: Axis.horizontal,
        itemCount: screenshots.length,
        separatorBuilder: (_, __) => Gaps.h16,
        itemBuilder: (context, index) {
          return AspectRatio(
            aspectRatio: 16 / 9,
            child: GameAsyncImage(
              imageUrl: screenshots[index],
              borderRadius: BorderRadius.circular(Sizes.size16),
            ),
          );
        },
      ),
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
      children: [
        for (var index = 0; index < entries.length; index++) ...[
          _DetailRow(entry: entries[index]),
          if (index != entries.length - 1)
            Divider(
              height: Sizes.size24,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
        ],
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
    final theme = Theme.of(context);
    final totalReviews = game.totalReviews;
    final totalPositive = game.totalPositive;
    final totalNegative = game.totalNegative;
    final positiveRatio = totalReviews == 0
        ? 0.0
        : totalPositive / totalReviews;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.emoji_events_outlined,
              color: theme.colorScheme.secondary,
            ),
            Gaps.h8,
            Text(
              game.reviewScore,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        if (totalReviews > 0) ...[
          Gaps.v12,
          ClipRRect(
            borderRadius: BorderRadius.circular(Sizes.size8),
            child: LinearProgressIndicator(
              value: positiveRatio.clamp(0.0, 1.0),
              minHeight: Sizes.size12,
              color: theme.colorScheme.primary,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
            ),
          ),
          Gaps.v8,
          Text(
            '${(positiveRatio * 100).toStringAsFixed(0)}% positive over ${_formatCount(totalReviews)} reviews',
            style: theme.textTheme.bodySmall,
          ),
        ] else ...[
          Gaps.v12,
          Text('No community reviews yet.', style: theme.textTheme.bodySmall),
        ],
        Gaps.v16,
        _ReviewStatRow(
          icon: Icons.thumb_up_alt_outlined,
          label: 'Positive',
          value: totalPositive,
          color: Colors.green.shade600,
        ),
        Gaps.v12,
        _ReviewStatRow(
          icon: Icons.thumb_down_alt_outlined,
          label: 'Negative',
          value: totalNegative,
          color: Colors.red.shade600,
        ),
      ],
    );
  }
}

class _SupportInfo extends StatelessWidget {
  const _SupportInfo({required this.game});

  final GameModel game;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (game.categories.isNotEmpty) ...[
          Text('Modes', style: theme.textTheme.labelLarge),
          Gaps.v8,
          Wrap(
            spacing: Sizes.size8,
            runSpacing: Sizes.size8,
            children: game.categories
                .map((category) => Chip(label: Text(category)))
                .toList(),
          ),
          Gaps.v16,
        ],
        Text('Compatibility', style: theme.textTheme.labelLarge),
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
              label: 'Controller support',
              enabled: game.controllerSupport != 'None',
            ),
            if (game.steamDeckCompatibility.isNotEmpty)
              _SupportChip(
                label: 'Steam Deck ${game.steamDeckCompatibility}',
                enabled: true,
              ),
          ],
        ),
        Gaps.v16,
        Text('Supported languages', style: theme.textTheme.labelLarge),
        Gaps.v8,
        Text(game.supportedLanguages, style: theme.textTheme.bodyMedium),
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

class _HeaderHero extends StatelessWidget {
  const _HeaderHero({required this.game});

  final GameModel game;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        GameAsyncImage(imageUrl: game.headerImage),
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x26000000), Color(0x99000000)],
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderTitle extends StatelessWidget {
  const _HeaderTitle({required this.game});

  final GameModel game;

  @override
  Widget build(BuildContext context) {
    final genreLabel = game.genres.take(3).join(' • ');
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.titleLarge?.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      height: 1.1,
    );
    final subtitleStyle = theme.textTheme.bodySmall?.copyWith(
      color: Colors.white70,
      height: 1.1,
    );

    return Text.rich(
      TextSpan(
        text: game.name,
        style: titleStyle,
        children: genreLabel.isNotEmpty
            ? [TextSpan(text: '\n$genreLabel', style: subtitleStyle)]
            : null,
      ),
      maxLines: genreLabel.isNotEmpty ? 2 : 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child, this.title, this.padding});

  final Widget child;
  final String? title;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: padding ?? const EdgeInsets.all(Sizes.size16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(Sizes.size16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(title!, style: theme.textTheme.titleMedium),
            Gaps.v12,
          ],
          child,
        ],
      ),
    );
  }
}

class _FactChip extends StatelessWidget {
  const _FactChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) {
      return const SizedBox.shrink();
    }

    return Chip(
      avatar: Icon(icon, size: Sizes.size18),
      label: Text(label),
    );
  }
}

class _ReviewStatRow extends StatelessWidget {
  const _ReviewStatRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, color: color),
        Gaps.h12,
        Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
        Text(
          _formatCount(value),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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

String _formatCount(int value) {
  if (value >= 1000000) {
    return '${(value / 1000000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}M';
  }
  if (value >= 1000) {
    return '${(value / 1000).toStringAsFixed(1).replaceAll(RegExp(r'\.0$'), '')}K';
  }
  return value.toString();
}
