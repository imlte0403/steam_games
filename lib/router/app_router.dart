import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:steam_games/views/detail/detail_view.dart';
import 'package:steam_games/views/home/home_view.dart';
import 'package:steam_games/views/recommendation/recommendation_view.dart';
import 'package:steam_games/views/search/search_view.dart';
import 'package:steam_games/views/statistics/statistics_view.dart';

// 앱에서 사용할 라우트 이름 정의
enum AppRoute { home, detail, search, statistics, recommendation }

// Riverpod을 통해 주입되는 GoRouter 인스턴스
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoute.home.path,
    routes: [
      GoRoute(
        path: AppRoute.home.path,
        name: AppRoute.home.name,
        builder: (context, state) => const HomeView(),
      ),
      GoRoute(
        path: AppRoute.detail.path,
        name: AppRoute.detail.name,
        builder: (context, state) {
          final appId = state.pathParameters['id'];
          if (appId == null || appId.isEmpty) {
            return const DetailView(appId: '');
          }
          return DetailView(appId: appId);
        },
      ),
      GoRoute(
        path: AppRoute.search.path,
        name: AppRoute.search.name,
        builder: (context, state) => const SearchView(),
      ),
      GoRoute(
        path: AppRoute.statistics.path,
        name: AppRoute.statistics.name,
        builder: (context, state) => const StatisticsView(),
      ),
      GoRoute(
        path: AppRoute.recommendation.path,
        name: AppRoute.recommendation.name,
        builder: (context, state) => const RecommendationView(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page not found')),
      body: Center(child: Text(state.error?.toString() ?? 'Unknown error')),
    ),
  );
});

extension on AppRoute {
  String get path {
    return switch (this) {
      AppRoute.home => '/',
      AppRoute.detail => '/detail/:id',
      AppRoute.search => '/search',
      AppRoute.statistics => '/statistics',
      AppRoute.recommendation => '/recommendation',
    };
  }
}
