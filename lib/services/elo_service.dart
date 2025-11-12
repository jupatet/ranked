import 'dart:math';
import '../models/rankable_item.dart';

/// Service to calculate ELO ratings based on comparisons
class EloService {
  // K-factor determines how much ratings change after each match
  // Higher K means more volatile ratings
  static const double kFactorNew = 32.0; // For items with few comparisons
  static const double kFactorNormal =
      24.0; // For items with moderate comparisons
  static const double kFactorExpert = 16.0; // For items with many comparisons

  /// Calculate the expected score for player A against player B
  /// Returns a value between 0 and 1
  static double calculateExpectedScore(double ratingA, double ratingB) {
    return 1.0 / (1.0 + pow(10, (ratingB - ratingA) / 400));
  }

  /// Get K-factor based on number of comparisons
  /// Items with fewer comparisons get a higher K-factor for faster adjustment
  static double getKFactor(int comparisons) {
    if (comparisons < 10) {
      return kFactorNew;
    } else if (comparisons < 30) {
      return kFactorNormal;
    } else {
      return kFactorExpert;
    }
  }

  /// Update ratings after a comparison (raw ratings)
  /// Returns tuple of (new winner rating, new loser rating)
  static (double, double) updateRatingsRaw({
    required double winnerRating,
    required double loserRating,
    required int winnerComparisons,
    required int loserComparisons,
  }) {
    // Calculate expected scores
    final expectedWinner = calculateExpectedScore(winnerRating, loserRating);
    final expectedLoser = calculateExpectedScore(loserRating, winnerRating);

    // Get K-factors
    final kWinner = getKFactor(winnerComparisons);
    final kLoser = getKFactor(loserComparisons);

    // Calculate new ratings
    // Winner gets 1 point, loser gets 0
    final newWinnerRating = winnerRating + kWinner * (1.0 - expectedWinner);
    final newLoserRating = loserRating + kLoser * (0.0 - expectedLoser);

    return (newWinnerRating, newLoserRating);
  }

  /// Update ratings after a comparison
  /// Returns updated copies of both items
  static (RankableItem, RankableItem) updateRatings({
    required RankableItem winner,
    required RankableItem loser,
  }) {
    // Calculate expected scores
    final expectedWinner = calculateExpectedScore(winner.rating, loser.rating);
    final expectedLoser = calculateExpectedScore(loser.rating, winner.rating);

    // Get K-factors
    final kWinner = getKFactor(winner.comparisons);
    final kLoser = getKFactor(loser.comparisons);

    // Calculate new ratings
    // Winner gets 1 point, loser gets 0
    final newWinnerRating = winner.rating + kWinner * (1.0 - expectedWinner);
    final newLoserRating = loser.rating + kLoser * (0.0 - expectedLoser);

    // Return updated items
    return (
      winner.copyWith(
        rating: newWinnerRating,
        comparisons: winner.comparisons + 1,
      ),
      loser.copyWith(
        rating: newLoserRating,
        comparisons: loser.comparisons + 1,
      ),
    );
  }

  /// Calculate rating difference percentage
  /// Returns percentage (0-100) indicating how much better one item is
  static double getRatingDifferencePercentage(double ratingA, double ratingB) {
    final expected = calculateExpectedScore(ratingA, ratingB);
    return expected * 100;
  }

  /// Get rating tier description
  static String getRatingTier(double rating) {
    if (rating >= 2000) return 'Master';
    if (rating >= 1800) return 'Expert';
    if (rating >= 1600) return 'Advanced';
    if (rating >= 1400) return 'Intermediate';
    if (rating >= 1200) return 'Novice';
    return 'Beginner';
  }
}
