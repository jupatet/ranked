/// Represents a comparison result between two items
class Comparison {
  final String id;
  final String questionId;
  final String winnerId;
  final String loserId;
  final DateTime timestamp;

  Comparison({
    required this.id,
    required this.questionId,
    required this.winnerId,
    required this.loserId,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'questionId': questionId,
      'winnerId': winnerId,
      'loserId': loserId,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Create from JSON
  factory Comparison.fromJson(Map<String, dynamic> json) {
    return Comparison(
      id: json['id'] as String,
      questionId: json['questionId'] as String,
      winnerId: json['winnerId'] as String,
      loserId: json['loserId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
