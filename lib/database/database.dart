import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'tables.dart';
import '../core/constants/sample_data.dart';

part 'database.g.dart';

const _uuid = Uuid();

@DriftDatabase(tables: [
  VocabularyItems,
  ReviewSessions,
  ReviewAttempts,
  PracticeSentences,
  DailyActivity,
  UserSettings,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // ---------- Vocabulary ----------

  Stream<List<VocabularyItem>> watchAllVocabulary() =>
      (select(vocabularyItems)
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .watch();

  Stream<List<VocabularyItem>> watchDueForReview() => (select(vocabularyItems)
        ..where((t) =>
            t.nextReviewAt.isSmallerOrEqualValue(DateTime.now()) &
            t.mastered.equals(false))
        ..orderBy([(t) => OrderingTerm.asc(t.nextReviewAt)]))
      .watch();

  Future<VocabularyItem> addVocabulary({
    required String word,
    required String meaning,
    String exampleSentence = '',
    String userSentence = '',
    String partOfSpeech = '',
    int difficulty = 2,
    String tags = '',
    String notes = '',
  }) async {
    final now = DateTime.now();
    final entry = VocabularyItemsCompanion.insert(
      id: _uuid.v4(),
      word: word.trim(),
      meaning: meaning.trim(),
      exampleSentence: Value(exampleSentence),
      userSentence: Value(userSentence),
      partOfSpeech: Value(partOfSpeech),
      difficulty: Value(difficulty),
      tags: Value(tags),
      createdAt: now,
      updatedAt: now,
      nextReviewAt: now, // available for review immediately
      notes: Value(notes),
    );
    await into(vocabularyItems).insert(entry);
    return (select(vocabularyItems)..where((t) => t.id.equals(entry.id.value)))
        .getSingle();
  }

  Future<void> updateVocabulary(VocabularyItem item) =>
      update(vocabularyItems).replace(
        item.copyWith(updatedAt: DateTime.now()),
      );

  Future<void> deleteVocabulary(String id) =>
      (delete(vocabularyItems)..where((t) => t.id.equals(id))).go();

  Future<List<VocabularyItem>> searchVocabulary(String query) {
    final q = '%${query.toLowerCase()}%';
    return (select(vocabularyItems)
          ..where((t) =>
              t.word.lower().like(q) | t.meaning.lower().like(q)))
        .get();
  }

  /// Loads the built-in sample vocabulary — used by the "Try Sample
  /// Vocabulary" onboarding option for first-time users.
  Future<void> loadSampleVocabulary() async {
    for (final s in sampleVocabulary) {
      await addVocabulary(
        word: s.word,
        meaning: s.meaning,
        exampleSentence: s.example,
      );
    }
  }

  // ---------- Review sessions & attempts ----------

  Future<String> startReviewSession() async {
    final id = _uuid.v4();
    await into(reviewSessions).insert(
      ReviewSessionsCompanion.insert(id: id, startedAt: DateTime.now()),
    );
    return id;
  }

  Future<void> recordAttempt({
    required String vocabularyId,
    required String sessionId,
    required String mode,
    required bool isCorrect,
    String userAnswer = '',
  }) async {
    await into(reviewAttempts).insert(ReviewAttemptsCompanion.insert(
      id: _uuid.v4(),
      vocabularyId: vocabularyId,
      sessionId: sessionId,
      mode: mode,
      isCorrect: isCorrect,
      userAnswer: Value(userAnswer),
      createdAt: DateTime.now(),
    ));

    final item =
        await (select(vocabularyItems)..where((t) => t.id.equals(vocabularyId)))
            .getSingle();
    await update(vocabularyItems).replace(item.copyWith(
      correctCount: isCorrect ? item.correctCount + 1 : item.correctCount,
      wrongCount: isCorrect ? item.wrongCount : item.wrongCount + 1,
      updatedAt: DateTime.now(),
    ));
  }

  Future<void> finishReviewSession(
      String sessionId, int total, int correct, int incorrect) async {
    final session = await (select(reviewSessions)
          ..where((t) => t.id.equals(sessionId)))
        .getSingle();
    await update(reviewSessions).replace(session.copyWith(
      completedAt: Value(DateTime.now()),
      totalQuestions: total,
      correctAnswers: correct,
      incorrectAnswers: incorrect,
    ));
  }

  /// Words ordered by how often they've been missed — powers the Mistake Bank.
  Future<List<VocabularyItem>> mostMistakenWords({int limit = 20}) =>
      (select(vocabularyItems)
            ..where((t) => t.wrongCount.isBiggerThanValue(0))
            ..orderBy([(t) => OrderingTerm.desc(t.wrongCount)])
            ..limit(limit))
          .get();

  // ---------- Practice sentences ----------

  Future<void> addSentence(String vocabularyId, String sentence) => into(
        practiceSentences,
      ).insert(PracticeSentencesCompanion.insert(
        id: _uuid.v4(),
        vocabularyId: vocabularyId,
        sentence: sentence,
        createdAt: DateTime.now(),
      ));

  Stream<List<PracticeSentence>> watchSentencesFor(String vocabularyId) =>
      (select(practiceSentences)
            ..where((t) => t.vocabularyId.equals(vocabularyId))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .watch();

  Future<void> deleteSentence(String id) =>
      (delete(practiceSentences)..where((t) => t.id.equals(id))).go();

  // ---------- Daily activity / streaks ----------

  Future<void> logActivity({int reviews = 0, int sentences = 0}) async {
    final today = DateTime.now();
    final dayKey = DateTime(today.year, today.month, today.day);
    final existing = await (select(dailyActivity)
          ..where((t) => t.date.equals(dayKey)))
        .getSingleOrNull();

    final isFirstActivityToday = existing == null;

    if (existing == null) {
      await into(dailyActivity).insert(DailyActivityCompanion.insert(
        date: dayKey,
        reviewsCompleted: Value(reviews),
        sentencesWritten: Value(sentences),
      ));
    } else {
      await update(dailyActivity).replace(existing.copyWith(
        reviewsCompleted: existing.reviewsCompleted + reviews,
        sentencesWritten: existing.sentencesWritten + sentences,
      ));
    }

    // Only recompute the streak the first time today counts as active —
    // repeated reviews on the same day shouldn't re-trigger streak logic.
    if (isFirstActivityToday) {
      await _bumpStreak(dayKey);
    }
  }

  Future<void> _bumpStreak(DateTime today) async {
    final current = await (select(userSettings)..where((t) => t.id.equals(0)))
        .getSingleOrNull();

    final last = current?.lastActivityDate;
    final yesterday = today.subtract(const Duration(days: 1));

    int newStreak;
    if (last == null) {
      newStreak = 1;
    } else {
      final lastDay = DateTime(last.year, last.month, last.day);
      if (lastDay == yesterday) {
        newStreak = (current?.currentStreak ?? 0) + 1; // continued streak
      } else if (lastDay == today) {
        newStreak = current?.currentStreak ?? 1; // already counted today
      } else {
        newStreak = 1; // streak broken, restart
      }
    }

    final longest = current?.longestStreak ?? 0;

    await into(userSettings).insertOnConflictUpdate(
      UserSettingsCompanion(
        id: const Value(0),
        dailyGoal: Value(current?.dailyGoal ?? 10),
        theme: Value(current?.theme ?? 'system'),
        notificationsEnabled: Value(current?.notificationsEnabled ?? true),
        languagePreference: Value(current?.languagePreference ?? 'bn'),
        currentStreak: Value(newStreak),
        longestStreak: Value(newStreak > longest ? newStreak : longest),
        lastActivityDate: Value(today),
      ),
    );
  }

  Stream<List<DailyActivityData>> watchLastNDays(int n) {
    final cutoff = DateTime.now().subtract(Duration(days: n));
    return (select(dailyActivity)
          ..where((t) => t.date.isBiggerOrEqualValue(cutoff))
          ..orderBy([(t) => OrderingTerm.asc(t.date)]))
        .watch();
  }

  // ---------- Settings (single row) ----------

  Stream<UserSetting> watchSettings() {
    return (select(userSettings)..where((t) => t.id.equals(0)))
        .watchSingleOrNull()
        .map((s) => s ?? const UserSetting(
              id: 0,
              dailyGoal: 10,
              theme: 'system',
              notificationsEnabled: true,
              languagePreference: 'bn',
              currentStreak: 0,
              longestStreak: 0,
            ));
  }

  Future<void> upsertSettings(UserSettingsCompanion companion) async {
    await into(userSettings).insertOnConflictUpdate(
      companion.copyWith(id: const Value(0)),
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'duomate.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
