import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RecommendationView extends ConsumerWidget {
  const RecommendationView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Recommendation')),
      body: const Center(
        child: Text('AI powered picks will launch in Phase 4.'),
      ),
    );
  }
}
