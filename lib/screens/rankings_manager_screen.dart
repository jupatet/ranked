import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../models/ranking.dart';
import '../services/firebase_service.dart';

class RankingsManagerScreen extends StatefulWidget {
  const RankingsManagerScreen({super.key});

  @override
  State<RankingsManagerScreen> createState() => _RankingsManagerScreenState();
}

class _RankingsManagerScreenState extends State<RankingsManagerScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final TextEditingController _rankingNameController = TextEditingController();
  final TextEditingController _shareCodeController = TextEditingController();
  
  List<Ranking> _myRankings = [];
  List<Ranking> _collaborativeRankings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRankings();
  }

  @override
  void dispose() {
    _rankingNameController.dispose();
    _shareCodeController.dispose();
    super.dispose();
  }

  Future<void> _loadRankings() async {
    setState(() => _isLoading = true);
    
    try {
      print('Loading rankings...');
      
      // Add timeout to prevent infinite loading
      final myRankings = await _firebaseService.getUserRankings()
          .timeout(const Duration(seconds: 10));
      print('My rankings loaded: ${myRankings.length}');
      
      final collaborative = await _firebaseService.getCollaborativeRankings()
          .timeout(const Duration(seconds: 10));
      print('Collaborative rankings loaded: ${collaborative.length}');
      
      setState(() {
        _myRankings = myRankings;
        _collaborativeRankings = collaborative;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      print('Error loading rankings: $e');
      print('Stack trace: $stackTrace');
      setState(() => _isLoading = false);
      _showError('Failed to load rankings: ${e.toString()}');
    }
  }

  Future<void> _createNewRanking() async {
    if (_rankingNameController.text.trim().isEmpty) {
      _showError('Please enter a ranking name');
      return;
    }

    try {
      print('Getting user ID...');
      final userId = await _firebaseService.getCurrentUserId()
          .timeout(const Duration(seconds: 10));
      print('User ID: $userId');
      
      final ranking = Ranking(
        id: const Uuid().v4(),
        name: _rankingNameController.text.trim(),
        ownerId: userId,
        categories: [],
        items: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      print('Creating ranking: ${ranking.name}');
      await _firebaseService.createRanking(ranking)
          .timeout(const Duration(seconds: 10));
      print('Ranking created successfully');
      
      _rankingNameController.clear();
      if (mounted) Navigator.pop(context);
      await _loadRankings();
      
      _showSuccess('Ranking "${ranking.name}" created!');
    } catch (e, stackTrace) {
      print('Error creating ranking: $e');
      print('Stack trace: $stackTrace');
      _showError('Failed to create ranking: ${e.toString()}');
    }
  }

  Future<void> _joinRanking() async {
    if (_shareCodeController.text.trim().isEmpty) {
      _showError('Please enter a share code');
      return;
    }

    try {
      final rankingId = await _firebaseService.joinRankingByCode(
        _shareCodeController.text.trim(),
      );

      if (rankingId == null) {
        _showError('Invalid share code');
        return;
      }

      _shareCodeController.clear();
      Navigator.pop(context);
      await _loadRankings();
      
      _showSuccess('Successfully joined ranking!');
    } catch (e) {
      _showError('Failed to join ranking: $e');
    }
  }

  Future<void> _generateShareCode(Ranking ranking) async {
    try {
      final code = await _firebaseService.generateShareCode(ranking.id);
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: const Text('Share Code', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Share this code with others:',
                style: TextStyle(color: Colors.white.withOpacity(0.7)),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: SelectableText(
                  code,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Code expires in 30 days',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: code));
                _showSuccess('Code copied to clipboard!');
              },
              child: const Text('COPY', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CLOSE', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    } catch (e) {
      _showError('Failed to generate share code: $e');
    }
  }

  Future<void> _deleteRanking(Ranking ranking) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Delete Ranking', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete "${ranking.name}"? This cannot be undone.',
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _firebaseService.deleteRanking(ranking.id);
        await _loadRankings();
        _showSuccess('Ranking deleted');
      } catch (e) {
        _showError('Failed to delete ranking: $e');
      }
    }
  }

  void _openRanking(Ranking ranking) async {
    try {
      // Load the ranking data from Firebase
      final loadedRanking = await _firebaseService.getRanking(ranking.id);
      
      if (loadedRanking == null) {
        _showError('Ranking not found');
        return;
      }

      // Navigate back to home screen and pass the ranking data
      if (mounted) {
        Navigator.pop(context, loadedRanking);
      }
    } catch (e) {
      _showError('Failed to load ranking: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
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
                    'MY RANKINGS',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 4,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 44), // Balance the back button
                ],
              ),
            ),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.add,
                      label: 'New Ranking',
                      onTap: () => _showCreateDialog(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.group_add,
                      label: 'Join Ranking',
                      onTap: () => _showJoinDialog(),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadRankings,
                      color: Colors.white,
                      backgroundColor: Colors.black,
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        children: [
                          // My Rankings
                          if (_myRankings.isNotEmpty) ...[
                            const Text(
                              'My Rankings',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ..._myRankings.map((ranking) => _RankingCard(
                                  ranking: ranking,
                                  isOwner: true,
                                  onTap: () => _openRanking(ranking),
                                  onShare: () => _generateShareCode(ranking),
                                  onDelete: () => _deleteRanking(ranking),
                                )),
                            const SizedBox(height: 24),
                          ],

                          // Collaborative Rankings
                          if (_collaborativeRankings.isNotEmpty) ...[
                            const Text(
                              'Shared with Me',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ..._collaborativeRankings.map((ranking) => _RankingCard(
                                  ranking: ranking,
                                  isOwner: false,
                                  onTap: () => _openRanking(ranking),
                                )),
                          ],

                          // Empty State
                          if (_myRankings.isEmpty && _collaborativeRankings.isEmpty)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.folder_open,
                                      size: 64,
                                      color: Colors.white.withOpacity(0.3),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No rankings yet',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Create a new ranking or join an existing one',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white.withOpacity(0.5),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Create New Ranking', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: _rankingNameController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Ranking Name',
            labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
            hintText: 'e.g., Best Movies 2024',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
          onSubmitted: (_) => _createNewRanking(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: _createNewRanking,
            child: const Text('CREATE', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showJoinDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Join Ranking', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: _shareCodeController,
          style: const TextStyle(color: Colors.white, letterSpacing: 2),
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            labelText: 'Share Code',
            labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
            hintText: 'ABC123',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
          ),
          onSubmitted: (_) => _joinRanking(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: _joinRanking,
            child: const Text('JOIN', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RankingCard extends StatelessWidget {
  final Ranking ranking;
  final bool isOwner;
  final VoidCallback onTap;
  final VoidCallback? onShare;
  final VoidCallback? onDelete;

  const _RankingCard({
    required this.ranking,
    required this.isOwner,
    required this.onTap,
    this.onShare,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ranking.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${ranking.items.length} items • ${ranking.categories.length} categories',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isOwner) ...[
                    IconButton(
                      icon: const Icon(Icons.share, color: Colors.white, size: 20),
                      onPressed: onShare,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.white70, size: 20),
                      onPressed: onDelete,
                    ),
                  ] else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'SHARED',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 12,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Updated ${_formatDate(ranking.updatedAt)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (ranking.collaboratorIds.isNotEmpty) ...[
                    Icon(
                      Icons.people,
                      size: 12,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${ranking.collaboratorIds.length} collaborator${ranking.collaboratorIds.length > 1 ? 's' : ''}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 30) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }
}
