/// DuoMate's review scheduler.
///
/// This is a simple, transparent SM-2-inspired ladder — NOT a scientifically
/// validated algorithm. It's intentionally isolated in this one file so it
/// can be swapped or tuned later without touching UI or database code.
///
/// Ladder (days until next review), indexed by `intervalStage`:
///   0 → same day (a few hours later)
///   1 → 1 day
///   2 → 3 days
///   3 → 7 days
///   4 → 14 days
///   5 → 30 days
///   6+ → 30 days (repeats; "mastered" flag takes over from here)
class ReviewScheduler {
  ReviewScheduler._();

  static const List<Duration> _ladder = [
    Duration(hours: 4),
    Duration(days: 1),
    Duration(days: 3),
    Duration(days: 7),
    Duration(days: 14),
    Duration(days: 30),
  ];

  /// Given the current stage and whether the last answer was correct,
  /// returns the new stage and the next review DateTime.
  static ({int nextStage, DateTime nextReviewAt, bool mastered}) next({
    required int currentStage,
    required bool wasCorrect,
    DateTime? now,
  }) {
    final base = now ?? DateTime.now();

    if (!wasCorrect) {
      // Wrong answer: drop back two rungs (never below 0) so it resurfaces sooner.
      final newStage = (currentStage - 2).clamp(0, _ladder.length - 1);
      return (
        nextStage: newStage,
        nextReviewAt: base.add(_ladder[newStage]),
        mastered: false,
      );
    }

    final newStage = (currentStage + 1).clamp(0, _ladder.length - 1);
    final reachedTopTwice = currentStage >= _ladder.length - 1;
    return (
      nextStage: newStage,
      nextReviewAt: base.add(_ladder[newStage]),
      // Consider "mastered" once the user has cleared the longest interval.
      mastered: reachedTopTwice,
    );
  }
}
