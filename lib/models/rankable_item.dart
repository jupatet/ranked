/// Represents a person or object that can be ranked
class RankableItem {
  final String id;
  final String name;
  double rating; // Overall ELO rating
  int comparisons; // Number of times compared
  Map<String, double> categoryRatings; // Per-category subscores (categoryId -> rating)
  Map<String, int> categoryComparisons; // Per-category comparison counts
  String? groupId; // Optional group assignment (null for backward compatibility)

  RankableItem({
    required this.id,
    required this.name,
    this.rating = 1000.0, // Default ELO rating
    this.comparisons = 0,
    Map<String, double>? categoryRatings,
    Map<String, int>? categoryComparisons,
    this.groupId,
  })  : categoryRatings = categoryRatings ?? {},
        categoryComparisons = categoryComparisons ?? {};

  // Get rating for specific category (returns 1000 if not yet rated)
  double getCategoryRating(String categoryId) {
    return categoryRatings[categoryId] ?? 1000.0;
  }

  // Get comparison count for specific category
  int getCategoryComparisons(String categoryId) {
    return categoryComparisons[categoryId] ?? 0;
  }

  // Update category rating
  void updateCategoryRating(String categoryId, double newRating) {
    categoryRatings[categoryId] = newRating;
    categoryComparisons[categoryId] = (categoryComparisons[categoryId] ?? 0) + 1;
  }

  // Calculate overall rating as weighted average
  double calculateOverallRating(Map<String, double> categoryWeights) {
    if (categoryRatings.isEmpty) return 1000.0;

    double totalWeightedRating = 0.0;
    double totalWeight = 0.0;

    for (final entry in categoryRatings.entries) {
      final categoryId = entry.key;
      final rating = entry.value;
      final weight = categoryWeights[categoryId] ?? 1.0;

      totalWeightedRating += rating * weight;
      totalWeight += weight;
    }

    return totalWeight > 0 ? totalWeightedRating / totalWeight : 1000.0;
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'rating': rating,
      'comparisons': comparisons,
      'categoryRatings': categoryRatings,
      'categoryComparisons': categoryComparisons,
      'groupId': groupId, // Save group assignment
    };
  }

  // Create from JSON
  factory RankableItem.fromJson(Map<String, dynamic> json) {
    return RankableItem(
      id: json['id'] as String,
      name: json['name'] as String,
      rating: (json['rating'] as num?)?.toDouble() ?? 1000.0,
      comparisons: (json['comparisons'] as num?)?.toInt() ?? 0,
      categoryRatings: (json['categoryRatings'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, (v as num).toDouble())) ??
          {},
      categoryComparisons: (json['categoryComparisons'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, (v as num).toInt())) ??
          {},
      groupId: json['groupId'] as String?, // Load group (nullable for old data)
    );
  }

  RankableItem copyWith({
    String? id,
    String? name,
    double? rating,
    int? comparisons,
    Map<String, double>? categoryRatings,
    Map<String, int>? categoryComparisons,
    String? groupId,
  }) {
    return RankableItem(
      id: id ?? this.id,
      name: name ?? this.name,
      rating: rating ?? this.rating,
      comparisons: comparisons ?? this.comparisons,
      categoryRatings: categoryRatings ?? Map<String, double>.from(this.categoryRatings),
      categoryComparisons: categoryComparisons ?? Map<String, int>.from(this.categoryComparisons),
      groupId: groupId ?? this.groupId,
    );
  }
}
