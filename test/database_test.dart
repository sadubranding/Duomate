import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:duomate/database/database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('Vocabulary CRUD', () {
    test('adding a word makes it appear in the list', () async {
      await db.addVocabulary(word: 'reliable', meaning: 'বিশ্বস্ত');
      final all = await db.watchAllVocabulary().first;
      expect(all.length, 1);
      expect(all.first.word, 'reliable');
    });

    test('editing a word persists the change', () async {
      final item =
          await db.addVocabulary(word: 'reliable', meaning: 'বিশ্বস্ত');
      await db.updateVocabulary(item.copyWith(meaning: 'নির্ভরযোগ্য'));
      final all = await db.watchAllVocabulary().first;
      expect(all.first.meaning, 'নির্ভরযোগ্য');
    });

    test('deleting a word removes it', () async {
      final item =
          await db.addVocabulary(word: 'reliable', meaning: 'বিশ্বস্ত');
      await db.deleteVocabulary(item.id);
      final all = await db.watchAllVocabulary().first;
      expect(all, isEmpty);
    });

    test('search matches word or meaning, case-insensitively', () async {
      await db.addVocabulary(word: 'Reliable', meaning: 'বিশ্বস্ত');
      await db.addVocabulary(word: 'Improve', meaning: 'উন্নতি করা');

      final byWord = await db.searchVocabulary('reli');
      expect(byWord.length, 1);
      expect(byWord.first.word, 'Reliable');

      final byMeaning = await db.searchVocabulary('উন্নতি');
      expect(byMeaning.length, 1);
      expect(byMeaning.first.word, 'Improve');
    });
  });

  group('Mistake tracking', () {
    test('wrong attempts increase wrongCount and rank in mistake bank',
        () async {
      final item =
          await db.addVocabulary(word: 'reliable', meaning: 'বিশ্বস্ত');
      final sessionId = await db.startReviewSession();

      await db.recordAttempt(
        vocabularyId: item.id,
        sessionId: sessionId,
        mode: 'meaningRecall',
        isCorrect: false,
      );
      await db.recordAttempt(
        vocabularyId: item.id,
        sessionId: sessionId,
        mode: 'meaningRecall',
        isCorrect: false,
      );

      final mistakes = await db.mostMistakenWords();
      expect(mistakes.length, 1);
      expect(mistakes.first.wrongCount, 2);
    });

    test('correct attempts increase correctCount, not wrongCount', () async {
      final item =
          await db.addVocabulary(word: 'reliable', meaning: 'বিশ্বস্ত');
      final sessionId = await db.startReviewSession();

      await db.recordAttempt(
        vocabularyId: item.id,
        sessionId: sessionId,
        mode: 'meaningRecall',
        isCorrect: true,
      );

      final all = await db.watchAllVocabulary().first;
      expect(all.first.correctCount, 1);
      expect(all.first.wrongCount, 0);
    });
  });

  group('Daily goal / streak', () {
    test('logging activity creates a streak of 1 on the first day',
        () async {
      await db.logActivity(reviews: 5);
      final settings = await db.watchSettings().first;
      expect(settings.currentStreak, 1);
    });
  });
}
