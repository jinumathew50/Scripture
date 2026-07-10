import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase/supabase_client.dart';
import '../services/bible_brain/bible_brain_service.dart';
import '../services/audio/audio_service.dart';
import 'presentation/blocs/reader_bloc.dart';
import 'presentation/blocs/audio_player_bloc.dart';
import 'presentation/screens/reader/reader_screen.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await SupabaseClient.instance.initialize(
    supabaseUrl: const String.fromEnvironment('SUPABASE_URL'),
    supabaseAnonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
  );

  // Initialize audio service for background playback
  final audioService = AudioService();
  await audioService.init();

  // Create services
  final bibleBrainService = BibleBrainService(
    edgeFunctionUrl: '${const String.fromEnvironment('SUPABASE_URL')}/functions/v1/bible-brain',
    supabaseToken: SupabaseClient.instance.currentUser?.accessToken,
  );

  runApp(
    BibleApp(
      bibleBrainService: bibleBrainService,
      audioService: audioService,
    ),
  );
}

class BibleApp extends StatelessWidget {
  final BibleBrainService bibleBrainService;
  final AudioService audioService;

  const BibleApp({
    super.key,
    required this.bibleBrainService,
    required this.audioService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ReaderBloc(bibleBrainService: bibleBrainService),
        ),
        BlocProvider(
          create: (_) => AudioPlayerBloc(audioService: audioService),
        ),
      ],
      child: MaterialApp(
        title: 'Bible App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    );
  }
}

/// Simple home screen with navigation to reader and other features.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bible App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Navigate to search screen
            },
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () {
              // TODO: Navigate to bookmarks screen
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Quick access to recent chapters
          _buildSectionTitle(context, 'Recent'),
          _buildRecentChapters(context),
          
          const SizedBox(height: 24),
          
          // Bible books grid
          _buildSectionTitle(context, 'Books'),
          _buildBooksGrid(context),
        ],
      ),
      bottomNavigationBar: const BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Bible',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.headphones),
            label: 'Audio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Plans',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildRecentChapters(BuildContext context) {
    // TODO: Load from user history in Supabase
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildChapterCard(context, 'John', 1),
          _buildChapterCard(context, 'Psalm', 23),
          _buildChapterCard(context, 'Romans', 8),
        ],
      ),
    );
  }

  Widget _buildChapterCard(BuildContext context, String bookName, int chapter) {
    return Card(
      margin: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: () {
          // Navigate to reader screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ReaderScreen(
                bookId: 'JHN', // TODO: Map book names to IDs
                chapterNumber: 1,
                translationId: 'eng ESV',
              ),
            ),
          );
        },
        child: SizedBox(
          width: 120,
          height: 80,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  bookName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Chapter $chapter',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBooksGrid(BuildContext context) {
    final books = [
      {'name': 'Genesis', 'id': 'GEN', 'testament': 'OT'},
      {'name': 'Exodus', 'id': 'EXO', 'testament': 'OT'},
      {'name': 'Psalms', 'id': 'PSA', 'testament': 'OT'},
      {'name': 'Matthew', 'id': 'MAT', 'testament': 'NT'},
      {'name': 'Mark', 'id': 'MRK', 'testament': 'NT'},
      {'name': 'Luke', 'id': 'LUK', 'testament': 'NT'},
      {'name': 'John', 'id': 'JHN', 'testament': 'NT'},
      {'name': 'Acts', 'id': 'ACT', 'testament': 'NT'},
      {'name': 'Romans', 'id': 'ROM', 'testament': 'NT'},
      // TODO: Load all books from BibleBrainService
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return Card(
          child: InkWell(
            onTap: () {
              // Navigate to chapter selection, then to reader
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReaderScreen(
                    bookId: book['id'] as String,
                    chapterNumber: 1,
                    translationId: 'eng ESV',
                  ),
                ),
              );
            },
            child: Center(
              child: Text(
                book['name'] as String,
                style: Theme.of(context).textTheme.titleSmall,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
    );
  }
}
