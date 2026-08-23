# Changelog

All notable changes to DuoMate are documented here.
This project follows [Semantic Versioning](https://semver.org/) (MAJOR.MINOR.PATCH).

## [0.2.0] - Unreleased

### Added
- Local notifications — daily review reminder, fully user-controlled
- Export / Import — JSON backup via system share sheet / file picker
- Vocabulary filter chips (All / Due / Mastered / Difficult / Recent)
- Daily goal progress bar on Home ("7 / 10 completed")
- Automated tests: 12 tests covering the review scheduler and database
  (vocabulary CRUD, search, mistake tracking, streak)

## [0.1.0] - Released as v0.1.0

### Added
- Onboarding flow (5 skippable screens) with sample-vocabulary option
- Vocabulary manager: add, edit, delete, search
- Quick-add bottom sheet
- Spaced-repetition review engine with 4 modes (meaning recall, multiple
  choice, reverse recall, example completion)
- Mistake bank (words ranked by wrong-answer count)
- Sentence practice screen
- Progress dashboard: streak, totals, weekly activity chart
- Settings: theme (light/dark/system), daily goal
- Local offline-first database (Drift/SQLite)
- Automated APK builds via GitHub Actions

### Not yet included
- Custom app icon / splash screen
