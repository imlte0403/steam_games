import 'package:flutter/foundation.dart';

@immutable
class GameModel {
  const GameModel({
    required this.appId,
    required this.name,
    required this.headerImage,
    required this.screenshots,
    required this.description,
    required this.releaseDate,
    required this.releaseYear,
    required this.developers,
    required this.publishers,
    required this.genres,
    required this.tags,
    required this.originalPrice,
    required this.discountPercent,
    required this.finalPrice,
    required this.isFree,
    required this.supportedLanguages,
    required this.platforms,
    required this.categories,
    required this.steamDeckCompatibility,
    required this.controllerSupport,
    required this.metacriticScore,
    required this.hasDLC,
    required this.isComingSoon,
    required this.reviewScore,
    required this.totalPositive,
    required this.totalNegative,
    required this.totalReviews,
  });

  final String appId;
  final String name;
  final String headerImage;
  final List<String> screenshots;
  final String description;
  final String releaseDate;
  final String releaseYear;
  final List<String> developers;
  final List<String> publishers;
  final List<String> genres;
  final List<String> tags;
  final String originalPrice;
  final int discountPercent;
  final String finalPrice;
  final bool isFree;
  final String supportedLanguages;
  final List<String> platforms;
  final List<String> categories;
  final String steamDeckCompatibility;
  final String controllerSupport;
  final int? metacriticScore;
  final bool hasDLC;
  final bool isComingSoon;

  final String reviewScore;
  final int totalPositive;
  final int totalNegative;
  final int totalReviews;
}
