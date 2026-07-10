import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/bible_entities.dart';
import '../blocs/reader_bloc.dart';

/// Main reading screen for displaying Bible chapters with verse-by-verse rendering.
class ReaderScreen extends StatefulWidget {
  final String bookId;
  final int chapterNumber;
  final String translationId;

  const ReaderScreen({
    super.key,
    required this.bookId,
    required this.chapterNumber,
    required this.translationId,
  });

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ReaderBloc>().add(LoadChapter(
      bookId: widget.bookId,
      chapterNumber: widget.chapterNumber,
      translationId: widget.translationId,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<ReaderBloc, ReaderState>(
          builder: (context, state) {
            if (state.chapter == null) {
              return Text('Loading...');
            }
            return Text('${state.chapter!.bookName} ${state.chapter!.chapterNumber}');
          },
        ),
        actions: [
          // Translation selector
          PopupMenuButton<String>(
            icon: const Icon(Icons.translate),
            onSelected: (translationId) {
              context.read<ReaderBloc>().add(ChangeTranslation(translationId: translationId));
            },
            itemBuilder: (context) {
              final translations = context.read<ReaderBloc>().state.availableTranslations;
              return translations.map((t) {
                return PopupMenuItem(
                  value: t.id,
                  child: Text(t.name),
                );
              }).toList();
            },
          ),
          // Font size controls
          PopupMenuButton<double>(
            icon: const Icon(Icons.text_fields),
            onSelected: (fontSize) {
              context.read<ReaderBloc>().add(ChangeFontSize(fontSize: fontSize));
            },
            itemBuilder: (context) {
              return [14.0, 16.0, 18.0, 20.0, 22.0, 24.0].map((size) {
                return PopupMenuItem(
                  value: size,
                  child: Text('${size.toInt()}px'),
                );
              }).toList();
            },
          ),
          // Theme selector
          PopupMenuButton<ReaderTheme>(
            icon: const Icon(Icons.palette),
            onSelected: (theme) {
              context.read<ReaderBloc>().add(ChangeTheme(theme: theme));
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem(value: ReaderTheme.light, child: Text('Light')),
                PopupMenuItem(value: ReaderTheme.dark, child: Text('Dark')),
                PopupMenuItem(value: ReaderTheme.sepia, child: Text('Sepia')),
              ];
            },
          ),
        ],
      ),
      body: BlocBuilder<ReaderBloc, ReaderState>(
        builder: (context, state) {
          switch (state.status) {
            case ReaderStatus.initial:
              return const Center(child: CircularProgressIndicator());
            case ReaderStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case ReaderStatus.loaded:
              if (state.chapter == null) {
                return const Center(child: Text('No content available'));
              }
              return _buildChapterView(state);
            case ReaderStatus.error:
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Error: ${state.errorMessage}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ReaderBloc>().add(LoadChapter(
                          bookId: widget.bookId,
                          chapterNumber: widget.chapterNumber,
                          translationId: widget.translationId,
                        ));
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
          }
        },
      ),
    );
  }

  Widget _buildChapterView(ReaderState state) {
    final chapter = state.chapter!;
    
    // Determine background color based on theme
    Color backgroundColor;
    Color textColor;
    
    switch (state.theme) {
      case ReaderTheme.light:
        backgroundColor = Colors.white;
        textColor = Colors.black87;
        break;
      case ReaderTheme.dark:
        backgroundColor = Colors.grey[900]!;
        textColor = Colors.white;
        break;
      case ReaderTheme.sepia:
        backgroundColor = const Color(0xFFF5E6D3);
        textColor = const Color(0xFF5B4636);
        break;
    }

    return Container(
      color: backgroundColor,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        itemCount: chapter.verses.length,
        itemBuilder: (context, index) {
          final verse = chapter.verses[index];
          final verseKey = '${verse.bookId}:${verse.chapterNumber}:${verse.verseNumber}';
          final isBookmarked = state.bookmarkedVerses.contains(verseKey);
          final highlightColor = state.highlightedVerses[verseKey];
          
          return _VerseWidget(
            verse: verse,
            fontSize: state.fontSize,
            textColor: textColor,
            isBookmarked: isBookmarked,
            highlightColor: highlightColor,
            onBookmarkToggle: () {
              context.read<ReaderBloc>().add(ToggleBookmark(
                bookId: verse.bookId,
                chapterNumber: verse.chapterNumber,
                verseNumber: verse.verseNumber,
              ));
            },
            onHighlight: (color) {
              context.read<ReaderBloc>().add(AddHighlight(
                bookId: verse.bookId,
                chapterNumber: verse.chapterNumber,
                startVerseNumber: verse.verseNumber,
                colorHex: color,
              ));
            },
          );
        },
      ),
    );
  }
}

/// Individual verse widget with bookmark and highlight support.
class _VerseWidget extends StatefulWidget {
  final Verse verse;
  final double fontSize;
  final Color textColor;
  final bool isBookmarked;
  final String? highlightColor;
  final VoidCallback onBookmarkToggle;
  final Function(String color) onHighlight;

  const _VerseWidget({
    required this.verse,
    required this.fontSize,
    required this.textColor,
    required this.isBookmarked,
    this.highlightColor,
    required this.onBookmarkToggle,
    required this.onHighlight,
  });

  @override
  State<_VerseWidget> createState() => _VerseWidgetState();
}

class _VerseWidgetState extends State<_VerseWidget> {
  bool _showActions = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showActions = !_showActions;
        });
      },
      onLongPress: () {
        _showHighlightMenu();
      },
      child: Container(
        color: widget.highlightColor != null 
            ? Color(int.parse(widget.highlightColor!.substring(1, 7), radix: 16) + 0xFF000000)
            : null,
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Verse number
            SizedBox(
              width: 40,
              child: Text(
                '${widget.verse.verseNumber}',
                style: TextStyle(
                  fontSize: widget.fontSize * 0.7,
                  fontWeight: FontWeight.bold,
                  color: widget.textColor.withOpacity(0.6),
                ),
              ),
            ),
            // Verse text
            Expanded(
              child: Text(
                widget.verse.text,
                style: TextStyle(
                  fontSize: widget.fontSize,
                  height: 1.6,
                  color: widget.textColor,
                ),
              ),
            ),
            // Actions
            if (_showActions) ...[
              IconButton(
                icon: Icon(
                  widget.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: widget.isBookmarked ? Colors.amber : widget.textColor,
                ),
                onPressed: widget.onBookmarkToggle,
              ),
              IconButton(
                icon: Icon(Icons.format_color_fill, color: widget.textColor),
                onPressed: _showHighlightMenu,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showHighlightMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: CircleAvatar(backgroundColor: Colors.yellow),
                title: const Text('Yellow'),
                onTap: () {
                  widget.onHighlight('#FFFF00');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: CircleAvatar(backgroundColor: Colors.green),
                title: const Text('Green'),
                onTap: () {
                  widget.onHighlight('#00FF00');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: CircleAvatar(backgroundColor: Colors.blue),
                title: const Text('Blue'),
                onTap: () {
                  widget.onHighlight('#0000FF');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: CircleAvatar(backgroundColor: Colors.pink),
                title: const Text('Pink'),
                onTap: () {
                  widget.onHighlight('#FF00FF');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
