import 'package:flutter/material.dart';
import '../models/rankable_item.dart';
import '../models/category.dart';
import '../models/question.dart';
import '../models/comparison.dart';
import '../models/ranking.dart';
import '../models/item_group.dart';
import '../services/storage_service.dart';
import '../services/elo_service.dart';
import '../services/firebase_service.dart';
import 'items_setup_screen.dart';
import 'categories_setup_screen.dart';
import 'comparison_screen.dart';
import 'rankings_screen.dart';
import 'rankings_manager_screen.dart';
import 'groups_manager_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final StorageService _storage = StorageService();
  final FirebaseService _firebaseService = FirebaseService();
  List<RankableItem> _items = [];
  List<Category> _categories = [];
  List<Comparison> _comparisons = [];
  List<ItemGroup> _groups = [];
  bool _isLoading = true;
  String? _currentCloudRankingId; // Track active cloud ranking
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    
    _glowAnimation = Tween<double>(begin: 0.2, end: 0.5).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    
    _initializeApp();
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    await _storage.initialize();
    await _loadData();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadData() async {
    final items = await _storage.loadItems();
    final categories = await _storage.loadCategories();
    final comparisons = await _storage.loadComparisons();
    final groups = await _storage.loadGroups();

    setState(() {
      _items = items;
      _categories = categories;
      _comparisons = comparisons;
      _groups = groups;
    });
  }

  Future<void> _saveItems() async {
    await _storage.saveItems(_items);
    
    // Sync to Firebase if working with a cloud ranking
    if (_currentCloudRankingId != null) {
      try {
        final ranking = await _firebaseService.getRanking(_currentCloudRankingId!);
        if (ranking != null) {
          await _firebaseService.updateRanking(
            ranking.copyWith(
              items: _items,
              updatedAt: DateTime.now(),
            ),
          );
          print('Synced items to cloud ranking: $_currentCloudRankingId');
        }
      } catch (e) {
        print('Failed to sync items to cloud: $e');
      }
    }
  }

  Future<void> _saveCategories() async {
    await _storage.saveCategories(_categories);
    
    // Sync to Firebase if working with a cloud ranking
    if (_currentCloudRankingId != null) {
      try {
        final ranking = await _firebaseService.getRanking(_currentCloudRankingId!);
        if (ranking != null) {
          await _firebaseService.updateRanking(
            ranking.copyWith(
              categories: _categories,
              updatedAt: DateTime.now(),
            ),
          );
          print('Synced categories to cloud ranking: $_currentCloudRankingId');
        }
      } catch (e) {
        print('Failed to sync categories to cloud: $e');
      }
    }
  }

  Future<void> _saveComparisons() async {
    await _storage.saveComparisons(_comparisons);
  }

  Future<void> _saveGroups() async {
    await _storage.saveGroups(_groups);
    
    // Sync to Firebase if working with a cloud ranking
    if (_currentCloudRankingId != null) {
      try {
        final ranking = await _firebaseService.getRanking(_currentCloudRankingId!);
        if (ranking != null) {
          await _firebaseService.updateRanking(
            ranking.copyWith(
              groups: _groups,
              updatedAt: DateTime.now(),
            ),
          );
          print('Synced groups to cloud ranking: $_currentCloudRankingId');
        }
      } catch (e) {
        print('Failed to sync groups to cloud: $e');
      }
    }
  }

  void _navigateToItemsSetup() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemsSetupScreen(
          items: _items,
          groups: _groups,
          onItemsChanged: (items) {
            setState(() {
              _items = items;
            });
            _saveItems();
          },
        ),
      ),
    );
  }

  void _navigateToCategoriesSetup() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoriesSetupScreen(
          categories: _categories,
          onCategoriesChanged: (categories) {
            setState(() {
              _categories = categories;
            });
            _saveCategories();
          },
        ),
      ),
    );
  }

  void _navigateToComparison() async {
    if (_items.length < 2) {
      _showError('You need at least 2 items to compare');
      return;
    }

    final totalQuestions = _categories.fold(
      0,
      (sum, cat) => sum + cat.questions.length,
    );

    if (totalQuestions == 0) {
      _showError('You need at least 1 question to compare');
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ComparisonScreen(
          items: _items,
          categories: _categories,
          onComparison: _handleComparison,
        ),
      ),
    );
  }

  void _navigateToRankings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RankingsScreen(
          items: _items,
          categories: _categories,
          groups: _groups,
        ),
      ),
    );
  }

  void _navigateToGroupsManager() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupsManagerScreen(
          groups: _groups,
          onGroupsChanged: (groups) {
            setState(() {
              _groups = groups;
            });
            _saveGroups();
          },
        ),
      ),
    );
  }

  void _navigateToRankingsManager() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RankingsManagerScreen(),
      ),
    );
    
    // If a ranking was selected, load it
    if (result != null && result is Ranking) {
      await _loadCloudRanking(result);
    }
  }

  Future<void> _loadCloudRanking(Ranking ranking) async {
    setState(() {
      _items = ranking.items;
      _categories = ranking.categories;
      _groups = ranking.groups;
      _currentCloudRankingId = ranking.id; // Track this ranking
      _isLoading = false;
    });

    // Save locally
    await _saveItems();
    await _saveCategories();
    await _saveGroups();

    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Loaded "${ranking.name}" (Cloud Sync Active)'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _handleComparison(
    RankableItem winner,
    RankableItem loser,
    Question question,
    Function(RankableItem, RankableItem) updateCallback,
  ) {
    // Find the category for this question
    final category = _categories.firstWhere(
      (cat) => cat.id == question.categoryId,
      orElse: () => _categories.first,
    );

    // Update category-specific ratings using ELO system
    final winnerCategoryRating = winner.getCategoryRating(category.id);
    final loserCategoryRating = loser.getCategoryRating(category.id);

    final (updatedWinnerCategoryRating, updatedLoserCategoryRating) =
        EloService.updateRatingsRaw(
      winnerRating: winnerCategoryRating,
      loserRating: loserCategoryRating,
      winnerComparisons: winner.getCategoryComparisons(category.id),
      loserComparisons: loser.getCategoryComparisons(category.id),
    );

    // Update items with new category ratings
    final updatedWinner = winner.copyWith();
    updatedWinner.updateCategoryRating(category.id, updatedWinnerCategoryRating);

    final updatedLoser = loser.copyWith();
    updatedLoser.updateCategoryRating(category.id, updatedLoserCategoryRating);

    // Recalculate overall ratings based on category weights
    final categoryWeights = {
      for (var cat in _categories) cat.id: cat.weight,
    };
    updatedWinner.rating = updatedWinner.calculateOverallRating(categoryWeights);
    updatedWinner.comparisons++;

    updatedLoser.rating = updatedLoser.calculateOverallRating(categoryWeights);
    updatedLoser.comparisons++;

    // Update items in the list
    setState(() {
      final winnerIndex = _items.indexWhere((item) => item.id == winner.id);
      final loserIndex = _items.indexWhere((item) => item.id == loser.id);

      if (winnerIndex != -1) {
        _items[winnerIndex] = updatedWinner;
      }
      if (loserIndex != -1) {
        _items[loserIndex] = updatedLoser;
      }

      // Record the comparison
      final comparison = Comparison(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        questionId: question.id,
        winnerId: winner.id,
        loserId: loser.id,
      );
      _comparisons.add(comparison);
    });

    _saveItems();
    _saveComparisons();
    updateCallback(updatedWinner, updatedLoser);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _resetData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset All Data?'),
        content: const Text(
          'This will delete all items, categories, questions, and comparisons. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _storage.clearAll();
      setState(() {
        _items = [];
        _categories = [];
        _comparisons = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        ),
      );
    }

    final totalQuestions = _categories.fold(
      0,
      (sum, cat) => sum + cat.questions.length,
    );

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // App header - centered icon
                const SizedBox(height: 40),
                Center(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.elasticOut,
                    builder: (context, scaleValue, child) {
                      return Transform.scale(
                        scale: scaleValue,
                        child: AnimatedBuilder(
                          animation: _glowAnimation,
                          builder: (context, child) {
                            return Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(_glowAnimation.value),
                                    blurRadius: 20 + (_glowAnimation.value * 30),
                                    spreadRadius: 5 + (_glowAnimation.value * 15),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.emoji_events,
                                size: 48,
                                color: Colors.black,
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'RANKED',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w200,
                    letterSpacing: 8,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'ELO Rating System',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 2,
                    color: Colors.white.withOpacity(0.5),
                  ),
                  textAlign: TextAlign.center,
                ),

                // Small reset button aligned to the right to reference _resetData
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    tooltip: 'Reset All Data',
                    icon: Icon(
                      Icons.delete_forever,
                      color: Colors.white.withOpacity(0.6),
                    ),
                    onPressed: _resetData,
                  ),
                ),

                const SizedBox(height: 48),

                // Statistics
                Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatCard(
                        icon: Icons.people_outline,
                        label: 'Items',
                        value: _items.length,
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.white.withOpacity(0.1),
                      ),
                      _StatCard(
                        icon: Icons.category_outlined,
                        label: 'Categories',
                        value: _categories.length,
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.white.withOpacity(0.1),
                      ),
                      _StatCard(
                        icon: Icons.quiz_outlined,
                        label: 'Questions',
                        value: totalQuestions,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                _MenuCard(
                  icon: Icons.people_outline,
                  title: 'Manage Items',
                  subtitle: 'Add people or objects to rank',
                  onTap: _navigateToItemsSetup,
                  trailing: Text(
                    '${_items.length}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                _MenuCard(
                  icon: Icons.category_outlined,
                  title: 'Categories & Questions',
                  subtitle: 'Set up comparison criteria',
                  onTap: _navigateToCategoriesSetup,
                  trailing: Text(
                    '$totalQuestions',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                _MenuCard(
                  icon: Icons.folder_outlined,
                  title: 'Manage Groups',
                  subtitle: 'Organize items into groups',
                  onTap: _navigateToGroupsManager,
                  trailing: Text(
                    '${_groups.length}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                _MenuCard(
                  icon: Icons.cloud_outlined,
                  title: 'Cloud Rankings',
                  subtitle: 'Manage & share rankings',
                  onTap: _navigateToRankingsManager,
                  trailing: Icon(
                    Icons.chevron_right,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),

                const SizedBox(height: 48),

                // Actions
                _AnimatedButton(
                  onPressed: _items.length >= 2 && totalQuestions >= 1
                      ? _navigateToComparison
                      : null,
                  label: 'COMPARE ITEMS',
                  icon: Icons.compare_arrows,
                  isPrimary: true,
                ),
                
                const SizedBox(height: 16),
                
                _AnimatedButton(
                  onPressed: _items.isNotEmpty ? _navigateToRankings : null,
                  label: 'VIEW RANKINGS',
                  icon: Icons.leaderboard_outlined,
                  isPrimary: false,
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 12),
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w200,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w300,
            letterSpacing: 1,
            color: Colors.white.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}

class _MenuCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  @override
  State<_MenuCard> createState() => _MenuCardState();
}

class _MenuCardState extends State<_MenuCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(_isHovered ? 1.02 : 1.0),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(_isHovered ? 0.2 : 0.1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(widget.icon, size: 28, color: Colors.white),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                widget.trailing ?? Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.white.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String label;
  final IconData icon;
  final bool isPrimary;

  const _AnimatedButton({
    required this.onPressed,
    required this.label,
    required this.icon,
    required this.isPrimary,
  });

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 64,
          decoration: BoxDecoration(
            color: widget.isPrimary
                ? (isEnabled ? Colors.white : Colors.white.withOpacity(0.3))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(32),
            border: widget.isPrimary
                ? null
                : Border.all(
                    color: isEnabled
                        ? Colors.white.withOpacity(0.3)
                        : Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
            boxShadow: widget.isPrimary && _isHovered && isEnabled
                ? [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                color: widget.isPrimary
                    ? (isEnabled ? Colors.black : Colors.black.withOpacity(0.3))
                    : (isEnabled ? Colors.white : Colors.white.withOpacity(0.3)),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 2,
                  color: widget.isPrimary
                      ? (isEnabled ? Colors.black : Colors.black.withOpacity(0.3))
                      : (isEnabled ? Colors.white : Colors.white.withOpacity(0.3)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
