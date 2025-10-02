import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../views/home/home_view.dart';

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
      // TODO: 상세/검색/통계/추천 라우트 추가
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
