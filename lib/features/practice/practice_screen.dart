import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers.dart';
import '../../database/database.dart';

class PracticeScreen extends ConsumerWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vocab = ref.watch(allVocabularyProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('বাক্য অনুশীলন')),
      body: vocab.when(
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Text('অনুশীলনের জন্য প্রথমে কিছু শব্দ যোগ করুন।',
                  style: Theme.of(context).textTheme.bodyLarge),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, i) {
              final item = list[i];
              return IosCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(item.word,
                      style: Theme.of(context).textTheme.titleMedium),
                  subtitle: Text(item.meaning),
                  trailing: const Icon(Icons.edit_note_rounded),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => _SentencePracticeDetail(item: item),
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('সমস্যা হয়েছে: $e')),
      ),
    );
  }
}

class _SentencePracticeDetail extends ConsumerStatefulWidget {
  final VocabularyItem item;
  const _SentencePracticeDetail({required this.item});

  @override
  ConsumerState<_SentencePracticeDetail> createState() =>
      _SentencePracticeDetailState();
}

class _SentencePracticeDetailState
    extends ConsumerState<_SentencePracticeDetail> {
  final _ctrl = TextEditingController();

  Future<void> _submit() async {
    if (_ctrl.text.trim().isEmpty) return;
    final db = ref.read(databaseProvider);
    await db.addSentence(widget.item.id, _ctrl.text.trim());
    await db.logActivity(sentences: 1);
    _ctrl.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sentences =
        ref.watch(databaseProvider).watchSentencesFor(widget.item.id);

    return Scaffold(
      appBar: AppBar(title: Text(widget.item.word)),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            IosCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('"${widget.item.word}" দিয়ে একটা বাক্য বানান',
                      style: Theme.of(context).textTheme.titleMedium),
                  if (widget.item.exampleSentence.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text('উদাহরণ: ${widget.item.exampleSentence}',
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _ctrl,
              maxLines: 2,
              decoration:
                  const InputDecoration(hintText: 'আপনার বাক্য লিখুন...'),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: _submit, child: const Text('সংরক্ষণ করুন')),
            ),
            const SizedBox(height: AppSpacing.lg),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('আগের বাক্যগুলো',
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: StreamBuilder<List<PracticeSentence>>(
                stream: sentences,
                builder: (context, snapshot) {
                  final list = snapshot.data ?? [];
                  if (list.isEmpty) {
                    return const Center(child: Text('এখনো কোনো বাক্য লেখা হয়নি।'));
                  }
                  return ListView.separated(
                    itemCount: list.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, i) => IosCard(
                      child: Row(
                        children: [
                          Expanded(child: Text(list[i].sentence)),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded,
                                size: 20),
                            onPressed: () => ref
                                .read(databaseProvider)
                                .deleteSentence(list[i].id),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
