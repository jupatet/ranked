import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/ranking.dart';
import '../models/rankable_item.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID (anonymous auth)
  Future<String> getCurrentUserId() async {
    try {
      print('Getting current user...');
      User? user = _auth.currentUser;
      print('Current user: ${user?.uid ?? "null"}');
      
      if (user == null) {
        print('No current user, signing in anonymously...');
        UserCredential credential = await _auth.signInAnonymously();
        user = credential.user;
        print('Signed in anonymously: ${user?.uid}');
      }
      return user!.uid;
    } catch (e, stackTrace) {
      print('Error in getCurrentUserId: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Create a new ranking
  Future<void> createRanking(Ranking ranking) async {
    try {
      print('Creating ranking in Firestore: ${ranking.id}');
      await _firestore.collection('rankings').doc(ranking.id).set(ranking.toJson());
      print('Ranking created successfully');
    } catch (e, stackTrace) {
      print('Error in createRanking: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Update an existing ranking
  Future<void> updateRanking(Ranking ranking) async {
    await _firestore.collection('rankings').doc(ranking.id).update(ranking.toJson());
  }

  // Get all rankings for current user
  Future<List<Ranking>> getUserRankings() async {
    try {
      final userId = await getCurrentUserId();
      print('Fetching rankings for user: $userId');
      
      final querySnapshot = await _firestore
          .collection('rankings')
          .where('ownerId', isEqualTo: userId)
          .orderBy('updatedAt', descending: true)
          .get();

      print('Found ${querySnapshot.docs.length} rankings');
      
      return querySnapshot.docs
          .map((doc) => Ranking.fromJson(doc.data()))
          .toList();
    } catch (e, stackTrace) {
      print('Error in getUserRankings: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Get rankings where user is a collaborator
  Future<List<Ranking>> getCollaborativeRankings() async {
    try {
      final userId = await getCurrentUserId();
      print('Fetching collaborative rankings for user: $userId');
      
      final querySnapshot = await _firestore
          .collection('rankings')
          .where('collaboratorIds', arrayContains: userId)
          .orderBy('updatedAt', descending: true)
          .get();

      print('Found ${querySnapshot.docs.length} collaborative rankings');
      
      return querySnapshot.docs
          .map((doc) => Ranking.fromJson(doc.data()))
          .toList();
    } catch (e, stackTrace) {
      print('Error in getCollaborativeRankings: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Get a specific ranking by ID
  Future<Ranking?> getRanking(String rankingId) async {
    final doc = await _firestore.collection('rankings').doc(rankingId).get();
    if (!doc.exists) return null;
    return Ranking.fromJson(doc.data()!);
  }

  // Delete a ranking
  Future<void> deleteRanking(String rankingId) async {
    await _firestore.collection('rankings').doc(rankingId).delete();
  }

  // Add a collaborator to a ranking
  Future<void> addCollaborator(String rankingId, String collaboratorId) async {
    await _firestore.collection('rankings').doc(rankingId).update({
      'collaboratorIds': FieldValue.arrayUnion([collaboratorId]),
    });
  }

  // Remove a collaborator from a ranking
  Future<void> removeCollaborator(String rankingId, String collaboratorId) async {
    await _firestore.collection('rankings').doc(rankingId).update({
      'collaboratorIds': FieldValue.arrayRemove([collaboratorId]),
    });
  }

  // Make ranking public/private
  Future<void> updateRankingVisibility(String rankingId, bool isPublic) async {
    await _firestore.collection('rankings').doc(rankingId).update({
      'isPublic': isPublic,
    });
  }

  // Real-time sync: Listen to ranking changes
  Stream<Ranking?> watchRanking(String rankingId) {
    return _firestore
        .collection('rankings')
        .doc(rankingId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return null;
      return Ranking.fromJson(snapshot.data()!);
    });
  }

  // Sync local item updates to Firebase
  Future<void> syncItemUpdate(String rankingId, RankableItem item) async {
    final ranking = await getRanking(rankingId);
    if (ranking == null) return;

    final updatedItems = ranking.items.map((i) {
      if (i.id == item.id) return item;
      return i;
    }).toList();

    await updateRanking(ranking.copyWith(
      items: updatedItems,
      updatedAt: DateTime.now(),
    ));
  }

  // Generate a shareable link code for a ranking
  Future<String> generateShareCode(String rankingId) async {
    // Generate a short code and store in a separate collection for easy lookup
    final code = _generateRandomCode(6);
    
    await _firestore.collection('share_codes').doc(code).set({
      'rankingId': rankingId,
      'createdAt': FieldValue.serverTimestamp(),
      'expiresAt': DateTime.now().add(Duration(days: 30)),
    });

    return code;
  }

  // Join a ranking using a share code
  Future<String?> joinRankingByCode(String code) async {
    final doc = await _firestore.collection('share_codes').doc(code.toUpperCase()).get();
    
    if (!doc.exists) return null;
    
    final data = doc.data()!;
    final rankingId = data['rankingId'] as String;
    final userId = await getCurrentUserId();
    
    // Add user as collaborator
    await addCollaborator(rankingId, userId);
    
    return rankingId;
  }

  String _generateRandomCode(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().microsecondsSinceEpoch;
    var code = '';
    for (var i = 0; i < length; i++) {
      code += chars[(random * (i + 1) * 7919) % chars.length];
    }
    return code;
  }
}
