import '../entities/bible_entities.dart';

abstract class BibleRepository {
  Future<List<BibleVersionEntity>> getAvailableVersions();
  Future<List<BookEntity>> getBooks(String versionId);
  Future<ChapterEntity> getChapter({
    required String versionId,
    required String bookId,
    required int chapterNumber,
  });
  Future<String> getAudioUrl({
    required String filesetId,
    required String bookId,
    required int chapterNumber,
  });
  Future<List<Map<String, double>>> getAudioTiming({
    required String filesetId,
    required String bookId,
    required int chapterNumber,
  });
}
