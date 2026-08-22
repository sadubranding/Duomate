import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';
import '../home/home_shell.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingPage {
  final IconData icon;
  final String title;
  final String subtitle;
  const _OnboardingPage(this.icon, this.title, this.subtitle);
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  final _pages = const [
    _OnboardingPage(Icons.auto_stories_rounded, 'DuoMate-এ স্বাগতম',
        'আপনার প্রিয় অ্যাপে (যেমন Duolingo) যা শিখছেন, তা এখানে গুছিয়ে রাখুন।'),
    _OnboardingPage(Icons.bookmark_added_rounded, 'শব্দ সংরক্ষণ করুন',
        'নতুন শেখা প্রতিটা ইংরেজি শব্দ কয়েক সেকেন্ডে যোগ করুন।'),
    _OnboardingPage(Icons.refresh_rounded, 'স্মার্ট রিভিশন',
        'সঠিক সময়ে সঠিক শব্দ আবার মনে করিয়ে দেবে DuoMate — যাতে ভুলে না যান।'),
    _OnboardingPage(Icons.edit_note_rounded, 'নিজের বাক্য লিখুন',
        'শেখা শব্দ দিয়ে নিজে বাক্য বানিয়ে অনুশীলন করুন।'),
    _OnboardingPage(Icons.flag_rounded, 'দৈনিক লক্ষ্য ঠিক করুন',
        'প্রতিদিন অল্প অল্প করে চর্চা করে ধারাবাহিকতা তৈরি করুন।'),
  ];

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _index == _pages.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: TextButton(
                  onPressed: _finish,
                  child: const Text('স্কিপ করুন'),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) {
                  final page = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(page.icon,
                              size: 56, color: AppColors.primary),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Text(page.title,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineMedium),
                        const SizedBox(height: AppSpacing.sm),
                        Text(page.subtitle,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == _index ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: i == _index
                        ? AppColors.primary
                        : AppColors.primary.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLast
                      ? _finish
                      : () => _controller.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut),
                  child: Text(isLast ? 'শুরু করি' : 'পরবর্তী'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
