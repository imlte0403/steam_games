import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:steam_games/core/constants/gaps.dart';
import 'package:steam_games/core/constants/sizes.dart';
import 'package:steam_games/router/app_router.dart';
import 'package:steam_games/views/home/home_view_model.dart';
import 'package:steam_games/views/home/widgets/game_section.dart';

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
        data: (data) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(homeSectionsProvider);
            await ref.read(homeSectionsProvider.future);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: Sizes.size16,
              vertical: Sizes.size24,
            ),
            children: [
              GameSection(
                title: 'Popular Games',
                games: data.popular,
                onGameTap: (game) => _openDetail(context, game.appId),
              ),
              Gaps.v32,
              GameSection(
                title: 'Discounted Picks',
                games: data.discounted,
                onGameTap: (game) => _openDetail(context, game.appId),
              ),
              Gaps.v32,
              GameSection(
                title: 'Free to Play',
                games: data.freeToPlay,
                onGameTap: (game) => _openDetail(context, game.appId),
              ),
              Gaps.v32,
              GameSection(
                title: 'New & Upcoming',
                games: data.newReleases,
                onGameTap: (game) => _openDetail(context, game.appId),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
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
