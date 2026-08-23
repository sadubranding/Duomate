import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers.dart';
import '../vocabulary/add_word_sheet.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsStreamProvider);
    final vocab = ref.watch(allVocabularyProvider);
    final due = ref.watch(dueForReviewProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('DuoMate'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {},
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            settings.when(
              data: (s) => IosCard(
                child: Row(
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 32)),
                    const SizedBox(width: AppSpacing.md),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${s.currentStreak} দিনের ধারাবাহিকতা',
                            style: Theme.of(context).textTheme.titleMedium),
                        Text('সর্বোচ্চ: ${s.longestStreak} দিন',
                            style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ],
                ),
              ),
              loading: () => const SizedBox(
                  height: 60, child: Center(child: CircularProgressIndicator())),
              error: (e, _) => const SizedBox.shrink(),
            ),
            const SizedBox(height: AppSpacing.md),
            settings.when(
              data: (s) => StreamBuilder(
                stream: ref.read(databaseProvider).watchToday(),
                builder: (context, snapshot) {
                  final done = snapshot.data?.reviewsCompleted ?? 0;
                  final goal = s.dailyGoal;
                  final progress = goal == 0 ? 0.0 : (done / goal).clamp(0, 1);
                  final reached = done >= goal;
                  return IosCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('🎯 আজকের লক্ষ্য',
                                style: Theme.of(context).textTheme.titleMedium),
                            Text('$done / $goal',
                                style: Theme.of(context).textTheme.titleMedium),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          child: LinearProgressIndicator(
                            value: progress.toDouble(),
                            minHeight: 8,
                            backgroundColor: AppColors.separatorLight,
                            color: reached ? AppColors.success : AppColors.primary,
                          ),
                        ),
                        if (reached) ...[
                          const SizedBox(height: AppSpacing.sm),
                          const Text('🎉 আজকের লক্ষ্য পূরণ হয়েছে!'),
                        ],
                      ],
                    ),
                  );
                },
              ),
              loading: () => const SizedBox.shrink(),
              error: (e, _) => const SizedBox.shrink(),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: vocab.when(
                    data: (list) => _StatCard(
                        icon: Icons.menu_book_rounded,
                        label: 'মোট শব্দ',
                        value: '${list.length}'),
                    loading: () => const _StatCardSkeleton(),
                    error: (e, _) => const _StatCardSkeleton(),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: due.when(
                    data: (list) => _StatCard(
                        icon: Icons.notifications_active_rounded,
                        label: 'রিভিউ বাকি',
                        value: '${list.length}',
                        highlight: list.isNotEmpty),
                    loading: () => const _StatCardSkeleton(),
                    error: (e, _) => const _StatCardSkeleton(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => const AddWordSheet(),
                ),
                icon: const Icon(Icons.add_rounded),
                label: const Text('+ নতুন শব্দ যোগ করুন'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool highlight;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return IosCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon,
              color: highlight ? AppColors.warning : AppColors.primary),
          const SizedBox(height: AppSpacing.sm),
          Text(value, style: Theme.of(context).textTheme.headlineMedium),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _StatCardSkeleton extends StatelessWidget {
  const _StatCardSkeleton();
  @override
  Widget build(BuildContext context) =>
      const IosCard(child: SizedBox(height: 64));
}
