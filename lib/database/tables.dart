import 'package:drift/drift.dart';

/// Why Drift (over Isar or plain sqflite):
/// - Compile-time-checked SQL (typos become build errors, not runtime crashes)
/// - Reactive streams out of the box (widgets auto-update when data changes —
///   perfect for "due for review" counts, streaks, dashboard numbers)
/// - Plain SQLite under the hood, so exporting/inspecting the raw .db file
///   later (e.g. for sync) stays simple
/// - Actively maintained, works well with Riverpod

class VocabularyItems extends Table {
  TextColumn get id => text()();
  TextColumn get word => text().withLength(min: 1, max: 200)();
  TextColumn get meaning => text()();
  TextColumn get exampleSentence => text().withDefault(const Constant(''))();
  TextColumn get userSentence => text().withDefault(const Constant(''))();
  TextColumn get partOfSpeech => text().withDefault(const Constant(''))();
  // 1 = easy, 2 = medium, 3 = hard — user- or system-assigned
  IntColumn get difficulty => integer().withDefault(const Constant(2))();
  TextColumn get tags => text().withDefault(const Constant(''))(); // comma-separated
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  IntColumn get correctCount => integer().withDefault(const Constant(0))();
  IntColumn get wrongCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get nextReviewAt => dateTime()();
  // Index into the spaced-repetition interval ladder (see ReviewScheduler)
  IntColumn get intervalStage => integer().withDefault(const Constant(0))();
  BoolColumn get mastered => boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {id};
}

class ReviewSessions extends Table {
  TextColumn get id => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  IntColumn get totalQuestions => integer().withDefault(const Constant(0))();
  IntColumn get correctAnswers => integer().withDefault(const Constant(0))();
  IntColumn get incorrectAnswers => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class ReviewAttempts extends Table {
  TextColumn get id => text()();
  TextColumn get vocabularyId =>
      text().references(VocabularyItems, #id, onDelete: KeyAction.cascade)();
  TextColumn get sessionId =>
      text().references(ReviewSessions, #id, onDelete: KeyAction.cascade)();
  // 'meaningRecall' | 'multipleChoice' | 'reverseRecall' | 'exampleCompletion'
  TextColumn get mode => text()();
  BoolColumn get isCorrect => boolean()();
  TextColumn get userAnswer => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class PracticeSentences extends Table {
  TextColumn get id => text()();
  TextColumn get vocabularyId =>
      text().references(VocabularyItems, #id, onDelete: KeyAction.cascade)();
  TextColumn get sentence => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class DailyActivity extends Table {
  // One row per calendar day the user did a qualifying learning action —
  // this is what streaks and the weekly-activity chart are computed from.
  DateTimeColumn get date => dateTime()(); // stored at midnight, local time
  IntColumn get reviewsCompleted => integer().withDefault(const Constant(0))();
  IntColumn get sentencesWritten => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {date};
}

class UserSettings extends Table {
  // Single-row settings table (id is always 0)
  IntColumn get id => integer().withDefault(const Constant(0))();
  IntColumn get dailyGoal => integer().withDefault(const Constant(10))();
  // 'light' | 'dark' | 'system'
  TextColumn get theme => text().withDefault(const Constant('system'))();
  BoolColumn get notificationsEnabled =>
      boolean().withDefault(const Constant(true))();
  TextColumn get languagePreference => text().withDefault(const Constant('bn'))();
  IntColumn get currentStreak => integer().withDefault(const Constant(0))();
  IntColumn get longestStreak => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastActivityDate => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
