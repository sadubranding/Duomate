import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'core/providers.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/home/home_shell.dart';

void main() {
  runApp(const ProviderScope(child: DuoMateApp()));
}

class DuoMateApp extends ConsumerWidget {
  const DuoMateApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsStreamProvider);

    final themeMode = settings.maybeWhen(
      data: (s) => switch (s.theme) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      },
      orElse: () => ThemeMode.system,
    );

    return MaterialApp(
      title: 'DuoMate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      home: const _StartupGate(),
    );
  }
}

/// Decides whether to show onboarding or go straight to the app,
/// based on whether onboarding was completed before.
class _StartupGate extends StatelessWidget {
  const _StartupGate();

  Future<bool> _hasCompletedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_complete') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _hasCompletedOnboarding(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        return snapshot.data! ? const HomeShell() : const OnboardingScreen();
      },
    );
  }
}
