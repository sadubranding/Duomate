import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers.dart';
import 'add_word_sheet.dart';
import 'word_detail_screen.dart';

class VocabularyListScreen extends ConsumerStatefulWidget {
  const VocabularyListScreen({super.key});

  @override
  ConsumerState<VocabularyListScreen> createState() =>
      _VocabularyListScreenState();
}

class _VocabularyListScreenState extends ConsumerState<VocabularyListScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final vocab = ref.watch(allVocabularyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('শব্দভাণ্ডার'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => const AddWordSheet(),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'শব্দ বা অর্থ খুঁজুন...',
                prefixIcon: Icon(Icons.search_rounded),
              ),
              onChanged: (v) => setState(() => _query = v.toLowerCase()),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: vocab.when(
                data: (list) {
                  final filtered = _query.isEmpty
                      ? list
                      : list
                          .where((v) =>
                              v.word.toLowerCase().contains(_query) ||
                              v.meaning.toLowerCase().contains(_query))
                          .toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        list.isEmpty
                            ? 'এখনো কোনো শব্দ যোগ করা হয়নি।\nউপরে + বাটনে চাপুন।'
                            : 'কিছু পাওয়া যায়নি।',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, i) {
                      final item = filtered[i];
                      return IosCard(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(item.word,
                              style: Theme.of(context).textTheme.titleMedium),
                          subtitle: Text(item.meaning),
                          trailing: item.mastered
                              ? const Icon(Icons.check_circle_rounded,
                                  color: AppColors.success)
                              : null,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => WordDetailScreen(item: item),
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
            ),
          ],
        ),
      ),
    );
  }
}
