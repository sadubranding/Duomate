import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers.dart';
import '../../core/utils/review_scheduler.dart';
import '../../database/database.dart';
import 'review_question_card.dart';

enum ReviewMode { meaningRecall, multipleChoice, reverseRecall, exampleCompletion }

class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  bool _sessionActive = false;
  late List<VocabularyItem> _queue;
  int _current = 0;
  int _correct = 0;
  int _incorrect = 0;
  String? _sessionId;
  final _rand = Random();

  Future<void> _startSession(List<VocabularyItem> due) async {
    final db = ref.read(databaseProvider);
    _sessionId = await db.startReviewSession();
    setState(() {
      _queue = List.of(due)..shuffle();
      _current = 0;
      _correct = 0;
      _incorrect = 0;
      _sessionActive = true;
    });
  }

  ReviewMode _pickMode() =>
      ReviewMode.values[_rand.nextInt(ReviewMode.values.length)];

  Future<void> _onAnswered(VocabularyItem item, bool wasCorrect, String userAnswer, ReviewMode mode) async {
    final db = ref.read(databaseProvider);

    await db.recordAttempt(
      vocabularyId: item.id,
      sessionId: _sessionId!,
      mode: mode.name,
      isCorrect: wasCorrect,
      userAnswer: userAnswer,
    );

    final result = ReviewScheduler.next(
      currentStage: item.intervalStage,
      wasCorrect: wasCorrect,
    );
    await db.updateVocabulary(item.copyWith(
      intervalStage: result.nextStage,
      nextReviewAt: result.nextReviewAt,
      mastered: result.mastered,
    ));

    setState(() {
      if (wasCorrect) {
        _correct++;
      } else {
        _incorrect++;
      }
    });

    await Future.delayed(const Duration(milliseconds: 700));

    if (_current + 1 >= _queue.length) {
      await db.finishReviewSession(
          _sessionId!, _queue.length, _correct, _incorrect);
      await db.logActivity(reviews: _queue.length);
      if (mounted) {
        setState(() => _sessionActive = false);
        _showSummary();
      }
    } else {
      setState(() => _current++);
    }
  }

  void _showSummary() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('সেশন শেষ! 🎉'),
        content: Text('✅ সঠিক: $_correct\n❌ ভুল: $_incorrect'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ঠিক আছে'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final due = ref.watch(dueForReviewProvider);

    if (_sessionActive) {
      final item = _queue[_current];
      final mode = _pickMode();
      return Scaffold(
        appBar: AppBar(
          title: Text('প্রশ্ন ${_current + 1} / ${_queue.length}'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              LinearProgressIndicator(
                value: (_current) / _queue.length,
                backgroundColor: AppColors.separatorLight,
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: ReviewQuestionCard(
                  key: ValueKey('${item.id}-$_current'),
                  item: item,
                  mode: mode,
                  onAnswered: (correct, answer) =>
                      _onAnswered(item, correct, answer, mode),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('রিভিউ')),
      body: due.when(
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Text(
                  'এই মুহূর্তে রিভিউ করার মতো কোনো শব্দ নেই।\nনতুন শব্দ যোগ করুন অথবা কিছুক্ষণ পরে আবার আসুন।',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IosCard(
                  child: Column(
                    children: [
                      Text('${list.length}',
                          style: Theme.of(context).textTheme.displaySmall),
                      const Text('শব্দ রিভিউর জন্য প্রস্তুত'),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _startSession(list),
                    child: const Text('রিভিউ শুরু করুন'),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('সমস্যা হয়েছে: $e')),
      ),
    );
  }
}
