import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio_background/just_audio_background.dart';

/// Audio service wrapper for just_audio with background playback support.
class AudioService {
  final AudioPlayer _player = AudioPlayer();

  AudioPlayer get player => _player;

  /// Initialize audio session for background playback.
  Future<void> init() async {
    // Set audio session for iOS/Android
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playback,
      avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.duckOthers,
      avAudioSessionMode: AVAudioSessionMode.spokenAudio,
      avAudioSessionRouteChangeReasons: [
        AVAudioSessionRouteChangeReason.newDeviceAvailable,
        AVAudioSessionRouteChangeReason.oldDeviceUnavailable,
      ],
      avAudioSessionSetActiveOptions: [
        AVAudioSessionSetActiveOptions.notifyOthersOnDeactivation,
      ],
      androidAudioAttributes: AndroidAudioAttributes(
        contentType: AndroidAudioContentType.speech,
        usage: AndroidAudioUsage.media,
        flags: [AndroidAudioFlags.none],
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDuckedWithDefault: true,
    ));

    // Initialize background audio handler
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.bibleapp.audio',
      androidNotificationChannelName: 'Bible Audio',
      androidNotificationOngoing: true,
    );
  }

  /// Set the audio URL to play.
  Future<void> setUrl(String url) async {
    await _player.setUrl(url);
  }

  /// Set audio from file path (for offline playback).
  Future<void> setFilePath(String filePath) async {
    await _player.setFilePath(filePath);
  }

  /// Start or resume playback.
  Future<void> play() async {
    await _player.play();
  }

  /// Pause playback.
  Future<void> pause() async {
    await _player.pause();
  }

  /// Stop playback and reset position.
  Future<void> stop() async {
    await _player.stop();
  }

  /// Seek to a specific position.
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  /// Set playback speed (0.5x to 2.0x).
  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed.clamp(0.5, 2.0));
  }

  /// Get current player state stream.
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  /// Get current position stream.
  Stream<Duration> get positionStream => _player.positionStream;

  /// Get current position.
  Duration get position => _player.position;

  /// Get total duration.
  Duration? get duration => _player.duration;

  /// Get current playback speed.
  double get speed => _player.speed;

  /// Check if currently playing.
  bool get isPlaying => _player.playing;

  /// Check if audio is loaded.
  bool get hasAudio => _player.duration != null;

  /// Dispose of audio resources.
  Future<void> dispose() async {
    await _player.dispose();
  }
}
