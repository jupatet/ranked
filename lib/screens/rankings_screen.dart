import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import '../models/rankable_item.dart';
import '../models/category.dart';
import '../models/item_group.dart';

enum SortBy { overall, category }

class RankingsScreen extends StatefulWidget {
  final List<RankableItem> items;
  final List<Category> categories;
  final List<ItemGroup> groups;

  const RankingsScreen({
    super.key,
    required this.items,
    required this.categories,
    required this.groups,
  });

  @override
  State<RankingsScreen> createState() => _RankingsScreenState();
}

class _RankingsScreenState extends State<RankingsScreen> {
  SortBy _sortBy = SortBy.overall;
  String? _selectedCategoryId;
  String? _selectedGroupId;
  bool _showGroupAverages = false; // Toggle between items and group averages

  List<RankableItem> get _sortedItems {
    var filtered = List<RankableItem>.from(widget.items);
    
    // Filter by group if selected
    if (_selectedGroupId != null) {
      if (_selectedGroupId == 'no_group') {
        filtered = filtered.where((item) => item.groupId == null).toList();
      } else {
        filtered = filtered.where((item) => item.groupId == _selectedGroupId).toList();
      }
    }
    
    // Sort
    if (_sortBy == SortBy.overall) {
      filtered.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (_selectedCategoryId != null) {
      filtered.sort((a, b) => b
          .getCategoryRating(_selectedCategoryId!)
          .compareTo(a.getCategoryRating(_selectedCategoryId!)));
    }
    return filtered;
  }

  // Calculate average ratings for groups
  List<MapEntry<ItemGroup, double>> get _groupAverages {
    final Map<String, List<double>> groupRatings = {};
    
    for (var item in widget.items) {
      if (item.groupId != null) {
        groupRatings.putIfAbsent(item.groupId!, () => []).add(
          _sortBy == SortBy.overall 
              ? item.rating 
              : item.getCategoryRating(_selectedCategoryId ?? ''),
        );
      }
    }
    
    final averages = <MapEntry<ItemGroup, double>>[];
    for (var group in widget.groups) {
      final ratings = groupRatings[group.id];
      if (ratings != null && ratings.isNotEmpty) {
        final average = ratings.reduce((a, b) => a + b) / ratings.length;
        averages.add(MapEntry(group, average));
      }
    }
    
    averages.sort((a, b) => b.value.compareTo(a.value));
    return averages;
  }

  IconData _getRankIcon(int rank) {
    switch (rank) {
      case 0:
        return Icons.emoji_events;
      case 1:
        return Icons.emoji_events_outlined;
      case 2:
        return Icons.emoji_events_outlined;
      default:
        return Icons.person;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortedItems = _sortedItems;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button and sort
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const Text(
                    'RANKINGS',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 4,
                      color: Colors.white,
                    ),
                  ),
                  // Filter and Sort controls - all same size as back button
                  Row(
                    children: [
                      // Group average toggle
                      if (widget.groups.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _showGroupAverages = !_showGroupAverages;
                              if (_showGroupAverages) {
                                _selectedGroupId = null; // Clear filter in group average mode
                              }
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 4),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _showGroupAverages
                                  ? Colors.green.withOpacity(0.2)
                                  : Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _showGroupAverages
                                    ? Colors.green.withOpacity(0.5)
                                    : Colors.white.withOpacity(0.1),
                              ),
                            ),
                            child: Icon(
                              Icons.functions,
                              color: _showGroupAverages ? Colors.green : Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      // Group filter (only in items mode)
                      if (widget.groups.isNotEmpty && !_showGroupAverages)
                        Container(
                          margin: const EdgeInsets.only(right: 4),
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: _selectedGroupId != null
                                ? Colors.blue.withOpacity(0.2)
                                : Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _selectedGroupId != null
                                  ? Colors.blue.withOpacity(0.5)
                                  : Colors.white.withOpacity(0.1),
                            ),
                          ),
                          child: PopupMenuButton<String?>(
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              Icons.filter_list,
                              color: _selectedGroupId != null
                                  ? Colors.blue
                                  : Colors.white,
                              size: 20,
                            ),
                            color: const Color(0xFF1A1A1A),
                            onSelected: (value) {
                              setState(() {
                                _selectedGroupId = value;
                              });
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: null,
                                child: Row(
                                  children: [
                                    Icon(Icons.clear, color: Colors.white, size: 18),
                                    SizedBox(width: 8),
                                    Text('All Items', style: TextStyle(color: Colors.white)),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'no_group',
                                child: Row(
                                  children: [
                                    Icon(Icons.folder_off, color: Colors.white, size: 18),
                                    SizedBox(width: 8),
                                    Text('No Group', style: TextStyle(color: Colors.white)),
                                  ],
                                ),
                              ),
                              const PopupMenuDivider(),
                              ...widget.groups.map((group) => PopupMenuItem(
                                    value: group.id,
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 18,
                                          height: 18,
                                          decoration: BoxDecoration(
                                            color: group.color,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Icon(
                                            group.icon,
                                            size: 12,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(group.name, style: const TextStyle(color: Colors.white)),
                                      ],
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      // Sort button
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          icon: const Icon(
                            Icons.sort,
                            color: Colors.white,
                            size: 20,
                          ),
                          color: const Color(0xFF1A1A1A),
                          onSelected: (value) {
                            setState(() {
                              if (value == 'overall') {
                                _sortBy = SortBy.overall;
                                _selectedCategoryId = null;
                              } else {
                                _sortBy = SortBy.category;
                                _selectedCategoryId = value;
                              }
                            });
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'overall',
                              child: Row(
                                children: [
                                  Icon(Icons.star, color: Colors.white, size: 18),
                                  SizedBox(width: 8),
                                  Text('Overall Rating', style: TextStyle(color: Colors.white)),
                                ],
                              ),
                            ),
                            const PopupMenuDivider(),
                            ...widget.categories.map((category) => PopupMenuItem(
                                  value: category.id,
                                  child: Row(
                                    children: [
                                      const Icon(Icons.category, color: Colors.white, size: 18),
                                      const SizedBox(width: 8),
                                      Text(category.name, style: const TextStyle(color: Colors.white)),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: _showGroupAverages
                  ? _buildGroupAveragesView()
                  : sortedItems.isEmpty
                      ? Center(
                          child: FCard(
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.leaderboard_outlined,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No rankings yet',
                                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Start comparing items to see rankings',
                                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          children: [
                // Group filter indicator
                if (_selectedGroupId != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: FCard(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            if (_selectedGroupId == 'no_group')
                              const Icon(Icons.folder_off, size: 20)
                            else
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: widget.groups
                                      .firstWhere((g) => g.id == _selectedGroupId!)
                                      .color,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  widget.groups
                                      .firstWhere((g) => g.id == _selectedGroupId!)
                                      .icon,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            const SizedBox(width: 8),
                            Text(
                              _selectedGroupId == 'no_group'
                                  ? 'Filtered: No Group'
                                  : 'Filtered: ${widget.groups.firstWhere((g) => g.id == _selectedGroupId!).name}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.close, size: 20),
                              onPressed: () {
                                setState(() {
                                  _selectedGroupId = null;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                // Sort indicator
                if (_sortBy == SortBy.category && _selectedCategoryId != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: FCard(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            const Icon(Icons.filter_list, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Sorted by: ${widget.categories.firstWhere((c) => c.id == _selectedCategoryId).name}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.close, size: 20),
                              onPressed: () {
                                setState(() {
                                  _sortBy = SortBy.overall;
                                  _selectedCategoryId = null;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Statistics section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: FCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatItem(
                            icon: Icons.people,
                            label: 'Items',
                            value: widget.items.length.toString(),
                          ),
                          _StatItem(
                            icon: Icons.category,
                            label: 'Categories',
                            value: widget.categories.length.toString(),
                          ),
                          _StatItem(
                            icon: Icons.compare_arrows,
                            label: 'Total Comparisons',
                            value: widget.items
                                .fold(0, (sum, item) => sum + item.comparisons)
                                .toString(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Top 3 podium
                if (sortedItems.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: FCard(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Top 3',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // 2nd place
                                if (sortedItems.length > 1)
                                  _PodiumItem(
                                    item: sortedItems[1],
                                    rank: 2,
                                    height: 80,
                                  ),
                                // 1st place
                                if (sortedItems.isNotEmpty)
                                  _PodiumItem(
                                    item: sortedItems[0],
                                    rank: 1,
                                    height: 120,
                                  ),
                                // 3rd place
                                if (sortedItems.length > 2)
                                  _PodiumItem(
                                    item: sortedItems[2],
                                    rank: 3,
                                    height: 60,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // Full rankings list
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Complete Rankings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Rankings list items
                ...List.generate(sortedItems.length, (index) {
                  final item = sortedItems[index];
                  final rank = index;

                  return TweenAnimationBuilder<double>(
                    key: ValueKey(item.id),
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: Duration(milliseconds: 400 + (index * 50)),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 30 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 12.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: ExpansionTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: rank < 3 ? Colors.white : Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                              ),
                            ),
                            child: Center(
                              child: rank < 3
                                  ? Icon(
                                      _getRankIcon(rank),
                                      color: Colors.black,
                                      size: 18,
                                    )
                                  : Text(
                                      '${rank + 1}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w300,
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 14,
                                      ),
                                    ),
                            ),
                          ),
                          title: Text(
                            item.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              children: [
                                Text(
                                  item.rating.toStringAsFixed(0),
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '•',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${item.comparisons} comparisons',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          iconColor: Colors.white.withOpacity(0.5),
                          collapsedIconColor: Colors.white.withOpacity(0.5),
                          children: [
                            if (item.categoryRatings.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Category Scores',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    ...widget.categories.map((category) {
                                      final categoryRating =
                                          item.getCategoryRating(category.id);
                                      final categoryComparisons =
                                          item.getCategoryComparisons(category.id);
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 12.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  category.name,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                Text(
                                                  categoryRating.toStringAsFixed(0),
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            LinearProgressIndicator(
                                              value: (categoryRating - 800) / 400,
                                              backgroundColor: Colors.grey[300],
                                              minHeight: 8,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '$categoryComparisons comparisons • Weight: ${category.weight}x',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 24), // Bottom padding
              ],
            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupAveragesView() {
    final groupAverages = _groupAverages;
    
    if (groupAverages.isEmpty) {
      return Center(
        child: FCard(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.folder_open,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No groups with items',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Assign items to groups to see group averages',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      children: [
        const SizedBox(height: 16),
        // Info banner
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: FCard(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 20, color: Colors.blue[300]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Showing group averages based on item ratings',
                      style: TextStyle(fontSize: 14, color: Colors.grey[300]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Group average cards
        ...groupAverages.asMap().entries.map((entry) {
          final rank = entry.key + 1;
          final groupEntry = entry.value;
          final group = groupEntry.key;
          final average = groupEntry.value;
          
          // Count items in this group
          final itemsInGroup = widget.items.where((item) => item.groupId == group.id).length;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: FCard(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Rank badge
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: rank <= 3
                            ? (rank == 1 ? Colors.amber : rank == 2 ? Colors.grey : Colors.brown)
                            : Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '$rank',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Group icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: group.color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        group.icon,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Group info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            group.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$itemsInGroup item${itemsInGroup == 1 ? '' : 's'}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Average rating
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              average.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Average',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 24), // Bottom padding
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.blue),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}

class _PodiumItem extends StatelessWidget {
  final RankableItem item;
  final int rank;
  final double height;

  const _PodiumItem({
    required this.item,
    required this.rank,
    required this.height,
  });

  Color get _color {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey[400]!;
      case 3:
        return Colors.brown[300]!;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: rank == 1 ? 32 : 24,
          backgroundColor: _color,
          child: Text(
            item.name[0].toUpperCase(),
            style: TextStyle(
              fontSize: rank == 1 ? 24 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 80,
          child: Text(
            item.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: rank == 1 ? 14 : 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          item.rating.toStringAsFixed(0),
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            color: _color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: Center(
            child: Text(
              '$rank',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
