import 'package:equatable/equatable.dart';
import '../../domain/entities/bible_entities.dart';

abstract class BibleReaderState extends Equatable {
  const BibleReaderState();

  @override
  List<Object?> get props => [];
}

class BibleReaderInitial extends BibleReaderState {}

class BibleReaderLoading extends BibleReaderState {}

class BibleVersionsLoaded extends BibleReaderState {
  final List<BibleVersionEntity> versions;

  const BibleVersionsLoaded({required this.versions});

  @override
  List<Object?> get props => [versions];
}

class BooksLoaded extends BibleReaderState {
  final List<BookEntity> books;

  const BooksLoaded({required this.books});

  @override
  List<Object?> get props => [books];
}

class ChapterLoaded extends BibleReaderState {
  final ChapterEntity chapter;
  final double fontSize;
  final String themeMode;

  const ChapterLoaded({
    required this.chapter,
    this.fontSize = 18.0,
    this.themeMode = 'light',
  });

  @override
  List<Object?> get props => [chapter, fontSize, themeMode];
}

class BibleReaderError extends BibleReaderState {
  final String message;

  const BibleReaderError({required this.message});

  @override
  List<Object?> get props => [message];
}
