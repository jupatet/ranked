import 'package:flutter/material.dart';
import 'dart:math';
import '../models/rankable_item.dart';
import '../models/category.dart';
import '../models/question.dart';

class ComparisonScreen extends StatefulWidget {
  final List<RankableItem> items;
  final List<Category> categories;
  final Function(
    RankableItem,
    RankableItem,
    Question,
    Function(RankableItem, RankableItem),
  )
  onComparison;

  const ComparisonScreen({
    super.key,
    required this.items,
    required this.categories,
    required this.onComparison,
  });

  @override
  State<ComparisonScreen> createState() => _ComparisonScreenState();
}

class _ComparisonScreenState extends State<ComparisonScreen>
    with SingleTickerProviderStateMixin {
  late List<Question> _allQuestions;
  late List<RankableItem> _items;
  Question? _currentQuestion;
  RankableItem? _leftItem;
  RankableItem? _rightItem;

  double _dragOffset = 0;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  
  // Track all comparisons made: Set of "questionId:item1Id:item2Id"
  final Set<String> _comparisonHistory = {};

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.items);
    _allQuestions = widget.categories
        .expand((category) => category.questions)
        .toList();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _nextComparison();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Hybrid selection: Pick from least-compared items, then choose closest ratings
  (RankableItem, RankableItem)? _selectNextPair() {
    if (_items.length < 2) return null;

    // Find median comparison count
    final sortedByComparisons = List<RankableItem>.from(_items)
      ..sort((a, b) => a.comparisons.compareTo(b.comparisons));
    
    final medianIndex = sortedByComparisons.length ~/ 2;
    final medianComparisons = sortedByComparisons[medianIndex].comparisons;

    // Get bottom 50% (least-compared items)
    final leastCompared = _items
        .where((item) => item.comparisons <= medianComparisons)
        .toList();

    // Need at least 2 items to compare
    if (leastCompared.length < 2) {
      // Fallback: just use all items
      return _findClosestRatingPair(_items);
    }

    // Among least-compared, find pair with closest ratings
    return _findClosestRatingPair(leastCompared);
  }

  /// Find the pair with the closest ratings from a list of items
  (RankableItem, RankableItem)? _findClosestRatingPair(List<RankableItem> items) {
    if (items.length < 2) return null;

    RankableItem? bestItem1;
    RankableItem? bestItem2;
    double smallestDiff = double.infinity;

    // Check all pairs to find closest ratings
    for (int i = 0; i < items.length; i++) {
      for (int j = i + 1; j < items.length; j++) {
        final diff = (items[i].rating - items[j].rating).abs();
        if (diff < smallestDiff) {
          smallestDiff = diff;
          bestItem1 = items[i];
          bestItem2 = items[j];
        }
      }
    }

    if (bestItem1 == null || bestItem2 == null) return null;

    // Randomize which item appears on left vs right
    final random = Random();
    return random.nextBool() 
        ? (bestItem1, bestItem2) 
        : (bestItem2, bestItem1);
  }

  String _makeComparisonKey(String questionId, String item1Id, String item2Id) {
    // Sort item IDs to ensure "A vs B" = "B vs A"
    final sortedIds = [item1Id, item2Id]..sort();
    return '$questionId:${sortedIds[0]}:${sortedIds[1]}';
  }

  bool _hasBeenCompared(Question question, RankableItem item1, RankableItem item2) {
    final key = _makeComparisonKey(question.id, item1.id, item2.id);
    return _comparisonHistory.contains(key);
  }

  void _markAsCompared(Question question, RankableItem item1, RankableItem item2) {
    final key = _makeComparisonKey(question.id, item1.id, item2.id);
    _comparisonHistory.add(key);
  }

  int _getTotalPossibleComparisons() {
    final numItems = _items.length;
    final numQuestions = _allQuestions.length;
    // Number of unique pairs = n*(n-1)/2
    final numPairs = (numItems * (numItems - 1)) ~/ 2;
    return numPairs * numQuestions;
  }

  void _nextComparison() {
    if (_allQuestions.isEmpty || _items.length < 2) {
      setState(() {
        _currentQuestion = null;
        _leftItem = null;
        _rightItem = null;
      });
      return;
    }

    final random = Random();
    
    // Check if we've exhausted all possible comparisons
    final totalPossible = _getTotalPossibleComparisons();
    if (_comparisonHistory.length >= totalPossible) {
      // Reset history when all combinations have been used
      _comparisonHistory.clear();
    }

    // Find an uncompared question-pair combination
    Question? selectedQuestion;
    RankableItem? item1;
    RankableItem? item2;
    
    int maxAttempts = 100; // Prevent infinite loop
    int attempts = 0;
    
    while (attempts < maxAttempts) {
      attempts++;
      
      // Pick random question
      final testQuestion = _allQuestions[random.nextInt(_allQuestions.length)];
      
      // Pick random pair
      final pair = _selectNextPair();
      RankableItem testItem1, testItem2;
      
      if (pair == null) {
        final shuffledItems = List<RankableItem>.from(_items)..shuffle();
        testItem1 = shuffledItems[0];
        testItem2 = shuffledItems[1];
      } else {
        testItem1 = pair.$1;
        testItem2 = pair.$2;
      }
      
      // Check if this combination has been used
      if (!_hasBeenCompared(testQuestion, testItem1, testItem2)) {
        selectedQuestion = testQuestion;
        item1 = testItem1;
        item2 = testItem2;
        break;
      }
    }
    
    // If we couldn't find an unused combination (shouldn't happen after reset), use any
    if (selectedQuestion == null || item1 == null || item2 == null) {
      selectedQuestion = _allQuestions[random.nextInt(_allQuestions.length)];
      final pair = _selectNextPair();
      if (pair == null) {
        final shuffledItems = List<RankableItem>.from(_items)..shuffle();
        item1 = shuffledItems[0];
        item2 = shuffledItems[1];
      } else {
        item1 = pair.$1;
        item2 = pair.$2;
      }
    }

    setState(() {
      _currentQuestion = selectedQuestion;
      _leftItem = item1;
      _rightItem = item2;
      _dragOffset = 0;
    });
  }

  void _selectWinner(RankableItem winner, RankableItem loser) {
    // Mark this comparison as completed
    if (_currentQuestion != null && _leftItem != null && _rightItem != null) {
      _markAsCompared(_currentQuestion!, _leftItem!, _rightItem!);
    }
    
    // Call the callback and get updated items
    widget.onComparison(winner, loser, _currentQuestion!, (
      updatedWinner,
      updatedLoser,
    ) {
      // Update local items list (use post-frame callback to avoid nested setState)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            final winnerIndex =
                _items.indexWhere((item) => item.id == winner.id);
            final loserIndex = _items.indexWhere((item) => item.id == loser.id);

            if (winnerIndex != -1) {
              _items[winnerIndex] = updatedWinner;
            }
            if (loserIndex != -1) {
              _items[loserIndex] = updatedLoser;
            }
          });
        }
      });
    });

    // Animate the card out
    _slideAnimation =
        Tween<double>(
          begin: _dragOffset,
          end: winner == _leftItem ? -1000 : 1000,
        ).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _animationController.forward(from: 0).then((_) {
      _animationController.reset();
      _nextComparison();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentQuestion == null || _leftItem == null || _rightItem == null) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'SETUP COMPLETE',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 2,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Please add items and questions\nto start comparing',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 32),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Text(
                        'GO BACK',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final categoryName = widget.categories
        .firstWhere((cat) => cat.id == _currentQuestion!.categoryId)
        .name;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Back button and category
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    child: Text(
                      categoryName.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 1,
                        fontWeight: FontWeight.w300,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _nextComparison,
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
                        Icons.skip_next,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Question
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: TweenAnimationBuilder<double>(
                key: ValueKey(_currentQuestion!.id),
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: Text(
                  _currentQuestion!.text,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            const SizedBox(height: 48),

          // Swipeable comparison card
          Expanded(
            child: AnimatedBuilder(
              animation: _slideAnimation,
              builder: (context, child) {
                final offset = _animationController.isAnimating
                    ? _slideAnimation.value
                    : _dragOffset;

                return GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    setState(() {
                      _dragOffset += details.delta.dx;
                    });
                  },
                  onHorizontalDragEnd: (details) {
                    if (_dragOffset < -100) {
                      _selectWinner(_leftItem!, _rightItem!);
                    } else if (_dragOffset > 100) {
                      _selectWinner(_rightItem!, _leftItem!);
                    } else {
                      setState(() {
                        _dragOffset = 0;
                      });
                    }
                  },
                  child: Transform.translate(
                    offset: Offset(offset, 0),
                    child: Transform.rotate(
                      angle: offset / 1000,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Main comparison card
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 24.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(32),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.1),
                                    blurRadius: 30,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: IntrinsicHeight(
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    // Left item
                                    Flexible(
                                      child: GestureDetector(
                                        onTap: () => _selectWinner(
                                          _leftItem!,
                                          _rightItem!,
                                        ),
                                        child: Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(32.0),
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(32),
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: 80,
                                                height: 80,
                                                decoration: BoxDecoration(
                                                  color: Colors.black,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    _leftItem!.name[0]
                                                        .toUpperCase(),
                                                    style: const TextStyle(
                                                      fontSize: 32,
                                                      fontWeight: FontWeight.w300,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 20),
                                              Text(
                                                _leftItem!.name,
                                                style: const TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.w300,
                                                  color: Colors.black,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                    // VS divider
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 20,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.white,
                                            Colors.black,
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Divider(
                                              color: Colors.white.withOpacity(0.3),
                                              thickness: 1,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.white.withOpacity(0.3),
                                              ),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              'VS',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w300,
                                                color: Colors.white.withOpacity(0.7),
                                                letterSpacing: 4,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Divider(
                                              color: Colors.white.withOpacity(0.3),
                                              thickness: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Right item (bottom - black with white outline)
                                    Flexible(
                                      child: GestureDetector(
                                        onTap: () => _selectWinner(
                                          _rightItem!,
                                          _leftItem!,
                                        ),
                                        child: Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(24.0),
                                          decoration: BoxDecoration(
                                            color: Colors.black,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 2,
                                            ),
                                            borderRadius: const BorderRadius.only(
                                              bottomLeft: Radius.circular(32),
                                              bottomRight: Radius.circular(32),
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: 60,
                                                height: 60,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    _rightItem!.name[0]
                                                        .toUpperCase(),
                                                    style: const TextStyle(
                                                      fontSize: 28,
                                                      fontWeight: FontWeight.w300,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 16),
                                              Text(
                                                _rightItem!.name,
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w300,
                                                  color: Colors.white,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

            // Instructions
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'Swipe or tap to choose',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.3),
                  fontSize: 12,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w300,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
