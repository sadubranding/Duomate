import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers.dart';
import '../../database/database.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsStreamProvider);
    final vocab = ref.watch(allVocabularyProvider);
    final weekly = ref.watch(databaseProvider).watchLastNDays(7);

    return Scaffold(
      appBar: AppBar(title: const Text('অগ্রগতি')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          settings.when(
            data: (s) => vocab.when(
              data: (list) {
                final mastered = list.where((v) => v.mastered).length;
                final totalCorrect =
                    list.fold<int>(0, (sum, v) => sum + v.correctCount);
                final totalWrong =
                    list.fold<int>(0, (sum, v) => sum + v.wrongCount);
                final accuracy = (totalCorrect + totalWrong) == 0
                    ? 0
                    : (totalCorrect / (totalCorrect + totalWrong) * 100).round();

                return GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: AppSpacing.sm,
                  crossAxisSpacing: AppSpacing.sm,
                  childAspectRatio: 1.4,
                  children: [
                    _StatTile('🔥', '${s.currentStreak}', 'দিনের streak'),
                    _StatTile('📚', '${list.length}', 'মোট শব্দ'),
                    _StatTile('✅', '$mastered', 'আয়ত্তে আনা'),
                    _StatTile('🎯', '$accuracy%', 'নির্ভুলতা'),
                  ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (e, _) => const SizedBox.shrink(),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => const SizedBox.shrink(),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('সাপ্তাহিক কার্যক্রম',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          StreamBuilder<List<DailyActivityData>>(
            stream: weekly,
            builder: (context, snapshot) {
              final data = snapshot.data ?? [];
              final byDay = {for (final d in data) d.date.weekday: d.reviewsCompleted};
              final bars = List.generate(7, (i) {
                final weekday = i + 1;
                final value = (byDay[weekday] ?? 0).toDouble();
                return BarChartGroupData(x: i, barRods: [
                  BarChartRodData(
                      toY: value,
                      color: AppColors.primary,
                      width: 18,
                      borderRadius: BorderRadius.circular(4)),
                ]);
              });
              return IosCard(
                child: SizedBox(
                  height: 160,
                  child: BarChart(BarChartData(
                    barGroups: bars,
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const days = ['সোম', 'মঙ্গল', 'বুধ', 'বৃহঃ', 'শুক্র', 'শনি', 'রবি'];
                            return Text(days[value.toInt() % 7],
                                style: const TextStyle(fontSize: 10));
                          },
                        ),
                      ),
                    ),
                  )),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('যেসব শব্দে বেশি ভুল হয়',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          FutureBuilder<List<VocabularyItem>>(
            future: ref.read(databaseProvider).mostMistakenWords(),
            builder: (context, snapshot) {
              final list = snapshot.data ?? [];
              if (list.isEmpty) {
                return const IosCard(
                    child: Text('এখনো কোনো ভুল রেকর্ড হয়নি — চমৎকার!'));
              }
              return Column(
                children: list
                    .map((v) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: IosCard(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(v.word,
                                      style:
                                          Theme.of(context).textTheme.titleMedium),
                                ),
                                Text('${v.wrongCount} ভুল',
                                    style: const TextStyle(color: AppColors.danger)),
                              ],
                            ),
                          ),
                        ))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  const _StatTile(this.emoji, this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return IosCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.headlineMedium),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}
