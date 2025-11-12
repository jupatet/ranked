import 'package:cloud_firestore/cloud_firestore.dart';
import 'category.dart';
import 'rankable_item.dart';
import 'item_group.dart';

class Ranking {
  final String id;
  final String name;
  final String ownerId;
  final List<Category> categories;
  final List<RankableItem> items;
  final List<ItemGroup> groups;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPublic;
  final List<String> collaboratorIds;

  Ranking({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.categories,
    required this.items,
    List<ItemGroup>? groups,
    required this.createdAt,
    required this.updatedAt,
    this.isPublic = false,
    this.collaboratorIds = const [],
  }) : groups = groups ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'ownerId': ownerId,
      'categories': categories.map((c) => c.toJson()).toList(),
      'items': items.map((i) => i.toJson()).toList(),
      'groups': groups.map((g) => g.toJson()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isPublic': isPublic,
      'collaboratorIds': collaboratorIds,
    };
  }

  factory Ranking.fromJson(Map<String, dynamic> json) {
    try {
      return Ranking(
        id: json['id'] as String,
        name: json['name'] as String,
        ownerId: json['ownerId'] as String,
        categories: (json['categories'] as List?)
                ?.map((c) => Category.fromJson(c as Map<String, dynamic>))
                .toList() ??
            [],
        items: (json['items'] as List?)
                ?.map((i) => RankableItem.fromJson(i as Map<String, dynamic>))
                .toList() ??
            [],
        groups: (json['groups'] as List?)
                ?.map((g) => ItemGroup.fromJson(g as Map<String, dynamic>))
                .toList() ??
            [],
        createdAt: (json['createdAt'] as Timestamp).toDate(),
        updatedAt: (json['updatedAt'] as Timestamp).toDate(),
        isPublic: json['isPublic'] as bool? ?? false,
        collaboratorIds: (json['collaboratorIds'] as List?)
                ?.map((e) => e as String)
                .toList() ??
            [],
      );
    } catch (e, stackTrace) {
      print('Error parsing Ranking from JSON: $e');
      print('JSON data: $json');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Ranking copyWith({
    String? name,
    List<Category>? categories,
    List<RankableItem>? items,
    List<ItemGroup>? groups,
    DateTime? updatedAt,
    bool? isPublic,
    List<String>? collaboratorIds,
  }) {
    return Ranking(
      id: id,
      name: name ?? this.name,
      ownerId: ownerId,
      categories: categories ?? this.categories,
      items: items ?? this.items,
      groups: groups ?? this.groups,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPublic: isPublic ?? this.isPublic,
      collaboratorIds: collaboratorIds ?? this.collaboratorIds,
    );
  }
}
