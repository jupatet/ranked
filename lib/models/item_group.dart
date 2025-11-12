import 'package:flutter/material.dart';

/// Available icons for groups
enum GroupIcon {
  folder,
  star,
  favorite,
  work,
  school,
  sports,
  movie,
  music,
  restaurant,
  cafe,
}

/// Extension to convert GroupIcon to IconData
extension GroupIconExtension on GroupIcon {
  IconData get iconData {
    switch (this) {
      case GroupIcon.folder:
        return Icons.folder;
      case GroupIcon.star:
        return Icons.star;
      case GroupIcon.favorite:
        return Icons.favorite;
      case GroupIcon.work:
        return Icons.work;
      case GroupIcon.school:
        return Icons.school;
      case GroupIcon.sports:
        return Icons.sports_soccer;
      case GroupIcon.movie:
        return Icons.movie;
      case GroupIcon.music:
        return Icons.music_note;
      case GroupIcon.restaurant:
        return Icons.restaurant;
      case GroupIcon.cafe:
        return Icons.local_cafe;
    }
  }
}

/// Represents a group/category for organizing items
class ItemGroup {
  final String id;
  final String name;
  final Color color;
  final GroupIcon groupIcon;
  double rating;
  int comparisons;
  Map<String, double> categoryRatings;
  Map<String, int> categoryComparisons;

  ItemGroup({
    required this.id,
    required this.name,
    required this.color,
    this.groupIcon = GroupIcon.folder,
    this.rating = 1000.0,
    this.comparisons = 0,
    Map<String, double>? categoryRatings,
    Map<String, int>? categoryComparisons,
  })  : categoryRatings = categoryRatings ?? {},
        categoryComparisons = categoryComparisons ?? {};

  /// Get the IconData for display
  IconData get icon => groupIcon.iconData;

  double getCategoryRating(String categoryId) {
    return categoryRatings[categoryId] ?? 1000.0;
  }

  int getCategoryComparisons(String categoryId) {
    return categoryComparisons[categoryId] ?? 0;
  }

  void updateCategoryRating(String categoryId, double rating) {
    categoryRatings[categoryId] = rating;
    categoryComparisons[categoryId] = (categoryComparisons[categoryId] ?? 0) + 1;
  }

  double calculateOverallRating(Map<String, double> categoryWeights) {
    if (categoryRatings.isEmpty) return 1000.0;

    double totalWeightedRating = 0.0;
    double totalWeight = 0.0;

    categoryRatings.forEach((categoryId, rating) {
      final weight = categoryWeights[categoryId] ?? 1.0;
      totalWeightedRating += rating * weight;
      totalWeight += weight;
    });

    return totalWeight > 0 ? totalWeightedRating / totalWeight : 1000.0;
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color.value,
      'icon': groupIcon.index,
      'rating': rating,
      'comparisons': comparisons,
      'categoryRatings': categoryRatings,
      'categoryComparisons': categoryComparisons,
    };
  }

  // Create from JSON
  factory ItemGroup.fromJson(Map<String, dynamic> json) {
    final iconIndex = json['icon'] as int? ?? 0;
    return ItemGroup(
      id: json['id'] as String,
      name: json['name'] as String,
      color: Color(json['color'] as int),
      groupIcon: GroupIcon.values[iconIndex.clamp(0, GroupIcon.values.length - 1)],
      rating: (json['rating'] as num?)?.toDouble() ?? 1000.0,
      comparisons: json['comparisons'] as int? ?? 0,
      categoryRatings: Map<String, double>.from(
        (json['categoryRatings'] as Map<String, dynamic>?)?.map(
              (key, value) => MapEntry(key, (value as num).toDouble()),
            ) ??
            {},
      ),
      categoryComparisons: Map<String, int>.from(
        (json['categoryComparisons'] as Map<String, dynamic>?)?.map(
              (key, value) => MapEntry(key, value as int),
            ) ??
            {},
      ),
    );
  }

  ItemGroup copyWith({
    String? name,
    Color? color,
    GroupIcon? groupIcon,
    double? rating,
    int? comparisons,
    Map<String, double>? categoryRatings,
    Map<String, int>? categoryComparisons,
  }) {
    return ItemGroup(
      id: id,
      name: name ?? this.name,
      color: color ?? this.color,
      groupIcon: groupIcon ?? this.groupIcon,
      rating: rating ?? this.rating,
      comparisons: comparisons ?? this.comparisons,
      categoryRatings: categoryRatings ?? Map.from(this.categoryRatings),
      categoryComparisons: categoryComparisons ?? Map.from(this.categoryComparisons),
    );
  }
}
