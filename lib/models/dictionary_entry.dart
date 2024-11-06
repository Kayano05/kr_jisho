class DictionaryEntry {
  final String word;
  final String partOfSpeech;
  final String kana;
  final List<String> examples;

  DictionaryEntry({
    required this.word,
    required this.partOfSpeech,
    required this.kana,
    required this.examples,
  });

  factory DictionaryEntry.fromJson(Map<String, dynamic> json) {
    return DictionaryEntry(
      word: json['word'] as String,
      partOfSpeech: json['partOfSpeech'] as String,
      kana: json['kana'] as String,
      examples: List<String>.from(json['examples']),
    );
  }
} 