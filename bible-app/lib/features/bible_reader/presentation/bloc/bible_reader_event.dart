import 'package:equatable/equatable.dart';

abstract class BibleReaderEvent extends Equatable {
  const BibleReaderEvent();

  @override
  List<Object?> get props => [];
}

class BibleVersionsRequested extends BibleReaderEvent {}

class BooksRequested extends BibleReaderEvent {
  final String versionId;

  const BooksRequested({required this.versionId});

  @override
  List<Object?> get props => [versionId];
}

class ChapterRequested extends BibleReaderEvent {
  final String versionId;
  final String bookId;
  final int chapterNumber;

  const ChapterRequested({
    required this.versionId,
    required this.bookId,
    required this.chapterNumber,
  });

  @override
  List<Object?> get props => [versionId, bookId, chapterNumber];
}

class VersionChanged extends BibleReaderEvent {
  final String versionId;

  const VersionChanged({required this.versionId});

  @override
  List<Object?> get props => [versionId];
}

class FontSizeChanged extends BibleReaderEvent {
  final double fontSize;

  const FontSizeChanged({required this.fontSize});

  @override
  List<Object?> get props => [fontSize];
}

class ThemeModeChanged extends BibleReaderEvent {
  final String themeMode; // 'light', 'dark', 'sepia'

  const ThemeModeChanged({required this.themeMode});

  @override
  List<Object?> get props => [themeMode];
}
