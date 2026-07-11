import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/bible_entities.dart';
import '../../domain/repositories/bible_repository.dart';
import 'bible_reader_event.dart';
import 'bible_reader_state.dart';

class BibleReaderBloc extends Bloc<BibleReaderEvent, BibleReaderState> {
  final BibleRepository bibleRepository;
  String _currentVersionId = 'engwbt'; // Default to World English Bible
  double _currentFontSize = 18.0;
  String _currentThemeMode = 'light';

  BibleReaderBloc({required this.bibleRepository}) : super(BibleReaderInitial()) {
    on<BibleVersionsRequested>(_onBibleVersionsRequested);
    on<BooksRequested>(_onBooksRequested);
    on<ChapterRequested>(_onChapterRequested);
    on<VersionChanged>(_onVersionChanged);
    on<FontSizeChanged>(_onFontSizeChanged);
    on<ThemeModeChanged>(_onThemeModeChanged);
  }

  Future<void> _onBibleVersionsRequested(
    BibleVersionsRequested event,
    Emitter<BibleReaderState> emit,
  ) async {
    emit(BibleReaderLoading());
    try {
      final versions = await bibleRepository.getAvailableVersions();
      emit(BibleVersionsLoaded(versions: versions));
    } catch (e) {
      emit(BibleReaderError(message: e.toString()));
    }
  }

  Future<void> _onBooksRequested(
    BooksRequested event,
    Emitter<BibleReaderState> emit,
  ) async {
    emit(BibleReaderLoading());
    try {
      final books = await bibleRepository.getBooks(event.versionId);
      emit(BooksLoaded(books: books));
    } catch (e) {
      emit(BibleReaderError(message: e.toString()));
    }
  }

  Future<void> _onChapterRequested(
    ChapterRequested event,
    Emitter<BibleReaderState> emit,
  ) async {
    emit(BibleReaderLoading());
    try {
      final chapter = await bibleRepository.getChapter(
        versionId: event.versionId,
        bookId: event.bookId,
        chapterNumber: event.chapterNumber,
      );
      
      _currentVersionId = event.versionId;
      
      emit(ChapterLoaded(
        chapter: chapter,
        fontSize: _currentFontSize,
        themeMode: _currentThemeMode,
      ));
    } catch (e) {
      emit(BibleReaderError(message: e.toString()));
    }
  }

  Future<void> _onVersionChanged(
    VersionChanged event,
    Emitter<BibleReaderState> emit,
  ) async {
    _currentVersionId = event.versionId;
    // Reload current chapter with new version if needed
  }

  Future<void> _onFontSizeChanged(
    FontSizeChanged event,
    Emitter<BibleReaderState> emit,
  ) async {
    _currentFontSize = event.fontSize;
    
    if (state is ChapterLoaded) {
      final currentState = state as ChapterLoaded;
      emit(ChapterLoaded(
        chapter: currentState.chapter,
        fontSize: _currentFontSize,
        themeMode: _currentThemeMode,
      ));
    }
  }

  Future<void> _onThemeModeChanged(
    ThemeModeChanged event,
    Emitter<BibleReaderState> emit,
  ) async {
    _currentThemeMode = event.themeMode;
    
    if (state is ChapterLoaded) {
      final currentState = state as ChapterLoaded;
      emit(ChapterLoaded(
        chapter: currentState.chapter,
        fontSize: _currentFontSize,
        themeMode: _currentThemeMode,
      ));
    }
  }

  String get currentVersionId => _currentVersionId;
  double get currentFontSize => _currentFontSize;
  String get currentThemeMode => _currentThemeMode;
}
