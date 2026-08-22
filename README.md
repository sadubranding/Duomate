# DuoMate

**Learn with your favorite language app. Remember with DuoMate.**

DuoMate is an independent, open-source companion app for people learning
English with apps like Duolingo. It helps you save vocabulary you've learned
elsewhere, review it with a spaced-repetition system, track your mistakes,
and practice writing your own sentences — fully offline, with no account
required.

> **Disclaimer:** DuoMate is an independent open-source project and is **not
> affiliated with, endorsed by, or sponsored by Duolingo**. It does not
> access Duolingo accounts or data in any way.

## Features (MVP)

- Vocabulary manager (add / edit / delete / search / filter)
- Quick-add flow — save a word in seconds
- Spaced-repetition review engine (4 question modes: meaning recall,
  multiple choice, reverse recall, example completion)
- Mistake bank — surfaces the words you get wrong most often
- Sentence practice — write and save your own example sentences
- Progress dashboard — streak, totals, weekly activity chart
- Daily goal with progress tracking
- Light / dark / system theme
- 100% offline, local SQLite database (via Drift), no account needed

## Getting an installable APK (no local setup required)

This repo includes a GitHub Actions workflow
(`.github/workflows/build-apk.yml`) that automatically builds a release APK
every time code is pushed to the `main` branch.

1. Push/upload this code to a GitHub repository.
2. Go to the **Actions** tab of the repository.
3. Open the latest **Build DuoMate APK** run.
4. Download the `duomate-apk` artifact — that's your installable APK.

## Tech stack

- **Flutter / Dart**
- **Drift** (type-safe SQLite) for the local database — chosen over Isar or
  raw sqflite for compile-time-checked queries and reactive streams, which
  suit a dashboard-heavy, offline-first app well.
- **Riverpod** for state management
- **fl_chart** for the weekly activity chart

## Project structure

```
lib/
├── core/            # theme, providers, shared utilities (review scheduler)
├── database/         # Drift schema + queries
├── features/
│   ├── onboarding/
│   ├── home/
│   ├── vocabulary/
│   ├── review/
│   ├── practice/
│   ├── progress/
│   └── settings/
└── main.dart
```

## Roadmap

- [ ] Local notifications for due reviews
- [ ] Export / import (JSON/CSV backup)
- [ ] Sample vocabulary data for first-time users
- [ ] Unit + widget tests
- [ ] Optional AI-assisted sentence feedback (off by default, not required
      for core functionality)

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT — see [LICENSE](LICENSE).
