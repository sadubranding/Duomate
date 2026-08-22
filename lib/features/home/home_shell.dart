import 'package:flutter/material.dart';
import '../home/home_screen.dart';
import '../vocabulary/vocabulary_list_screen.dart';
import '../review/review_screen.dart';
import '../practice/practice_screen.dart';
import '../progress/progress_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tab = 0;

  final _screens = const [
    HomeScreen(),
    VocabularyListScreen(),
    ReviewScreen(),
    PracticeScreen(),
    ProgressScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _tab, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded), label: 'হোম'),
          BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_rounded), label: 'শব্দভাণ্ডার'),
          BottomNavigationBarItem(
              icon: Icon(Icons.refresh_rounded), label: 'রিভিউ'),
          BottomNavigationBarItem(
              icon: Icon(Icons.edit_rounded), label: 'অনুশীলন'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_rounded), label: 'অগ্রগতি'),
        ],
      ),
    );
  }
}
