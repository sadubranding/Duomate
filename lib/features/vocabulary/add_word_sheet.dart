import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers.dart';

class AddWordSheet extends ConsumerStatefulWidget {
  const AddWordSheet({super.key});

  @override
  ConsumerState<AddWordSheet> createState() => _AddWordSheetState();
}

class _AddWordSheetState extends ConsumerState<AddWordSheet> {
  final _wordCtrl = TextEditingController();
  final _meaningCtrl = TextEditingController();
  final _exampleCtrl = TextEditingController();
  bool _showMore = false;
  bool _saving = false;

  @override
  void dispose() {
    _wordCtrl.dispose();
    _meaningCtrl.dispose();
    _exampleCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_wordCtrl.text.trim().isEmpty || _meaningCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('শব্দ আর অর্থ দুটোই লিখতে হবে')),
      );
      return;
    }
    setState(() => _saving = true);
    await ref.read(databaseProvider).addVocabulary(
          word: _wordCtrl.text,
          meaning: _meaningCtrl.text,
          exampleSentence: _exampleCtrl.text,
        );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('নতুন শব্দ যোগ করুন',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _wordCtrl,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'ইংরেজি শব্দ (যেমন: reliable)'),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _meaningCtrl,
            decoration: const InputDecoration(hintText: 'অর্থ (যেমন: বিশ্বস্ত)'),
          ),
          if (_showMore) ...[
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _exampleCtrl,
              decoration: const InputDecoration(
                  hintText: 'উদাহরণ বাক্য (ঐচ্ছিক)'),
            ),
          ],
          TextButton(
            onPressed: () => setState(() => _showMore = !_showMore),
            child: Text(_showMore ? 'কম দেখান' : '+ আরও তথ্য যোগ করুন (ঐচ্ছিক)'),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('সংরক্ষণ করুন'),
            ),
          ),
        ],
      ),
    );
  }
}
