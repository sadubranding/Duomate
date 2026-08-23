import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import '../../core/theme/app_theme.dart';
import '../../core/providers.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/backup_service.dart';
import '../../database/database.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _onNotificationToggle(AppDatabase db, bool enabled) async {
    if (enabled) {
      await NotificationService.instance.requestPermission();
      await NotificationService.instance.scheduleDailyReminder();
    } else {
      await NotificationService.instance.cancelAll();
    }
    await db.upsertSettings(
        UserSettingsCompanion(notificationsEnabled: Value(enabled)));
  }

  Future<void> _export(BuildContext context, AppDatabase db) async {
    try {
      await BackupService(db).exportAndShare();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('এক্সপোর্ট ব্যর্থ হয়েছে: $e')));
      }
    }
  }

  Future<void> _import(BuildContext context, AppDatabase db) async {
    try {
      final count = await BackupService(db).importFromFile();
      if (!context.mounted) return;
      if (count == null) return; // user cancelled
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$count টি শব্দ ইম্পোর্ট হয়েছে')));
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('ইম্পোর্ট ব্যর্থ হয়েছে: $e')));
      }
    }
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
            const SizedBox(height: AppSpacing.lg),
            Text('ডেটা ব্যাকআপ', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            IosCard(
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.upload_file_rounded),
                    title: const Text('এক্সপোর্ট করুন'),
                    subtitle: const Text('সব শব্দ JSON ফাইলে সংরক্ষণ করুন'),
                    onTap: () => _export(context, db),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.download_rounded),
                    title: const Text('ইম্পোর্ট করুন'),
                    subtitle: const Text('আগের ব্যাকআপ ফাইল থেকে ফিরিয়ে আনুন'),
                    onTap: () => _import(context, db),
                  ),
                ],
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
