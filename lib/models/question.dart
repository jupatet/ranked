/// Represents a question for comparing items
class Question {
  final String id;
  final String text;
  final String categoryId;

  Question({required this.id, required this.text, required this.categoryId});

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {'id': id, 'text': text, 'categoryId': categoryId};
  }

  // Create from JSON
  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      text: json['text'] as String,
      categoryId: json['categoryId'] as String,
    );
  }

  Question copyWith({String? id, String? text, String? categoryId}) {
    return Question(
      id: id ?? this.id,
      text: text ?? this.text,
      categoryId: categoryId ?? this.categoryId,
    );
  }
}
