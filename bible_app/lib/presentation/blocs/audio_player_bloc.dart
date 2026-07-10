import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:just_audio/just_audio.dart';
import '../../domain/entities/bible_entities.dart';
import '../../services/audio/audio_service.dart';

// Events
abstract class AudioPlayerEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadAudioChapter extends AudioPlayerEvent {
  final String bookId;
  final int chapterNumber;
  final String audioUrl;
  final List<Verse> verses;

  LoadAudioChapter({
    required this.bookId,
    required this.chapterNumber,
    required this.audioUrl,
    required this.verses,
  });

  @override
  List<Object?> get props => [bookId, chapterNumber, audioUrl, verses];
}

class PlayAudio extends AudioPlayerEvent {}

class PauseAudio extends AudioPlayerEvent {}

class StopAudio extends AudioPlayerEvent {}

class SeekToPosition extends AudioPlayerEvent {
  final Duration position;

  SeekToPosition({required this.position});

  @override
  List<Object?> get props => [position];
}

class SeekToVerse extends AudioPlayerEvent {
  final int verseNumber;

  SeekToVerse({required this.verseNumber});

  @override
  List<Object?> get props => [verseNumber];
}

class ChangePlaybackSpeed extends AudioPlayerEvent {
  final double speed;

  ChangePlaybackSpeed({required this.speed});

  @override
  List<Object?> get props => [speed];
}

class SetSleepTimer extends AudioPlayerEvent {
  final Duration duration;

  SetSleepTimer({required this.duration});

  @override
  List<Object?> get props => [duration];
}

class CancelSleepTimer extends AudioPlayerEvent {}

// States
enum AudioStatus { idle, loading, playing, paused, stopped, error }

class AudioPlayerState extends Equatable {
  final AudioStatus status;
  final Chapter? currentChapter;
  final Duration currentPosition;
  final Duration totalDuration;
  final int? highlightedVerseNumber; // Currently playing verse
  final double playbackSpeed;
  final Duration? sleepTimerRemaining;
  final String? errorMessage;

  const AudioPlayerState({
    this.status = AudioStatus.idle,
    this.currentChapter,
    this.currentPosition = Duration.zero,
    this.totalDuration = Duration.zero,
    this.highlightedVerseNumber,
    this.playbackSpeed = 1.0,
    this.sleepTimerRemaining,
    this.errorMessage,
  });

  AudioPlayerState copyWith({
    AudioStatus? status,
    Chapter? currentChapter,
    Duration? currentPosition,
    Duration? totalDuration,
    int? highlightedVerseNumber,
    double? playbackSpeed,
    Duration? sleepTimerRemaining,
    String? errorMessage,
  }) {
    return AudioPlayerState(
      status: status ?? this.status,
      currentChapter: currentChapter ?? this.currentChapter,
      currentPosition: currentPosition ?? this.currentPosition,
      totalDuration: totalDuration ?? this.totalDuration,
      highlightedVerseNumber: highlightedVerseNumber ?? this.highlightedVerseNumber,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      sleepTimerRemaining: sleepTimerRemaining ?? this.sleepTimerRemaining,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        currentChapter,
        currentPosition,
        totalDuration,
        highlightedVerseNumber,
        playbackSpeed,
        sleepTimerRemaining,
        errorMessage,
      ];
}

// BLoC
class AudioPlayerBloc extends Bloc<AudioPlayerEvent, AudioPlayerState> {
  final AudioService _audioService;
  PlayerState? _playerState;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  Timer? _sleepTimer;

  AudioPlayerBloc({required AudioService audioService})
      : _audioService = audioService,
        super(const AudioPlayerState()) {
    on<LoadAudioChapter>(_onLoadAudioChapter);
    on<PlayAudio>(_onPlayAudio);
    on<PauseAudio>(_onPauseAudio);
    on<StopAudio>(_onStopAudio);
    on<SeekToPosition>(_onSeekToPosition);
    on<SeekToVerse>(_onSeekToVerse);
    on<ChangePlaybackSpeed>(_onChangePlaybackSpeed);
    on<SetSleepTimer>(_onSetSleepTimer);
    on<CancelSleepTimer>(_onCancelSleepTimer);

    _initPlayerListeners();
  }

  void _initPlayerListeners() {
    _playerStateSubscription = _audioService.playerStateStream.listen((playerState) {
      _playerState = playerState;
      
      if (playerState.processingState == ProcessingState.completed) {
        add(StopAudio());
      }
    });

    _positionSubscription = _audioService.positionStream.listen((position) {
      if (!isClosed) {
        emit(state.copyWith(currentPosition: position));
        _updateHighlightedVerse(position);
      }
    });
  }

  void _updateHighlightedVerse(Duration position) {
    if (state.currentChapter == null) return;

    final verses = state.currentChapter!.verses;
    for (var i = verses.length - 1; i >= 0; i--) {
      final verse = verses[i];
      if (verse.audioStartTime != null && position >= verse.audioStartTime!) {
        if (state.highlightedVerseNumber != verse.verseNumber) {
          emit(state.copyWith(highlightedVerseNumber: verse.verseNumber));
        }
        break;
      }
    }
  }

  Future<void> _onLoadAudioChapter(LoadAudioChapter event, Emitter<AudioPlayerState> emit) async {
    emit(state.copyWith(status: AudioStatus.loading));

    try {
      await _audioService.setUrl(event.audioUrl);
      
      final chapter = Chapter(
        bookId: event.bookId,
        bookName: '', // TODO: Get from BibleBrainService
        chapterNumber: event.chapterNumber,
        verses: event.verses,
        translationId: '', // TODO: Get from context
      );

      emit(state.copyWith(
        status: AudioStatus.stopped,
        currentChapter: chapter,
        totalDuration: _audioService.duration ?? Duration.zero,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AudioStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onPlayAudio(PlayAudio event, Emitter<AudioPlayerState> emit) async {
    try {
      await _audioService.play();
      emit(state.copyWith(status: AudioStatus.playing));
    } catch (e) {
      emit(state.copyWith(
        status: AudioStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onPauseAudio(PauseAudio event, Emitter<AudioPlayerState> emit) async {
    try {
      await _audioService.pause();
      emit(state.copyWith(status: AudioStatus.paused));
    } catch (e) {
      emit(state.copyWith(
        status: AudioStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onStopAudio(StopAudio event, Emitter<AudioPlayerState> emit) async {
    try {
      await _audioService.stop();
      emit(state.copyWith(
        status: AudioStatus.stopped,
        currentPosition: Duration.zero,
        highlightedVerseNumber: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AudioStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onSeekToPosition(SeekToPosition event, Emitter<AudioPlayerState> emit) async {
    try {
      await _audioService.seek(event.position);
      emit(state.copyWith(currentPosition: event.position));
    } catch (e) {
      emit(state.copyWith(
        status: AudioStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onSeekToVerse(SeekToVerse event, Emitter<AudioPlayerState> emit) async {
    if (state.currentChapter == null) return;

    final verse = state.currentChapter!.verses.firstWhere(
      (v) => v.verseNumber == event.verseNumber,
      orElse: () => state.currentChapter!.verses.first,
    );

    if (verse.audioStartTime != null) {
      await _onSeekToPosition(SeekToPosition(position: verse.audioStartTime!), (Emitter<AudioPlayerState> emit) {});
    }
  }

  Future<void> _onChangePlaybackSpeed(ChangePlaybackSpeed event, Emitter<AudioPlayerState> emit) async {
    try {
      await _audioService.setSpeed(event.speed);
      emit(state.copyWith(playbackSpeed: event.speed));
    } catch (e) {
      emit(state.copyWith(
        status: AudioStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onSetSleepTimer(SetSleepTimer event, Emitter<AudioPlayerState> emit) {
    _sleepTimer?.cancel();
    
    _sleepTimer = Timer(event.duration, () {
      if (state.status == AudioStatus.playing) {
        add(PauseAudio());
      }
      emit(state.copyWith(sleepTimerRemaining: null));
    });

    // Update remaining time every second
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_sleepTimer == null || timer.tick >= event.duration.inSeconds) {
        timer.cancel();
        return;
      }
      
      final remaining = event.duration - Duration(seconds: timer.tick);
      emit(state.copyWith(sleepTimerRemaining: remaining));
    });
  }

  void _onCancelSleepTimer(CancelSleepTimer event, Emitter<AudioPlayerState> emit) {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    emit(state.copyWith(sleepTimerRemaining: null));
  }

  @override
  Future<void> close() {
    _playerStateSubscription?.cancel();
    _positionSubscription?.cancel();
    _sleepTimer?.cancel();
    return super.close();
  }
}
