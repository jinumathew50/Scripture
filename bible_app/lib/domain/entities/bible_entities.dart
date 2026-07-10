import 'package:equatable/equatable.dart';

/// Represents a single verse in the Bible.
class Verse extends Equatable {
  final String bookId;
  final int chapterNumber;
  final int verseNumber;
  final String text;
  final String? audioUrl;
  final Duration? audioStartTime;
  final Duration? audioEndTime;

  const Verse({
    required this.bookId,
    required this.chapterNumber,
    required this.verseNumber,
    required this.text,
    this.audioUrl,
    this.audioStartTime,
    this.audioEndTime,
  });

  factory Verse.fromJson(Map<String, dynamic> json) {
    return Verse(
      bookId: json['book_id'] as String,
      chapterNumber: json['chapter_number'] as int,
      verseNumber: json['verse_number'] as int,
      text: json['text'] as String,
      audioUrl: json['audio_url'] as String?,
      audioStartTime: json['audio_start_time'] != null
          ? Duration(milliseconds: json['audio_start_time'] as int)
          : null,
      audioEndTime: json['audio_end_time'] != null
          ? Duration(milliseconds: json['audio_end_time'] as int)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'book_id': bookId,
      'chapter_number': chapterNumber,
      'verse_number': verseNumber,
      'text': text,
      'audio_url': audioUrl,
      'audio_start_time': audioStartTime?.inMilliseconds,
      'audio_end_time': audioEndTime?.inMilliseconds,
    };
  }

  @override
  List<Object?> get props => [
        bookId,
        chapterNumber,
        verseNumber,
        text,
        audioUrl,
        audioStartTime,
        audioEndTime,
      ];

  @override
  String toString() {
    return '$bookId $chapterNumber:$verseNumber';
  }
}

/// Represents a chapter containing multiple verses.
class Chapter extends Equatable {
  final String bookId;
  final String bookName;
  final int chapterNumber;
  final List<Verse> verses;
  final String? audioUrl;
  final String translationId;

  const Chapter({
    required this.bookId,
    required this.bookName,
    required this.chapterNumber,
    required this.verses,
    this.audioUrl,
    required this.translationId,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    final versesJson = json['verses'] as List<dynamic>;
    return Chapter(
      bookId: json['book_id'] as String,
      bookName: json['book_name'] as String,
      chapterNumber: json['chapter_number'] as int,
      verses: versesJson.map((v) => Verse.fromJson(v as Map<String, dynamic>)).toList(),
      audioUrl: json['audio_url'] as String?,
      translationId: json['translation_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'book_id': bookId,
      'book_name': bookName,
      'chapter_number': chapterNumber,
      'verses': verses.map((v) => v.toJson()).toList(),
      'audio_url': audioUrl,
      'translation_id': translationId,
    };
  }

  @override
  List<Object?> get props => [
        bookId,
        bookName,
        chapterNumber,
        verses,
        audioUrl,
        translationId,
      ];
}

/// Represents a book of the Bible containing chapters.
class Book extends Equatable {
  final String id;
  final String name;
  final String abbreviation;
  final int totalChapters;
  final String testament; // 'OT' or 'NT'

  const Book({
    required this.id,
    required this.name,
    required this.abbreviation,
    required this.totalChapters,
    required this.testament,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] as String,
      name: json['name'] as String,
      abbreviation: json['abbreviation'] as String,
      totalChapters: json['total_chapters'] as int,
      testament: json['testament'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'abbreviation': abbreviation,
      'total_chapters': totalChapters,
      'testament': testament,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        abbreviation,
        totalChapters,
        testament,
      ];
}

/// Represents a Bible translation/version.
class Translation extends Equatable {
  final String id;
  final String name;
  final String language;
  final String? description;
  final bool hasAudio;
  final bool isDownloadable;

  const Translation({
    required this.id,
    required this.name,
    required this.language,
    this.description,
    required this.hasAudio,
    required this.isDownloadable,
  });

  factory Translation.fromJson(Map<String, dynamic> json) {
    return Translation(
      id: json['id'] as String,
      name: json['name'] as String,
      language: json['language'] as String,
      description: json['description'] as String?,
      hasAudio: json['has_audio'] as bool? ?? false,
      isDownloadable: json['is_downloadable'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'language': language,
      'description': description,
      'has_audio': hasAudio,
      'is_downloadable': isDownloadable,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        language,
        description,
        hasAudio,
        isDownloadable,
      ];
}
