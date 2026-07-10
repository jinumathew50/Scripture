import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../blocs/audio_player_bloc.dart';

/// Audio player widget with verse synchronization and playback controls.
class AudioPlayerWidget extends StatelessWidget {
  const AudioPlayerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, state) {
        if (state.status == AudioStatus.idle || state.currentChapter == null) {
          return const SizedBox.shrink();
        }

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Progress bar
              _buildProgressBar(context, state),
              
              // Player controls
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    // Current verse info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${state.currentChapter!.bookName} ${state.currentChapter!.chapterNumber}',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (state.highlightedVerseNumber != null)
                            Text(
                              'Verse ${state.highlightedVerseNumber}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                        ],
                      ),
                    ),
                    
                    // Playback controls
                    _buildPlaybackControls(context, state),
                    
                    // Additional controls
                    _buildAdditionalControls(context, state),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressBar(BuildContext context, AudioPlayerState state) {
    return SliderTheme(
      data: SliderThemeData(
        trackHeight: 4,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
      ),
      child: Slider(
        value: state.currentPosition.inSeconds.toDouble(),
        max: state.totalDuration.inSeconds.toDouble().clamp(1, double.infinity),
        onChanged: (value) {
          context.read<AudioPlayerBloc>().add(
            SeekToPosition(position: Duration(seconds: value.toInt())),
          );
        },
      ),
    );
  }

  Widget _buildPlaybackControls(BuildContext context, AudioPlayerState state) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Rewind 10 seconds
        IconButton(
          icon: const Icon(Icons.replay_10),
          onPressed: () {
            final newPosition = state.currentPosition - const Duration(seconds: 10);
            context.read<AudioPlayerBloc>().add(
              SeekToPosition(position: newPosition < Duration.zero ? Duration.zero : newPosition),
            );
          },
        ),
        
        // Play/Pause button
        FloatingActionButton(
          mini: true,
          onPressed: () {
            if (state.status == AudioStatus.playing) {
              context.read<AudioPlayerBloc>().add(PauseAudio());
            } else {
              context.read<AudioPlayerBloc>().add(PlayAudio());
            }
          },
          child: Icon(
            state.status == AudioStatus.playing ? Icons.pause : Icons.play_arrow,
          ),
        ),
        
        // Forward 10 seconds
        IconButton(
          icon: const Icon(Icons.forward_10),
          onPressed: () {
            final newPosition = state.currentPosition + const Duration(seconds: 10);
            context.read<AudioPlayerBloc>().add(
              SeekToPosition(
                position: newPosition > state.totalDuration 
                    ? state.totalDuration 
                    : newPosition,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAdditionalControls(BuildContext context, AudioPlayerState state) {
    return PopupMenuButton<double>(
      icon: Icon(
        Icons.speed,
        color: state.playbackSpeed != 1.0 
            ? Theme.of(context).colorScheme.primary 
            : null,
      ),
      tooltip: 'Playback Speed',
      onSelected: (speed) {
        context.read<AudioPlayerBloc>().add(ChangePlaybackSpeed(speed: speed));
      },
      itemBuilder: (context) {
        return [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0].map((speed) {
          return PopupMenuItem(
            value: speed,
            child: Row(
              children: [
                if (speed == state.playbackSpeed)
                  Icon(Icons.check, color: Theme.of(context).colorScheme.primary),
                if (speed != state.playbackSpeed)
                  const SizedBox(width: 24),
                Text('${speed}x'),
              ],
            ),
          );
        }).toList();
      },
    );
  }
}

/// Full-screen audio player dialog with sleep timer and verse navigation.
class FullScreenAudioPlayer extends StatefulWidget {
  final String bookId;
  final int chapterNumber;

  const FullScreenAudioPlayer({
    super.key,
    required this.bookId,
    required this.chapterNumber,
  });

  @override
  State<FullScreenAudioPlayer> createState() => _FullScreenAudioPlayerState();
}

class _FullScreenAudioPlayerState extends State<FullScreenAudioPlayer> {
  bool _showSleepTimerOptions = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              state.currentChapter != null
                  ? '${state.currentChapter!.bookName} ${state.currentChapter!.chapterNumber}'
                  : 'Audio Player',
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.timer,
                  color: state.sleepTimerRemaining != null 
                      ? Theme.of(context).colorScheme.primary 
                      : null,
                ),
                onPressed: () {
                  setState(() {
                    _showSleepTimerOptions = !_showSleepTimerOptions;
                  });
                },
                tooltip: 'Sleep Timer',
              ),
            ],
          ),
          body: Column(
            children: [
              if (_showSleepTimerOptions) _buildSleepTimerOptions(context, state),
              Expanded(child: _buildMainContent(context, state)),
              _buildBottomControls(context, state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSleepTimerOptions(BuildContext context, AudioPlayerState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          ElevatedButton(
            onPressed: () {
              context.read<AudioPlayerBloc>().add(
                SetSleepTimer(duration: const Duration(minutes: 15)),
              );
              setState(() => _showSleepTimerOptions = false);
            },
            child: const Text('15 min'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AudioPlayerBloc>().add(
                SetSleepTimer(duration: const Duration(minutes: 30)),
              );
              setState(() => _showSleepTimerOptions = false);
            },
            child: const Text('30 min'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AudioPlayerBloc>().add(
                SetSleepTimer(duration: const Duration(hours: 1)),
              );
              setState(() => _showSleepTimerOptions = false);
            },
            child: const Text('1 hour'),
          ),
          if (state.sleepTimerRemaining != null)
            OutlinedButton(
              onPressed: () {
                context.read<AudioPlayerBloc>().add(CancelSleepTimer());
                setState(() => _showSleepTimerOptions = false);
              },
              child: const Text('Cancel Timer'),
            ),
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, AudioPlayerState state) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.currentChapter?.verses.length ?? 0,
      itemBuilder: (context, index) {
        final verse = state.currentChapter!.verses[index];
        final isHighlighted = state.highlightedVerseNumber == verse.verseNumber;
        
        return Card(
          color: isHighlighted 
              ? Theme.of(context).colorScheme.primaryContainer 
              : null,
          child: ListTile(
            leading: Text(
              '${verse.verseNumber}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isHighlighted 
                    ? Theme.of(context).colorScheme.onPrimaryContainer 
                    : null,
              ),
            ),
            title: Text(verse.text),
            onTap: () {
              context.read<AudioPlayerBloc>().add(
                SeekToVerse(verseNumber: verse.verseNumber),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildBottomControls(BuildContext context, AudioPlayerState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Time display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(state.currentPosition),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (state.sleepTimerRemaining != null)
                Text(
                  'Timer: ${_formatDuration(state.sleepTimerRemaining!)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              Text(
                _formatDuration(state.totalDuration),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Playback controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.replay_10),
                iconSize: 32,
                onPressed: () {
                  final newPosition = state.currentPosition - const Duration(seconds: 10);
                  context.read<AudioPlayerBloc>().add(
                    SeekToPosition(
                      position: newPosition < Duration.zero ? Duration.zero : newPosition,
                    ),
                  );
                },
              ),
              const SizedBox(width: 16),
              FloatingActionButton.large(
                onPressed: () {
                  if (state.status == AudioStatus.playing) {
                    context.read<AudioPlayerBloc>().add(PauseAudio());
                  } else {
                    context.read<AudioPlayerBloc>().add(PlayAudio());
                  }
                },
                child: Icon(
                  state.status == AudioStatus.playing ? Icons.pause : Icons.play_arrow,
                  size: 36,
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.forward_10),
                iconSize: 32,
                onPressed: () {
                  final newPosition = state.currentPosition + const Duration(seconds: 10);
                  context.read<AudioPlayerBloc>().add(
                    SeekToPosition(
                      position: newPosition > state.totalDuration 
                          ? state.totalDuration 
                          : newPosition,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }
}
