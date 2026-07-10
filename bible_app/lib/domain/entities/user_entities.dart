import 'package:equatable/equatable.dart';

/// Represents a user bookmark for a specific verse.
class Bookmark extends Equatable {
  final String id;
  final String userId;
  final String bookId;
  final int chapterNumber;
  final int verseNumber;
  final DateTime createdAt;

  const Bookmark({
    required this.id,
    required this.userId,
    required this.bookId,
    required this.chapterNumber,
    required this.verseNumber,
    required this.createdAt,
  });

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      bookId: json['book_id'] as String,
      chapterNumber: json['chapter_number'] as int,
      verseNumber: json['verse_number'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'book_id': bookId,
      'chapter_number': chapterNumber,
      'verse_number': verseNumber,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        bookId,
        chapterNumber,
        verseNumber,
        createdAt,
      ];
}

/// Represents a highlight on one or more verses.
class Highlight extends Equatable {
  final String id;
  final String userId;
  final String bookId;
  final int chapterNumber;
  final int startVerseNumber;
  final int? endVerseNumber; // null if single verse
  final String colorHex; // e.g., '#FFFF00' for yellow
  final DateTime createdAt;

  const Highlight({
    required this.id,
    required this.userId,
    required this.bookId,
    required this.chapterNumber,
    required this.startVerseNumber,
    this.endVerseNumber,
    required this.colorHex,
    required this.createdAt,
  });

  factory Highlight.fromJson(Map<String, dynamic> json) {
    return Highlight(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      bookId: json['book_id'] as String,
      chapterNumber: json['chapter_number'] as int,
      startVerseNumber: json['start_verse_number'] as int,
      endVerseNumber: json['end_verse_number'] as int?,
      colorHex: json['color_hex'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'book_id': bookId,
      'chapter_number': chapterNumber,
      'start_verse_number': startVerseNumber,
      'end_verse_number': endVerseNumber,
      'color_hex': colorHex,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        bookId,
        chapterNumber,
        startVerseNumber,
        endVerseNumber,
        colorHex,
        createdAt,
      ];
}

/// Represents a personal note on a passage.
class Note extends Equatable {
  final String id;
  final String userId;
  final String bookId;
  final int chapterNumber;
  final int? startVerseNumber;
  final int? endVerseNumber;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Note({
    required this.id,
    required this.userId,
    required this.bookId,
    required this.chapterNumber,
    this.startVerseNumber,
    this.endVerseNumber,
    required this.content,
    required this.createdAt,
    this.updatedAt,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      bookId: json['book_id'] as String,
      chapterNumber: json['chapter_number'] as int,
      startVerseNumber: json['start_verse_number'] as int?,
      endVerseNumber: json['end_verse_number'] as int?,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'book_id': bookId,
      'chapter_number': chapterNumber,
      'start_verse_number': startVerseNumber,
      'end_verse_number': endVerseNumber,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        bookId,
        chapterNumber,
        startVerseNumber,
        endVerseNumber,
        content,
        createdAt,
        updatedAt,
      ];
}

/// Represents a reading plan.
class ReadingPlan extends Equatable {
  final String id;
  final String name;
  final String description;
  final int totalDays;
  final bool isCustom;
  final String? createdBy; // userId if custom

  const ReadingPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.totalDays,
    required this.isCustom,
    this.createdBy,
  });

  factory ReadingPlan.fromJson(Map<String, dynamic> json) {
    return ReadingPlan(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      totalDays: json['total_days'] as int,
      isCustom: json['is_custom'] as bool,
      createdBy: json['created_by'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'total_days': totalDays,
      'is_custom': isCustom,
      'created_by': createdBy,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        totalDays,
        isCustom,
        createdBy,
      ];
}

/// Represents a user's progress in a reading plan.
class ReadingPlanProgress extends Equatable {
  final String id;
  final String userId;
  final String planId;
  final int currentDay;
  final Set<int> completedDays;
  final DateTime startDate;
  final DateTime? lastCompletedDate;
  final int streak;

  const ReadingPlanProgress({
    required this.id,
    required this.userId,
    required this.planId,
    required this.currentDay,
    required this.completedDays,
    required this.startDate,
    this.lastCompletedDate,
    required this.streak,
  });

  factory ReadingPlanProgress.fromJson(Map<String, dynamic> json) {
    final completedDaysList = (json['completed_days'] as List<dynamic>).cast<int>();
    return ReadingPlanProgress(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      planId: json['plan_id'] as String,
      currentDay: json['current_day'] as int,
      completedDays: completedDaysList.toSet(),
      startDate: DateTime.parse(json['start_date'] as String),
      lastCompletedDate: json['last_completed_date'] != null
          ? DateTime.parse(json['last_completed_date'] as String)
          : null,
      streak: json['streak'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'plan_id': planId,
      'current_day': currentDay,
      'completed_days': completedDays.toList(),
      'start_date': startDate.toIso8601String(),
      'last_completed_date': lastCompletedDate?.toIso8601String(),
      'streak': streak,
    };
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        planId,
        currentDay,
        completedDays,
        startDate,
        lastCompletedDate,
        streak,
      ];
}

/// Represents a downloaded fileset (book/chapter) for offline use.
class Download extends Equatable {
  final String id;
  final String userId;
  final String filesetId;
  final String bookId;
  final String bookName;
  final int? chapterNumber; // null if entire book
  final String type; // 'audio' or 'text'
  final int fileSizeBytes;
  final DateTime downloadedAt;
  final bool isComplete;

  const Download({
    required this.id,
    required this.userId,
    required this.filesetId,
    required this.bookId,
    required this.bookName,
    this.chapterNumber,
    required this.type,
    required this.fileSizeBytes,
    required this.downloadedAt,
    required this.isComplete,
  });

  factory Download.fromJson(Map<String, dynamic> json) {
    return Download(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      filesetId: json['fileset_id'] as String,
      bookId: json['book_id'] as String,
      bookName: json['book_name'] as String,
      chapterNumber: json['chapter_number'] as int?,
      type: json['type'] as String,
      fileSizeBytes: json['file_size_bytes'] as int,
      downloadedAt: DateTime.parse(json['downloaded_at'] as String),
      isComplete: json['is_complete'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'fileset_id': filesetId,
      'book_id': bookId,
      'book_name': bookName,
      'chapter_number': chapterNumber,
      'type': type,
      'file_size_bytes': fileSizeBytes,
      'downloaded_at': downloadedAt.toIso8601String(),
      'is_complete': isComplete,
    };
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        filesetId,
        bookId,
        bookName,
        chapterNumber,
        type,
        fileSizeBytes,
        downloadedAt,
        isComplete,
      ];
}
