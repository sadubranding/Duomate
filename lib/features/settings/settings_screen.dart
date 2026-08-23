import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import '../../core/theme/app_theme.dart';
import '../../core/providers.dart';
import '../../core/services/notification_service.dart';
import '../../database/database.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _onNotificationToggle(
      AppDatabase db, bool enabled) async {
    if (enabled) {
      await NotificationService.instance.requestPermission();
      await NotificationService.instance.scheduleDailyReminder();
    } else {
      await NotificationService.instance.cancelAll();
    }
    await db.upsertSettings(
        UserSettingsCompanion(notificationsEnabled: Value(enabled)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsStreamProvider);
    final db = ref.read(databaseProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('সেটিংস')),
      body: settings.when(
        data: (s) => ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Text('থিম', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            IosCard(
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: const Text('সিস্টেম অনুযায়ী'),
                    value: 'system',
                    groupValue: s.theme,
                    onChanged: (v) => db.upsertSettings(
                        UserSettingsCompanion(theme: Value(v!))),
                  ),
                  RadioListTile<String>(
                    title: const Text('হালকা (Light)'),
                    value: 'light',
                    groupValue: s.theme,
                    onChanged: (v) => db.upsertSettings(
                        UserSettingsCompanion(theme: Value(v!))),
                  ),
                  RadioListTile<String>(
                    title: const Text('গাঢ় (Dark)'),
                    value: 'dark',
                    groupValue: s.theme,
                    onChanged: (v) => db.upsertSettings(
                        UserSettingsCompanion(theme: Value(v!))),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('দৈনিক লক্ষ্য', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            IosCard(
              child: Column(
                children: [
                  Text('${s.dailyGoal} টি রিভিউ/দিন',
                      style: Theme.of(context).textTheme.bodyLarge),
                  Slider(
                    value: s.dailyGoal.toDouble(),
                    min: 5,
                    max: 50,
                    divisions: 9,
                    label: '${s.dailyGoal}',
                    onChanged: (v) => db.upsertSettings(
                        UserSettingsCompanion(dailyGoal: Value(v.round()))),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('নোটিফিকেশন', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            IosCard(
              child: SwitchListTile(
                title: const Text('রিভিউ রিমাইন্ডার'),
                subtitle:
                    const Text('প্রতিদিন সন্ধ্যা ৮টায় মনে করিয়ে দেবে (বাকি থাকলে)'),
                value: s.notificationsEnabled,
                onChanged: (v) => _onNotificationToggle(db, v),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            IosCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('DuoMate সম্পর্কে',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'DuoMate একটি স্বাধীন, ওপেন-সোর্স প্রজেক্ট। এটি Duolingo-র '
                    'সাথে কোনোভাবে সম্পর্কিত, অনুমোদিত বা স্পনসরকৃত নয়।',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('সমস্যা হয়েছে: $e')),
      ),
    );
  }
}
