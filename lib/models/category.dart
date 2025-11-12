import 'question.dart';

/// Represents a category with subscores and associated questions
class Category {
  final String id;
  final String name;
  final double weight; // Weight in final calculation (0.0 to 1.0)
  final List<Question> questions;

  Category({
    required this.id,
    required this.name,
    this.weight = 1.0,
    List<Question>? questions,
  }) : questions = questions ?? [];

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'weight': weight,
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }

  // Create from JSON
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      weight: (json['weight'] as num?)?.toDouble() ?? 1.0,
      questions:
          (json['questions'] as List?)
              ?.map((q) => Question.fromJson(q as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Category copyWith({
    String? id,
    String? name,
    double? weight,
    List<Question>? questions,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      weight: weight ?? this.weight,
      questions: questions ?? this.questions,
    );
  }
}
