import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';

import '../../database/database.dart';

/// Exports/imports vocabulary as a human-readable JSON backup file.
/// Fully local — no server involved, matching the spec's privacy-by-design
/// and "the user owns their learning data" requirements.
class BackupService {
  BackupService(this._db);
  final AppDatabase _db;

  Future<String> _exportToJson() async {
    final items = await _db.watchAllVocabulary().first;
    final data = {
      'exportedAt': DateTime.now().toIso8601String(),
      'appVersion': '0.1.0',
      'vocabulary': items
          .map((v) => {
                'word': v.word,
                'meaning': v.meaning,
                'exampleSentence': v.exampleSentence,
                'userSentence': v.userSentence,
                'partOfSpeech': v.partOfSpeech,
                'difficulty': v.difficulty,
                'tags': v.tags,
                'notes': v.notes,
                'correctCount': v.correctCount,
                'wrongCount': v.wrongCount,
                'mastered': v.mastered,
              })
          .toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// Writes the backup to a temp file and opens the system share sheet
  /// (the user can save it to Drive, Files, send it to themselves, etc.)
  Future<void> exportAndShare() async {
    final json = await _exportToJson();
    final dir = await getTemporaryDirectory();
    final stamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final file = File('${dir.path}/duomate-backup-$stamp.json');
    await file.writeAsString(json);
    await Share.shareXFiles([XFile(file.path)],
        text: 'DuoMate vocabulary backup');
  }

  /// Lets the user pick a previously-exported JSON file and imports it.
  /// Returns the number of words imported, or null if the user cancelled.
  Future<int?> importFromFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result == null || result.files.single.path == null) return null;

    final file = File(result.files.single.path!);
    final content = await file.readAsString();
    final data = jsonDecode(content) as Map<String, dynamic>;
    final list = (data['vocabulary'] as List).cast<Map<String, dynamic>>();

    var count = 0;
    for (final item in list) {
      await _db.addVocabulary(
        word: item['word'] as String? ?? '',
        meaning: item['meaning'] as String? ?? '',
        exampleSentence: item['exampleSentence'] as String? ?? '',
        userSentence: item['userSentence'] as String? ?? '',
        partOfSpeech: item['partOfSpeech'] as String? ?? '',
        difficulty: item['difficulty'] as int? ?? 2,
        tags: item['tags'] as String? ?? '',
        notes: item['notes'] as String? ?? '',
      );
      count++;
    }
    return count;
  }
}
