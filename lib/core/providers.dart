import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../database/database.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final settingsStreamProvider = StreamProvider<UserSetting>((ref) {
  return ref.watch(databaseProvider).watchSettings();
});

final dueForReviewProvider = StreamProvider<List<VocabularyItem>>((ref) {
  return ref.watch(databaseProvider).watchDueForReview();
});

final allVocabularyProvider = StreamProvider<List<VocabularyItem>>((ref) {
  return ref.watch(databaseProvider).watchAllVocabulary();
});
