import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers.dart';
import '../../database/database.dart';

class WordDetailScreen extends ConsumerStatefulWidget {
  final VocabularyItem item;
  const WordDetailScreen({super.key, required this.item});

  @override
  ConsumerState<WordDetailScreen> createState() => _WordDetailScreenState();
}

class _WordDetailScreenState extends ConsumerState<WordDetailScreen> {
  late TextEditingController _wordCtrl;
  late TextEditingController _meaningCtrl;
  late TextEditingController _exampleCtrl;
  late TextEditingController _notesCtrl;

  @override
  void initState() {
    super.initState();
    _wordCtrl = TextEditingController(text: widget.item.word);
    _meaningCtrl = TextEditingController(text: widget.item.meaning);
    _exampleCtrl = TextEditingController(text: widget.item.exampleSentence);
    _notesCtrl = TextEditingController(text: widget.item.notes);
  }

  @override
  void dispose() {
    _wordCtrl.dispose();
    _meaningCtrl.dispose();
    _exampleCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final updated = widget.item.copyWith(
      word: _wordCtrl.text.trim(),
      meaning: _meaningCtrl.text.trim(),
      exampleSentence: _exampleCtrl.text.trim(),
      notes: _notesCtrl.text.trim(),
    );
    await ref.read(databaseProvider).updateVocabulary(updated);
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('সংরক্ষিত হয়েছে')));
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('মুছে ফেলবেন?'),
        content: Text('"${widget.item.word}" শব্দটি স্থায়ীভাবে মুছে যাবে।'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('বাতিল')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('মুছুন',
                  style: TextStyle(color: AppColors.danger))),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(databaseProvider).deleteVocabulary(widget.item.id);
      if (mounted) Navigator.of(context).pop();
    }
  }

  Future<void> _toggleMastered() async {
    await ref.read(databaseProvider).updateVocabulary(
        widget.item.copyWith(mastered: !widget.item.mastered));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final accuracy = (widget.item.correctCount + widget.item.wrongCount) == 0
        ? 0.0
        : widget.item.correctCount /
            (widget.item.correctCount + widget.item.wrongCount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('শব্দের বিস্তারিত'),
        actions: [
          IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: _delete),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          IosCard(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('✅ ${widget.item.correctCount} সঠিক  ·  '
                              '❌ ${widget.item.wrongCount} ভুল'),
                          const SizedBox(height: 4),
                          Text('নির্ভুলতা: ${(accuracy * 100).round()}%'),
                        ],
                      ),
                    ),
                    FilterChip(
                      label: Text(widget.item.mastered ? 'আয়ত্তে' : 'শিখছি'),
                      selected: widget.item.mastered,
                      onSelected: (_) => _toggleMastered(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _wordCtrl,
            decoration: const InputDecoration(labelText: 'শব্দ'),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _meaningCtrl,
            decoration: const InputDecoration(labelText: 'অর্থ'),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _exampleCtrl,
            decoration: const InputDecoration(labelText: 'উদাহরণ বাক্য'),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _notesCtrl,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'নোট'),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
                onPressed: _save, child: const Text('পরিবর্তন সংরক্ষণ করুন')),
          ),
        ],
      ),
    );
  }
}
