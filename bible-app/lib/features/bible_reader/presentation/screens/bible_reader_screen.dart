import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../presentation/bloc/bible_reader_bloc.dart';
import '../../presentation/bloc/bible_reader_event.dart';
import '../../presentation/bloc/bible_reader_state.dart';

class BibleReaderScreen extends StatefulWidget {
  const BibleReaderScreen({Key? key}) : super(key: key);

  @override
  State<BibleReaderScreen> createState() => _BibleReaderScreenState();
}

class _BibleReaderScreenState extends State<BibleReaderScreen> {
  String? _selectedBookId;
  int? _selectedChapterNumber;

  @override
  void initState() {
    super.initState();
    // Load available Bible versions on startup
    context.read<BibleReaderBloc>().add(BibleVersionsRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bible Reader'),
        actions: [
          // Version selector
          PopupMenuButton<String>(
            icon: const Icon(Icons.translate),
            tooltip: 'Select Version',
            onSelected: (versionId) {
              context.read<BibleReaderBloc>().add(VersionChanged(versionId: versionId));
            },
            itemBuilder: (context) => _buildVersionSelector(),
          ),
          // Font size controls
          PopupMenuButton<double>(
            icon: const Icon(Icons.text_fields),
            tooltip: 'Font Size',
            onSelected: (fontSize) {
              context.read<BibleReaderBloc>().add(FontSizeChanged(fontSize: fontSize));
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 14.0, child: Text('Small')),
              const PopupMenuItem(value: 18.0, child: Text('Medium')),
              const PopupMenuItem(value: 22.0, child: Text('Large')),
              const PopupMenuItem(value: 26.0, child: Text('Extra Large')),
            ],
          ),
          // Theme selector
          PopupMenuButton<String>(
            icon: const Icon(Icons.palette),
            tooltip: 'Theme',
            onSelected: (theme) {
              context.read<BibleReaderBloc>().add(ThemeModeChanged(themeMode: theme));
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'light', child: Text('Light')),
              const PopupMenuItem(value: 'dark', child: Text('Dark')),
              const PopupMenuItem(value: 'sepia', child: Text('Sepia')),
            ],
          ),
        ],
      ),
      body: BlocBuilder<BibleReaderBloc, BibleReaderState>(
        builder: (context, state) {
          if (state is BibleReaderLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is BibleReaderError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<BibleReaderBloc>().add(BibleVersionsRequested());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (state is BibleVersionsLoaded) {
            return _buildBookSelection(state);
          } else if (state is BooksLoaded) {
            return _buildChapterSelection(state);
          } else if (state is ChapterLoaded) {
            return _buildChapterView(state);
          } else {
            return const Center(child: Text('Select a book to begin reading'));
          }
        },
      ),
    );
  }

  List<PopupMenuEntry<String>> _buildVersionSelector() {
    return context.select<BibleReaderBloc, BibleVersionsLoaded?>((bloc) {
      final state = bloc.state as BibleVersionsLoaded?;
      if (state == null) return [];
      
      return state.versions.map((version) {
        return PopupMenuItem<String>(
          value: version.id,
          child: Text('${version.abbreviation} - ${version.name}'),
        );
      }).toList();
    }) ?? [];
  }

  Widget _buildBookSelection(BibleVersionsLoaded state) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Select a Book',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: BlocBuilder<BibleReaderBloc, BibleReaderState>(
            builder: (context, state) {
              if (state is! BooksLoaded && state is! BibleVersionsLoaded) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (state is BibleVersionsLoaded) {
                // Trigger loading books for default version
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  context.read<BibleReaderBloc>().add(
                    BooksRequested(versionId: context.read<BibleReaderBloc>().currentVersionId),
                  );
                });
                return const Center(child: CircularProgressIndicator());
              }
              
              final books = (state as BooksLoaded).books;
              return ListView.builder(
                itemCount: books.length,
                itemBuilder: (context, index) {
                  final book = books[index];
                  return ListTile(
                    title: Text('${book.bookNumber}. ${book.name}'),
                    subtitle: Text('${book.chapterCount} chapters'),
                    trailing: book.hasAudio 
                        ? const Icon(Icons.headphones, size: 16)
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedBookId = book.id;
                      });
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => _ChapterListScreen(book: book),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChapterSelection(BooksLoaded state) {
    return const Center(child: Text('Select a chapter from the book list'));
  }

  Widget _buildChapterView(ChapterLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${state.chapter.bookId} ${state.chapter.chapterNumber}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ...state.chapter.verses.map((verse) {
            return _VerseWidget(
              verse: verse,
              fontSize: state.fontSize,
              onTap: () => _showVerseOptions(verse),
            );
          }),
        ],
      ),
    );
  }

  void _showVerseOptions(dynamic verse) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.bookmark_border),
              title: const Text('Bookmark'),
              onTap: () {
                // Add bookmark logic
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.highlight),
              title: const Text('Highlight'),
              onTap: () {
                // Add highlight logic
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.note_add),
              title: const Text('Add Note'),
              onTap: () {
                // Add note logic
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.play_arrow),
              title: const Text('Play Audio'),
              onTap: () {
                // Navigate to audio player
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _VerseWidget extends StatelessWidget {
  final dynamic verse;
  final double fontSize;
  final VoidCallback onTap;

  const _VerseWidget({
    required this.verse,
    required this.fontSize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: fontSize,
          height: 1.6,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
        children: [
          TextSpan(
            text: '${verse.verseNumber} ',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          TextSpan(
            text: verse.text,
            recognizer: TapGestureRecognizer()..onTap = onTap,
          ),
        ],
      ),
    );
  }
}

class _ChapterListScreen extends StatelessWidget {
  final dynamic book;

  const _ChapterListScreen({required this.book});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(book.name),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 1,
        ),
        itemCount: book.chapterCount,
        itemBuilder: (context, index) {
          final chapterNum = index + 1;
          return Card(
            child: InkWell(
              onTap: () {
                context.read<BibleReaderBloc>().add(
                  ChapterRequested(
                    versionId: context.read<BibleReaderBloc>().currentVersionId,
                    bookId: book.id,
                    chapterNumber: chapterNum,
                  ),
                );
                Navigator.pop(context);
              },
              child: Center(
                child: Text(
                  '$chapterNum',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
