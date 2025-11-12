import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/rankable_item.dart';
import '../models/category.dart';
import '../models/question.dart';
import '../models/comparison.dart';
import '../models/item_group.dart';

/// Service to handle local data persistence
class StorageService {
  static const String _itemsKey = 'rankable_items';
  static const String _categoriesKey = 'categories';
  static const String _questionsKey = 'questions';
  static const String _comparisonsKey = 'comparisons';
  static const String _groupsKey = 'item_groups';

  late final SharedPreferences _prefs;
  bool _initialized = false;

  /// Initialize the storage service
  Future<void> initialize() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  /// Ensure the service is initialized
  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError(
        'StorageService not initialized. Call initialize() first.',
      );
    }
  }

  // ==================== Items ====================

  /// Save all items
  Future<bool> saveItems(List<RankableItem> items) async {
    _ensureInitialized();
    final jsonList = items.map((item) => item.toJson()).toList();
    return await _prefs.setString(_itemsKey, jsonEncode(jsonList));
  }

  /// Load all items
  Future<List<RankableItem>> loadItems() async {
    _ensureInitialized();
    final jsonString = _prefs.getString(_itemsKey);
    if (jsonString == null) return [];

    final jsonList = jsonDecode(jsonString) as List;
    return jsonList
        .map((json) => RankableItem.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Clear all items
  Future<bool> clearItems() async {
    _ensureInitialized();
    return await _prefs.remove(_itemsKey);
  }

  // ==================== Categories ====================

  /// Save all categories
  Future<bool> saveCategories(List<Category> categories) async {
    _ensureInitialized();
    final jsonList = categories.map((cat) => cat.toJson()).toList();
    return await _prefs.setString(_categoriesKey, jsonEncode(jsonList));
  }

  /// Load all categories
  Future<List<Category>> loadCategories() async {
    _ensureInitialized();
    final jsonString = _prefs.getString(_categoriesKey);
    if (jsonString == null) return [];

    final jsonList = jsonDecode(jsonString) as List;
    return jsonList
        .map((json) => Category.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Clear all categories
  Future<bool> clearCategories() async {
    _ensureInitialized();
    return await _prefs.remove(_categoriesKey);
  }

  // ==================== Questions ====================

  /// Save all questions
  Future<bool> saveQuestions(List<Question> questions) async {
    _ensureInitialized();
    final jsonList = questions.map((q) => q.toJson()).toList();
    return await _prefs.setString(_questionsKey, jsonEncode(jsonList));
  }

  /// Load all questions
  Future<List<Question>> loadQuestions() async {
    _ensureInitialized();
    final jsonString = _prefs.getString(_questionsKey);
    if (jsonString == null) return [];

    final jsonList = jsonDecode(jsonString) as List;
    return jsonList
        .map((json) => Question.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Clear all questions
  Future<bool> clearQuestions() async {
    _ensureInitialized();
    return await _prefs.remove(_questionsKey);
  }

  // ==================== Comparisons ====================

  /// Save all comparisons
  Future<bool> saveComparisons(List<Comparison> comparisons) async {
    _ensureInitialized();
    final jsonList = comparisons.map((comp) => comp.toJson()).toList();
    return await _prefs.setString(_comparisonsKey, jsonEncode(jsonList));
  }

  /// Load all comparisons
  Future<List<Comparison>> loadComparisons() async {
    _ensureInitialized();
    final jsonString = _prefs.getString(_comparisonsKey);
    if (jsonString == null) return [];

    final jsonList = jsonDecode(jsonString) as List;
    return jsonList
        .map((json) => Comparison.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Clear all comparisons
  Future<bool> clearComparisons() async {
    _ensureInitialized();
    return await _prefs.remove(_comparisonsKey);
  }

  // ==================== Groups ====================

  /// Save all groups
  Future<bool> saveGroups(List<ItemGroup> groups) async {
    _ensureInitialized();
    final jsonList = groups.map((group) => group.toJson()).toList();
    return await _prefs.setString(_groupsKey, jsonEncode(jsonList));
  }

  /// Load all groups
  Future<List<ItemGroup>> loadGroups() async {
    _ensureInitialized();
    final jsonString = _prefs.getString(_groupsKey);
    if (jsonString == null) return [];

    final jsonList = jsonDecode(jsonString) as List;
    return jsonList
        .map((json) => ItemGroup.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Clear all groups
  Future<bool> clearGroups() async {
    _ensureInitialized();
    return await _prefs.remove(_groupsKey);
  }

  // ==================== Clear All ====================

  /// Clear all stored data
  Future<bool> clearAll() async {
    _ensureInitialized();
    await clearItems();
    await clearCategories();
    await clearQuestions();
    await clearComparisons();
    await clearGroups();
    return true;
  }
}
