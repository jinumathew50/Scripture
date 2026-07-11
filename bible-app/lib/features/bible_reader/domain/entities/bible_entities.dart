import 'package:equatable/equatable.dart';

class BibleVersionEntity extends Equatable {
  final String id;
  final String name;
  final String abbreviation;
  final String language;
  final String? description;
  final bool hasAudio;
  final bool isDownloadable;

  const BibleVersionEntity({
    required this.id,
    required this.name,
    required this.abbreviation,
    required this.language,
    this.description,
    required this.hasAudio,
    required this.isDownloadable,
  });

  @override
  List<Object?> get props => [id, name, abbreviation, language, hasAudio, isDownloadable];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'abbreviation': abbreviation,
      'language': language,
      'description': description,
      'has_audio': hasAudio,
      'is_downloadable': isDownloadable,
    };
  }

  factory BibleVersionEntity.fromMap(Map<String, dynamic> map) {
    return BibleVersionEntity(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      abbreviation: map['abbreviation'] ?? '',
      language: map['language'] ?? '',
      description: map['description'],
      hasAudio: map['has_audio'] ?? false,
      isDownloadable: map['is_downloadable'] ?? false,
    );
  }
}

class BookEntity extends Equatable {
  final String id;
  final String name;
  final String abbreviation;
  final int bookNumber;
  final String testament; // 'OT' or 'NT'
  final int chapterCount;

  const BookEntity({
    required this.id,
    required this.name,
    required this.abbreviation,
    required this.bookNumber,
    required this.testament,
    required this.chapterCount,
  });

  @override
  List<Object?> get props => [id, name, abbreviation, bookNumber, testament, chapterCount];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'abbreviation': abbreviation,
      'book_number': bookNumber,
      'testament': testament,
      'chapter_count': chapterCount,
    };
  }

  factory BookEntity.fromMap(Map<String, dynamic> map) {
    return BookEntity(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      abbreviation: map['abbreviation'] ?? '',
      bookNumber: map['book_number'] ?? 0,
      testament: map['testament'] ?? '',
      chapterCount: map['chapter_count'] ?? 0,
    );
  }
}

class ChapterEntity extends Equatable {
  final String versionId;
  final String bookId;
  final int chapterNumber;
  final List<VerseEntity> verses;

  const ChapterEntity({
    required this.versionId,
    required this.bookId,
    required this.chapterNumber,
    required this.verses,
  });

  @override
  List<Object?> get props => [versionId, bookId, chapterNumber, verses];

  Map<String, dynamic> toMap() {
    return {
      'version_id': versionId,
      'book_id': bookId,
      'chapter_number': chapterNumber,
      'verses': verses.map((v) => v.toMap()).toList(),
    };
  }

  factory ChapterEntity.fromMap(Map<String, dynamic> map) {
    return ChapterEntity(
      versionId: map['version_id'] ?? '',
      bookId: map['book_id'] ?? '',
      chapterNumber: map['chapter_number'] ?? 0,
      verses: (map['verses'] as List?)
              ?.map((v) => VerseEntity.fromMap(v))
              .toList() ??
          [],
    );
  }
}

class VerseEntity extends Equatable {
  final String verseId;
  final int verseNumber;
  final String text;
  final double? audioStartTime;
  final double? audioEndTime;

  const VerseEntity({
    required this.verseId,
    required this.verseNumber,
    required this.text,
    this.audioStartTime,
    this.audioEndTime,
  });

  @override
  List<Object?> get props => [verseId, verseNumber, text, audioStartTime, audioEndTime];

  Map<String, dynamic> toMap() {
    return {
      'verse_id': verseId,
      'verse_number': verseNumber,
      'text': text,
      'audio_start_time': audioStartTime,
      'audio_end_time': audioEndTime,
    };
  }

  factory VerseEntity.fromMap(Map<String, dynamic> map) {
    return VerseEntity(
      verseId: map['verse_id'] ?? '',
      verseNumber: map['verse_number'] ?? 0,
      text: map['text'] ?? '',
      audioStartTime: map['audio_start_time']?.toDouble(),
      audioEndTime: map['audio_end_time']?.toDouble(),
    );
  }
}
