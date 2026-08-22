/// Sample vocabulary shown to first-time users who tap
/// "Try Sample Vocabulary" instead of adding their own words right away.
/// Purely local, static data — no network or account needed.
class SampleWord {
  final String word;
  final String meaning;
  final String example;
  const SampleWord(this.word, this.meaning, this.example);
}

const List<SampleWord> sampleVocabulary = [
  SampleWord('reliable', 'বিশ্বস্ত', 'He is a reliable worker.'),
  SampleWord('although', 'যদিও', 'Although it rained, we went out.'),
  SampleWord('environment', 'পরিবেশ', 'We must protect the environment.'),
  SampleWord('improve', 'উন্নতি করা', 'I want to improve my English.'),
  SampleWord('opportunity', 'সুযোগ', 'This job is a great opportunity.'),
  SampleWord('achieve', 'অর্জন করা', 'She worked hard to achieve her goal.'),
  SampleWord('confident', 'আত্মবিশ্বাসী', 'He felt confident before the exam.'),
  SampleWord('essential', 'অপরিহার্য', 'Water is essential for life.'),
  SampleWord('particular', 'নির্দিষ্ট', 'I have no particular preference.'),
  SampleWord('generous', 'উদার', 'My uncle is very generous.'),
];
