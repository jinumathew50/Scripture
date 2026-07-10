# Bible App - Flutter Mobile Application

A cross-platform Bible reading and listening app built with Flutter and Supabase, featuring dramatized audio playback, offline access, and structured reading plans.

## Features

### MVP Features
- **Scripture Reading**: Multiple translations, chapter/verse navigation, adjustable font size, light/dark/sepia themes
- **Audio Bible**: Streamed and downloadable dramatized narration with verse-level text highlighting
- **Offline Mode**: Download books/chapters for offline use with download manager
- **Bookmarks & Highlights**: Verse-level bookmarks, highlights, and personal notes
- **Reading Plans**: Pre-built plans with daily progress tracking and streaks

### Technical Stack
- **Frontend**: Flutter (iOS/Android)
- **Backend**: Supabase (Auth, PostgreSQL, Storage, Edge Functions, Realtime)
- **Bible Content**: Bible Brain API (via Supabase Edge Functions proxy)
- **State Management**: flutter_bloc
- **Local Storage**: Hive + flutter_cache_manager
- **Audio Playback**: just_audio with background support

## Project Structure

```
bible_app/
├── lib/
│   ├── core/                    # Core utilities, constants, theme
│   │   ├── constants/
│   │   ├── errors/
│   │   ├── utils/
│   │   └── theme/
│   ├── data/                    # Data layer (repositories, datasources, models)
│   │   ├── providers/
│   │   ├── repositories/
│   │   ├── models/
│   │   └── local/
│   │       ├── datasources/
│   │       └── cache/
│   ├── domain/                  # Business logic layer
│   │   ├── entities/
│   │   ├── repositories/
│   │   └── usecases/
│   ├── presentation/            # UI layer (screens, widgets, blocs)
│   │   ├── screens/
│   │   │   ├── home/
│   │   │   ├── reader/
│   │   │   ├── audio_player/
│   │   │   ├── bookmarks/
│   │   │   ├── notes/
│   │   │   ├── reading_plans/
│   │   │   ├── settings/
│   │   │   └── downloads/
│   │   ├── widgets/
│   │   └── blocs/
│   ├── services/                # External services
│   │   ├── audio/
│   │   ├── supabase/
│   │   ├── bible_brain/
│   │   └── ai/
│   └── main.dart
├── assets/
│   ├── fonts/
│   ├── images/
│   └── translations/
├── pubspec.yaml
└── README.md
```

## Setup Instructions

### Prerequisites
- Flutter SDK 3.0+
- Supabase account and project
- Bible Brain API key (free for non-commercial use)
- iOS/Android development environment

### 1. Clone and Install Dependencies

```bash
cd bible_app
flutter pub get
```

### 2. Configure Supabase

Create a `.env` file or use Flutter's `--dart-define`:

```bash
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

### 3. Set Up Supabase Database

Run the SQL migrations in your Supabase project to create the required tables:

- `profiles` - User profiles
- `bookmarks` - Verse bookmarks
- `highlights` - Text highlights
- `notes` - Personal notes
- `reading_plans` - Available reading plans
- `user_reading_plans` - User progress in plans
- `downloads` - Offline download tracking
- `ai_response_cache` - Cached AI responses

See `supabase/migrations/` for SQL scripts (to be created).

### 4. Deploy Supabase Edge Functions

Deploy the following Edge Functions to proxy Bible Brain API requests:

```bash
# Install Supabase CLI
npm install -g supabase

# Login to Supabase
supabase login

# Link to your project
supabase link --project-ref your_project_ref

# Deploy edge functions
supabase functions deploy bible-brain-proxy
supabase functions deploy ai-study-assistant
supabase functions deploy sync-offline-actions
```

### 5. Configure Bible Brain API

Add your Bible Brain API key to the Edge Function secrets:

```bash
supabase secrets set BIBLE_BRAIN_API_KEY=your_api_key
```

### 6. Run the App

```bash
# For iOS
flutter run --dart-define=SUPABASE_URL=your_url --dart-define=SUPABASE_ANON_KEY=your_key

# For Android
flutter run --dart-define=SUPABASE_URL=your_url --dart-define=SUPABASE_ANON_KEY=your_key

# For web (limited audio support)
flutter run -d chrome --dart-define=SUPABASE_URL=your_url --dart-define=SUPABASE_ANON_KEY=your_key
```

## Key Components

### Services

#### `SupabaseClient`
Singleton wrapper for Supabase SDK handling:
- Authentication (email, Google, Apple)
- Database queries with Row Level Security
- Storage operations
- Realtime subscriptions

#### `BibleBrainService`
Proxy service for Bible Brain API:
- Fetches translations, books, chapters
- Retrieves verse-level audio timing data
- Handles offline download permissions
- Search functionality

#### `AudioService`
Audio playback with background support:
- Streaming and offline playback
- Verse-level synchronization
- Variable playback speed (0.5x - 2.0x)
- Sleep timer
- Lock screen controls

### BLoCs

#### `ReaderBloc`
Manages reading state:
- Load chapters from Bible Brain API
- Switch translations
- Toggle bookmarks
- Add highlights
- Change font size and theme

#### `AudioPlayerBloc`
Manages audio playback state:
- Load audio chapters
- Play/pause/stop controls
- Seek to position or verse
- Change playback speed
- Sleep timer management

### Screens

#### `ReaderScreen`
Main scripture reading interface:
- Verse-by-verse rendering
- Bookmark and highlight actions
- Translation selector
- Font size and theme controls
- Light/dark/sepia themes

#### `AudioPlayerScreen`
Full-screen audio player:
- Progress bar with seeking
- Playback controls
- Verse list with current highlighting
- Sleep timer
- Playback speed control

## Architecture Patterns

### Clean Architecture
The app follows Clean Architecture principles:
- **Domain Layer**: Entities and business rules (pure Dart)
- **Data Layer**: Repositories, datasources, models
- **Presentation Layer**: BLoCs, screens, widgets

### State Management
Uses `flutter_bloc` for predictable state management:
- Events trigger state changes
- States are immutable and equatable
- UI rebuilds based on state changes

### Offline-First Design
- Local caching with Hive
- Download manager for offline content
- Sync queue for offline actions
- Conflict resolution on reconnection

## License Considerations

This app uses Bible Brain API content under the following constraints:
- Free for non-commercial use
- Only filesets explicitly flagged as downloadable may be cached offline
- API keys must be kept server-side (via Edge Functions)
- Commercial use requires separate licensing

Always verify current license terms with Faith Comes By Hearing before distribution.

## Next Steps

### Phase 1 (MVP) - Weeks 1-6
- [x] Project scaffolding
- [ ] Complete ReaderScreen with all interactions
- [ ] Complete AudioPlayerScreen with background playback
- [ ] Supabase authentication integration
- [ ] Basic bookmark/highlight functionality

### Phase 2 - Weeks 7-10
- [ ] Offline download manager
- [ ] Sync offline actions to Supabase
- [ ] Cross-device sync
- [ ] Reading history tracking

### Phase 3 - Weeks 11-14
- [ ] Reading plans implementation
- [ ] Full-text search
- [ ] Notes functionality
- [ ] Daily reminders

### Phase 4 - Weeks 15-17
- [ ] AI study assistant
- [ ] Response caching
- [ ] Context-aware explanations

### Phase 5 - Weeks 18-20+
- [ ] Polish and performance optimization
- [ ] Accessibility improvements
- [ ] Multi-language UI
- [ ] Stretch features (verse-of-day, community plans, etc.)

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Write/update tests
5. Submit a pull request

## Support

For issues, questions, or contributions, please open an issue on GitHub.

---

Built with ❤️ for spreading Scripture through modern technology.
