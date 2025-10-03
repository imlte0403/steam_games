import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:steam_games/core/constants/gaps.dart';
import 'package:steam_games/core/constants/sizes.dart';
import 'package:steam_games/router/app_router.dart';
import 'package:steam_games/views/home/home_view_model.dart';
import 'package:steam_games/data/models/game_model.dart';
import 'package:steam_games/views/home/widgets/game_grid_section.dart';
import 'package:steam_games/views/home/widgets/game_section.dart';
import 'package:steam_games/views/home/widgets/popular_highlights.dart';
import 'package:steam_games/widgets/shimmer_loading.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sections = ref.watch(homeSectionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Steam Game Explorer'),
        actions: [
          IconButton(
            onPressed: () => context.pushNamed(AppRoute.search.name),
            icon: const Icon(Icons.search),
          ),
          PopupMenuButton<AppRoute>(
            onSelected: (route) {
              if (route == AppRoute.home) {
                return;
              }
              context.pushNamed(route.name);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: AppRoute.statistics,
                child: Text('Statistics'),
              ),
              PopupMenuItem(
                value: AppRoute.recommendation,
                child: Text('AI Recommendation'),
              ),
            ],
          ),
        ],
      ),
      body: sections.when(
        data: (data) {
          final sectionConfigs = _buildSections(
            context,
            data,
            (game) => _openDetail(context, game.appId),
          );

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(homeSectionsProvider);
              await ref.read(homeSectionsProvider.future);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(Sizes.size20),
              children: [
                if (data.popular.isNotEmpty) ...[
                  PopularHighlights(
                    games: data.popular,
                    onGameTap: (game) => _openDetail(context, game.appId),
                  ),
                  if (sectionConfigs.isNotEmpty) Gaps.v40,
                ],
                for (var i = 0; i < sectionConfigs.length; i++) ...[
                  sectionConfigs[i],
                  if (i != sectionConfigs.length - 1) Gaps.v40,
                ],
                Gaps.v20,
              ],
            ),
          );
        },
        loading: () => const ShimmerLoading(),
        error: (error, stackTrace) => _HomeError(
          message: error.toString(),
          onRetry: () => ref.invalidate(homeSectionsProvider),
        ),
      ),
    );
  }

  void _openDetail(BuildContext context, String appId) {
    context.pushNamed(AppRoute.detail.name, pathParameters: {'id': appId});
  }
}

List<Widget> _buildSections(
  BuildContext context,
  HomeSections data,
  ValueChanged<GameModel> onGameTap,
) {
  final sections = <_HomeSectionDescriptor>[
    _HomeSectionDescriptor(
      games: data.discounted,
      builder: (games) => GameSection(
        title: 'Discounted Picks',
        leadingEmoji: '💰',
        games: games,
        onGameTap: onGameTap,
      ),
    ),
    _HomeSectionDescriptor(
      games: data.freeToPlay,
      builder: (games) => GameGridSection(
        title: 'Free to Play',
        leadingEmoji: '🆓',
        games: games,
        onGameTap: onGameTap,
      ),
    ),
    _HomeSectionDescriptor(
      games: data.newReleases,
      builder: (games) => GameSection(
        title: 'New & Upcoming',
        leadingEmoji: '✨',
        games: games,
        onGameTap: onGameTap,
      ),
    ),
  ];

  final widgets = <Widget>[];
  for (final section in sections) {
    if (section.games.isEmpty) continue;
    widgets.add(section.builder(section.games));
  }
  return widgets;
}

class _HomeSectionDescriptor {
  const _HomeSectionDescriptor({required this.games, required this.builder});

  final List<GameModel> games;
  final Widget Function(List<GameModel> games) builder;
}

class _HomeError extends StatelessWidget {
  const _HomeError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Failed to load games\n$message', textAlign: TextAlign.center),
          Gaps.v12,
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
