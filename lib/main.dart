import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:steam_games/router/app_router.dart';

void main() {
  runApp(const ProviderScope(child: SteamGameApp()));
}

class SteamGameApp extends ConsumerWidget {
  const SteamGameApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Steam Game Explorer',
      routerConfig: router,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        textTheme: const TextTheme(
          // 섹션 제목
          titleLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
          // 게임 제목 (카드)
          titleMedium: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          titleSmall: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          // 가격 (현재가)
          headlineSmall: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          // 가격 (작은 카드)
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          // 원가 (취소선)
          bodySmall: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.normal,
          ),
          // 추가 정보
          labelMedium: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
