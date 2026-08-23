import 'package:flutter_test/flutter_test.dart';
import 'package:duomate/core/utils/review_scheduler.dart';

void main() {
  group('ReviewScheduler', () {
    test('correct answer moves to the next stage', () {
      final result =
          ReviewScheduler.next(currentStage: 0, wasCorrect: true);
      expect(result.nextStage, 1);
      expect(result.mastered, false);
    });

    test('wrong answer drops back two stages, never below 0', () {
      final result =
          ReviewScheduler.next(currentStage: 1, wasCorrect: false);
      expect(result.nextStage, 0);

      final resultAtZero =
          ReviewScheduler.next(currentStage: 0, wasCorrect: false);
      expect(resultAtZero.nextStage, 0);
    });

    test('reaching the top stage twice in a row marks as mastered', () {
      // Stage 5 is the last rung (index 5, the 30-day interval).
      final result =
          ReviewScheduler.next(currentStage: 5, wasCorrect: true);
      expect(result.mastered, true);
    });

    test('next review time is always in the future', () {
      final now = DateTime(2026, 1, 1, 12);
      final result = ReviewScheduler.next(
        currentStage: 0,
        wasCorrect: true,
        now: now,
      );
      expect(result.nextReviewAt.isAfter(now), true);
    });

    test('a correct answer never regresses the stage', () {
      final result =
          ReviewScheduler.next(currentStage: 3, wasCorrect: true);
      expect(result.nextStage, greaterThanOrEqualTo(3));
    });
  });
}
