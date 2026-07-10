import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/bible_entities.dart';
import '../../services/bible_brain/bible_brain_service.dart';

// Events
abstract class ReaderEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadChapter extends ReaderEvent {
  final String bookId;
  final int chapterNumber;
  final String translationId;

  LoadChapter({
    required this.bookId,
    required this.chapterNumber,
    required this.translationId,
  });

  @override
  List<Object?> get props => [bookId, chapterNumber, translationId];
}

class ChangeTranslation extends ReaderEvent {
  final String translationId;

  ChangeTranslation({required this.translationId});

  @override
  List<Object?> get props => [translationId];
}

class ToggleBookmark extends ReaderEvent {
  final String bookId;
  final int chapterNumber;
  final int verseNumber;

  ToggleBookmark({
    required this.bookId,
    required this.chapterNumber,
    required this.verseNumber,
  });

  @override
  List<Object?> get props => [bookId, chapterNumber, verseNumber];
}

class AddHighlight extends ReaderEvent {
  final String bookId;
  final int chapterNumber;
  final int startVerseNumber;
  final int? endVerseNumber;
  final String colorHex;

  AddHighlight({
    required this.bookId,
    required this.chapterNumber,
    required this.startVerseNumber,
    this.endVerseNumber,
    required this.colorHex,
  });

  @override
  List<Object?> get props => [bookId, chapterNumber, startVerseNumber, endVerseNumber, colorHex];
}

class ChangeFontSize extends ReaderEvent {
  final double fontSize;

  ChangeFontSize({required this.fontSize});

  @override
  List<Object?> get props => [fontSize];
}

class ChangeTheme extends ReaderEvent {
  final ReaderTheme theme;

  ChangeTheme({required this.theme});

  @override
  List<Object?> get props => [theme];
}

// States
enum ReaderTheme { light, dark, sepia }

enum ReaderStatus { initial, loading, loaded, error }

class ReaderState extends Equatable {
  final ReaderStatus status;
  final Chapter? chapter;
  final Translation currentTranslation;
  final List<Translation> availableTranslations;
  final Set<String> bookmarkedVerses; // Format: "bookId:chapter:verse"
  final Map<String, String> highlightedVerses; // Format: "bookId:chapter:verse" -> colorHex
  final double fontSize;
  final ReaderTheme theme;
  final String? errorMessage;

  const ReaderState({
    this.status = ReaderStatus.initial,
    this.chapter,
    required this.currentTranslation,
    required this.availableTranslations,
    this.bookmarkedVerses = const {},
    this.highlightedVerses = const {},
    this.fontSize = 16.0,
    this.theme = ReaderTheme.light,
    this.errorMessage,
  });

  ReaderState copyWith({
    ReaderStatus? status,
    Chapter? chapter,
    Translation? currentTranslation,
    List<Translation>? availableTranslations,
    Set<String>? bookmarkedVerses,
    Map<String, String>? highlightedVerses,
    double? fontSize,
    ReaderTheme? theme,
    String? errorMessage,
  }) {
    return ReaderState(
      status: status ?? this.status,
      chapter: chapter ?? this.chapter,
      currentTranslation: currentTranslation ?? this.currentTranslation,
      availableTranslations: availableTranslations ?? this.availableTranslations,
      bookmarkedVerses: bookmarkedVerses ?? this.bookmarkedVerses,
      highlightedVerses: highlightedVerses ?? this.highlightedVerses,
      fontSize: fontSize ?? this.fontSize,
      theme: theme ?? this.theme,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        chapter,
        currentTranslation,
        availableTranslations,
        bookmarkedVerses,
        highlightedVerses,
        fontSize,
        theme,
        errorMessage,
      ];
}

// BLoC
class ReaderBloc extends Bloc<ReaderEvent, ReaderState> {
  final BibleBrainService _bibleBrainService;

  ReaderBloc({required BibleBrainService bibleBrainService})
      : _bibleBrainService = bibleBrainService,
        super(ReaderState(
          currentTranslation: const Translation(
            id: 'eng ESV',
            name: 'ESV',
            language: 'eng',
            hasAudio: true,
            isDownloadable: true,
          ),
          availableTranslations: [],
        )) {
    on<LoadChapter>(_onLoadChapter);
    on<ChangeTranslation>(_onChangeTranslation);
    on<ToggleBookmark>(_onToggleBookmark);
    on<AddHighlight>(_onAddHighlight);
    on<ChangeFontSize>(_onChangeFontSize);
    on<ChangeTheme>(_onChangeTheme);
  }

  Future<void> _onLoadChapter(LoadChapter event, Emitter<ReaderState> emit) async {
    emit(state.copyWith(status: ReaderStatus.loading));

    try {
      final chapter = await _bibleBrainService.getChapter(
        bookId: event.bookId,
        chapterNumber: event.chapterNumber,
        translationId: event.translationId,
      );

      // TODO: Load bookmarks and highlights from Supabase for this chapter
      
      emit(state.copyWith(
        status: ReaderStatus.loaded,
        chapter: chapter,
        currentTranslation: state.availableTranslations.firstWhere(
          (t) => t.id == event.translationId,
          orElse: () => state.currentTranslation,
        ),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ReaderStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onChangeTranslation(ChangeTranslation event, Emitter<ReaderState> emit) async {
    if (state.chapter == null) return;

    emit(state.copyWith(status: ReaderStatus.loading));

    try {
      final chapter = await _bibleBrainService.getChapter(
        bookId: state.chapter!.bookId,
        chapterNumber: state.chapter!.chapterNumber,
        translationId: event.translationId,
      );

      emit(state.copyWith(
        status: ReaderStatus.loaded,
        chapter: chapter,
        currentTranslation: state.availableTranslations.firstWhere(
          (t) => t.id == event.translationId,
          orElse: () => state.currentTranslation,
        ),
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ReaderStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onToggleBookmark(ToggleBookmark event, Emitter<ReaderState> emit) {
    final verseKey = '${event.bookId}:${event.chapterNumber}:${event.verseNumber}';
    final newBookmarks = Set<String>.from(state.bookmarkedVerses);

    if (newBookmarks.contains(verseKey)) {
      newBookmarks.remove(verseKey);
      // TODO: Remove from Supabase
    } else {
      newBookmarks.add(verseKey);
      // TODO: Add to Supabase
    }

    emit(state.copyWith(bookmarkedVerses: newBookmarks));
  }

  void _onAddHighlight(AddHighlight event, Emitter<ReaderState> emit) {
    final newHighlights = Map<String, String>.from(state.highlightedVerses);
    
    // Add highlight for each verse in range
    final start = event.startVerseNumber;
    final end = event.endVerseNumber ?? start;
    
    for (int i = start; i <= end; i++) {
      final verseKey = '${event.bookId}:${event.chapterNumber}:$i';
      newHighlights[verseKey] = event.colorHex;
    }

    // TODO: Save to Supabase
    
    emit(state.copyWith(highlightedVerses: newHighlights));
  }

  void _onChangeFontSize(ChangeFontSize event, Emitter<ReaderState> emit) {
    emit(state.copyWith(fontSize: event.fontSize));
  }

  void _onChangeTheme(ChangeTheme event, Emitter<ReaderState> emit) {
    emit(state.copyWith(theme: event.theme));
  }
}
