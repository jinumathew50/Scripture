import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/bible_entities.dart';
import '../bible_repository.dart';

class SupabaseBibleRepository implements BibleRepository {
  final SupabaseClient supabase;
  final Dio dio;
  final String edgeFunctionUrl;

  SupabaseBibleRepository({
    required this.supabase,
    required this.dio,
    required this.edgeFunctionUrl,
  });

  @override
  Future<List<BibleVersionEntity>> getAvailableVersions() async {
    try {
      // Call Edge Function to fetch versions from Bible Brain API
      final response = await dio.post(
        '$edgeFunctionUrl/get-bible-versions',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${supabase.auth.currentSession?.accessToken}',
          },
        ),
      );

      if (response.statusCode == 200) {
        return (response.data as List)
            .map((item) => BibleVersionEntity.fromMap(item))
            .toList();
      } else {
        throw Exception('Failed to fetch Bible versions');
      }
    } catch (e) {
      throw Exception('Error fetching versions: $e');
    }
  }

  @override
  Future<List<BookEntity>> getBooks(String versionId) async {
    try {
      final response = await dio.post(
        '$edgeFunctionUrl/get-books',
        data: {'versionId': versionId},
        options: Options(
          headers: {
            'Authorization': 'Bearer ${supabase.auth.currentSession?.accessToken}',
          },
        ),
      );

      if (response.statusCode == 200) {
        return (response.data as List)
            .map((item) => BookEntity.fromMap(item))
            .toList();
      } else {
        throw Exception('Failed to fetch books');
      }
    } catch (e) {
      throw Exception('Error fetching books: $e');
    }
  }

  @override
  Future<ChapterEntity> getChapter({
    required String versionId,
    required String bookId,
    required int chapterNumber,
  }) async {
    try {
      final response = await dio.post(
        '$edgeFunctionUrl/get-chapter',
        data: {
          'versionId': versionId,
          'bookId': bookId,
          'chapterNumber': chapterNumber,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer ${supabase.auth.currentSession?.accessToken}',
          },
        ),
      );

      if (response.statusCode == 200) {
        return ChapterEntity.fromMap(response.data);
      } else {
        throw Exception('Failed to fetch chapter');
      }
    } catch (e) {
      throw Exception('Error fetching chapter: $e');
    }
  }

  @override
  Future<String> getAudioUrl({
    required String filesetId,
    required String bookId,
    required int chapterNumber,
  }) async {
    try {
      final response = await dio.post(
        '$edgeFunctionUrl/get-audio-url',
        data: {
          'filesetId': filesetId,
          'bookId': bookId,
          'chapterNumber': chapterNumber,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer ${supabase.auth.currentSession?.accessToken}',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['url'] != null) {
        return response.data['url'];
      } else {
        throw Exception('Failed to get audio URL');
      }
    } catch (e) {
      throw Exception('Error getting audio URL: $e');
    }
  }

  @override
  Future<List<Map<String, double>>> getAudioTiming({
    required String filesetId,
    required String bookId,
    required int chapterNumber,
  }) async {
    try {
      final response = await dio.post(
        '$edgeFunctionUrl/get-audio-timing',
        data: {
          'filesetId': filesetId,
          'bookId': bookId,
          'chapterNumber': chapterNumber,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer ${supabase.auth.currentSession?.accessToken}',
          },
        ),
      );

      if (response.statusCode == 200) {
        return List<Map<String, double>>.from(response.data);
      } else {
        throw Exception('Failed to get audio timing');
      }
    } catch (e) {
      throw Exception('Error getting audio timing: $e');
    }
  }
}
