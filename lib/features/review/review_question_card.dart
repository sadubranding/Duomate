import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers.dart';
import '../../database/database.dart';
import 'review_screen.dart';

class ReviewQuestionCard extends ConsumerStatefulWidget {
  final VocabularyItem item;
  final ReviewMode mode;
  final void Function(bool wasCorrect, String userAnswer) onAnswered;

  const ReviewQuestionCard({
    super.key,
    required this.item,
    required this.mode,
    required this.onAnswered,
  });

  @override
  ConsumerState<ReviewQuestionCard> createState() => _ReviewQuestionCardState();
}

class _ReviewQuestionCardState extends ConsumerState<ReviewQuestionCard> {
  final _textCtrl = TextEditingController();
  bool? _isCorrectShown;
  String? _selectedOption;
  List<String>? _choices;

  @override
  void initState() {
    super.initState();
    if (widget.mode == ReviewMode.multipleChoice) {
      _buildChoices();
    }
  }

  Future<void> _buildChoices() async {
    final all = await ref.read(databaseProvider).watchAllVocabulary().first;
    final distractorPool = all.where((v) => v.id != widget.item.id).toList()
      ..shuffle();
    final distractors = distractorPool.take(3).map((v) => v.meaning).toList();
    final options = [widget.item.meaning, ...distractors]..shuffle(Random());
    if (mounted) setState(() => _choices = options);
  }

  bool _fuzzyMatch(String input, String target) {
    final a = input.trim().toLowerCase();
    final b = target.trim().toLowerCase();
    return a.isNotEmpty && a == b;
  }

  void _submitTyped() {
    final target = widget.mode == ReviewMode.reverseRecall
        ? widget.item.word
        : widget.mode == ReviewMode.exampleCompletion
            ? widget.item.word
            : widget.item.meaning;
    final correct = _fuzzyMatch(_textCtrl.text, target);
    setState(() => _isCorrectShown = correct);
    Future.delayed(const Duration(milliseconds: 500), () {
      widget.onAnswered(correct, _textCtrl.text.trim());
    });
  }

  void _submitChoice(String choice) {
    final correct = choice == widget.item.meaning;
    setState(() {
      _selectedOption = choice;
      _isCorrectShown = correct;
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      widget.onAnswered(correct, choice);
    });
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.mode) {
      case ReviewMode.meaningRecall:
        return _typedQuestion(
          prompt: widget.item.word,
          question: 'এই শব্দের অর্থ কী?',
          hint: 'অর্থ লিখুন',
        );
      case ReviewMode.reverseRecall:
        return _typedQuestion(
          prompt: widget.item.meaning,
          question: 'ইংরেজি শব্দটি কী?',
          hint: 'ইংরেজি শব্দ লিখুন',
        );
      case ReviewMode.exampleCompletion:
        final blanked = widget.item.exampleSentence.isEmpty
            ? '${widget.item.word} — উদাহরণ বাক্য নেই, শব্দটি আবার লিখুন।'
            : widget.item.exampleSentence
                .replaceAll(RegExp(widget.item.word, caseSensitive: false), '______');
        return _typedQuestion(
          prompt: blanked,
          question: 'ফাঁকা জায়গায় কোন শব্দ বসবে?',
          hint: 'শব্দটি লিখুন',
        );
      case ReviewMode.multipleChoice:
        return _multipleChoiceQuestion();
    }
  }

  Widget _typedQuestion(
      {required String prompt, required String question, required String hint}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IosCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              Text(prompt,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(question, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _textCtrl,
          enabled: _isCorrectShown == null,
          decoration: InputDecoration(hintText: hint),
          onSubmitted: (_) => _submitTyped(),
        ),
        const SizedBox(height: AppSpacing.md),
        if (_isCorrectShown != null)
          _FeedbackBanner(
            isCorrect: _isCorrectShown!,
            correctAnswer: widget.mode == ReviewMode.meaningRecall
                ? widget.item.meaning
                : widget.item.word,
          )
        else
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
                onPressed: _submitTyped, child: const Text('জমা দিন')),
          ),
      ],
    );
  }

  Widget _multipleChoiceQuestion() {
    if (_choices == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IosCard(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Text(widget.item.word,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('এই শব্দের সঠিক অর্থ কোনটি?',
            style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: AppSpacing.md),
        ..._choices!.map((choice) {
          Color? color;
          if (_selectedOption != null) {
            if (choice == widget.item.meaning) {
              color = AppColors.success;
            } else if (choice == _selectedOption) {
              color = AppColors.danger;
            }
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed:
                    _selectedOption == null ? () => _submitChoice(choice) : null,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: color ?? AppColors.separatorLight, width: color != null ? 2 : 1),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(choice),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _FeedbackBanner extends StatelessWidget {
  final bool isCorrect;
  final String correctAnswer;
  const _FeedbackBanner({required this.isCorrect, required this.correctAnswer});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: (isCorrect ? AppColors.success : AppColors.danger)
            .withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Icon(isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
              color: isCorrect ? AppColors.success : AppColors.danger),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(isCorrect ? 'সঠিক হয়েছে!' : 'সঠিক উত্তর: $correctAnswer'),
          ),
        ],
      ),
    );
  }
}
