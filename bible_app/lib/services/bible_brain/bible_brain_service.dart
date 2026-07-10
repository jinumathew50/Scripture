import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/bible_entities.dart';

/// Service for interacting with the Bible Brain API via Supabase Edge Functions.
/// 
/// This service acts as a proxy to Bible Brain API, ensuring API keys are never
/// exposed client-side. All requests go through Supabase Edge Functions.
class BibleBrainService {
  final String edgeFunctionUrl;
  final String? supabaseToken;

  BibleBrainService({
    required this.edgeFunctionUrl,
    this.supabaseToken,
  });

  /// Get a list of available Bible translations.
  Future<List<Translation>> getTranslations() async {
    final response = await http.get(
      Uri.parse('$edgeFunctionUrl/translations'),
      headers: {
        'Content-Type': 'application/json',
        if (supabaseToken != null) 'Authorization': 'Bearer $supabaseToken',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List<dynamic>;
      return data.map((t) => Translation.fromJson(t)).toList();
    } else {
      throw Exception('Failed to load translations: ${response.statusCode}');
    }
  }

  /// Get a list of Bible books.
  Future<List<Book>> getBooks() async {
    final response = await http.get(
      Uri.parse('$edgeFunctionUrl/books'),
      headers: {
        'Content-Type': 'application/json',
        if (supabaseToken != null) 'Authorization': 'Bearer $supabaseToken',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List<dynamic>;
      return data.map((b) => Book.fromJson(b)).toList();
    } else {
      throw Exception('Failed to load books: ${response.statusCode}');
    }
  }

  /// Get a specific chapter with verses and audio timing data.
  Future<Chapter> getChapter({
    required String bookId,
    required int chapterNumber,
    required String translationId,
  }) async {
    final response = await http.get(
      Uri.parse(
        '$edgeFunctionUrl/chapter?book_id=$bookId&chapter=$chapterNumber&translation_id=$translationId',
      ),
      headers: {
        'Content-Type': 'application/json',
        if (supabaseToken != null) 'Authorization': 'Bearer $supabaseToken',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return Chapter.fromJson(data);
    } else {
      throw Exception('Failed to load chapter: ${response.statusCode}');
    }
  }

  /// Get verse-level audio timing data for synchronization.
  Future<Map<int, AudioTiming>> getVerseTimings({
    required String filesetId,
    required String bookId,
    required int chapterNumber,
  }) async {
    final response = await http.get(
      Uri.parse(
        '$edgeFunctionUrl/timings?fileset_id=$filesetId&book_id=$bookId&chapter=$chapterNumber',
      ),
      headers: {
        'Content-Type': 'application/json',
        if (supabaseToken != null) 'Authorization': 'Bearer $supabaseToken',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return data.map((key, value) => MapEntry(int.parse(key), AudioTiming.fromJson(value)));
    } else {
      throw Exception('Failed to load timings: ${response.statusCode}');
    }
  }

  /// Check if a fileset is available for offline download.
  Future<bool> isDownloadable(String filesetId) async {
    final response = await http.get(
      Uri.parse('$edgeFunctionUrl/fileset/$filesetId'),
      headers: {
        'Content-Type': 'application/json',
        if (supabaseToken != null) 'Authorization': 'Bearer $supabaseToken',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return data['is_downloadable'] as bool? ?? false;
    } else {
      throw Exception('Failed to check downloadability: ${response.statusCode}');
    }
  }

  /// Search for passages containing specific text.
  Future<List<VerseSearchResult>> search({
    required String query,
    required String translationId,
    int limit = 20,
  }) async {
    final response = await http.post(
      Uri.parse('$edgeFunctionUrl/search'),
      headers: {
        'Content-Type': 'application/json',
        if (supabaseToken != null) 'Authorization': 'Bearer $supabaseToken',
      },
      body: json.encode({
        'query': query,
        'translation_id': translationId,
        'limit': limit,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List<dynamic>;
      return data.map((r) => VerseSearchResult.fromJson(r)).toList();
    } else {
      throw Exception('Search failed: ${response.statusCode}');
    }
  }
}

/// Represents audio timing information for a verse.
class AudioTiming {
  final Duration startTime;
  final Duration endTime;
  final double? confidence;

  const AudioTiming({
    required this.startTime,
    required this.endTime,
    this.confidence,
  });

  factory AudioTiming.fromJson(Map<String, dynamic> json) {
    return AudioTiming(
      startTime: Duration(milliseconds: json['start_time'] as int),
      endTime: Duration(milliseconds: json['end_time'] as int),
      confidence: json['confidence'] as double?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start_time': startTime.inMilliseconds,
      'end_time': endTime.inMilliseconds,
      'confidence': confidence,
    };
  }
}

/// Represents a search result for a verse.
class VerseSearchResult {
  final String bookId;
  final String bookName;
  final int chapterNumber;
  final int verseNumber;
  final String text;
  final List<int> matchIndices; // Character indices where query matches

  const VerseSearchResult({
    required this.bookId,
    required this.bookName,
    required this.chapterNumber,
    required this.verseNumber,
    required this.text,
    required this.matchIndices,
  });

  factory VerseSearchResult.fromJson(Map<String, dynamic> json) {
    return VerseSearchResult(
      bookId: json['book_id'] as String,
      bookName: json['book_name'] as String,
      chapterNumber: json['chapter_number'] as int,
      verseNumber: json['verse_number'] as int,
      text: json['text'] as String,
      matchIndices: (json['match_indices'] as List<dynamic>).cast<int>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'book_id': bookId,
      'book_name': bookName,
      'chapter_number': chapterNumber,
      'verse_number': verseNumber,
      'text': text,
      'match_indices': matchIndices,
    };
  }
}
