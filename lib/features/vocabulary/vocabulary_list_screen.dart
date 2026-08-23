import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers.dart';
import '../../database/database.dart';
import 'add_word_sheet.dart';
import 'word_detail_screen.dart';

enum _VocabFilter { all, due, mastered, difficult, recent }

class VocabularyListScreen extends ConsumerStatefulWidget {
  const VocabularyListScreen({super.key});

  @override
  ConsumerState<VocabularyListScreen> createState() =>
      _VocabularyListScreenState();
}

class _VocabularyListScreenState extends ConsumerState<VocabularyListScreen> {
  String _query = '';
  _VocabFilter _filter = _VocabFilter.all;

  List<VocabularyItem> _applyFilter(List<VocabularyItem> list) {
    final now = DateTime.now();
    switch (_filter) {
      case _VocabFilter.all:
        return list;
      case _VocabFilter.due:
        return list
            .where((v) => !v.mastered && v.nextReviewAt.isBefore(now))
            .toList();
      case _VocabFilter.mastered:
        return list.where((v) => v.mastered).toList();
      case _VocabFilter.difficult:
        return list.where((v) => v.difficulty >= 3).toList()
          ..sort((a, b) => b.wrongCount.compareTo(a.wrongCount));
      case _VocabFilter.recent:
        final sorted = List.of(list)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return sorted.take(20).toList();
    }
  }

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
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _filterChip('সব', _VocabFilter.all),
                  _filterChip('রিভিউ বাকি', _VocabFilter.due),
                  _filterChip('আয়ত্তে আনা', _VocabFilter.mastered),
                  _filterChip('কঠিন', _VocabFilter.difficult),
                  _filterChip('সাম্প্রতিক', _VocabFilter.recent),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: vocab.when(
                data: (list) {
                  final byFilter = _applyFilter(list);
                  final filtered = _query.isEmpty
                      ? byFilter
                      : byFilter
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

  Widget _filterChip(String label, _VocabFilter value) {
    final selected = _filter == value;
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => setState(() => _filter = value),
        selectedColor: AppColors.primary.withValues(alpha: 0.15),
        labelStyle: TextStyle(
          color: selected ? AppColors.primary : null,
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        ),
        side: BorderSide(
          color: selected ? AppColors.primary : AppColors.separatorLight,
        ),
      ),
    );
  }
}
