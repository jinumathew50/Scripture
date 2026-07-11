# Bible App

A cross-platform Bible reading and listening app built with Flutter and Supabase, featuring dramatized audio playback, offline access, and structured reading plans.

## Features

### MVP Features
- **Scripture Reading**: Multiple translations, chapter/verse navigation, adjustable font size, light/dark/sepia themes
- **Audio Bible**: Streamed and downloadable dramatized narration with verse-level text highlighting
- **Offline Mode**: Download books/chapters for offline use with license-compliant caching
- **Reading Plans**: Pre-built plans (chronological, 90-day NT, topical) with progress tracking
- **Accounts & Sync**: Supabase Authentication with bookmarks, highlights, notes synced across devices
- **Search**: Full-text search within active translation

### Future Features
- AI study assistant powered by Gemini
- Verse-of-the-day share cards
- Group/community reading plans
- Journal entries linked to passages

## Tech Stack

- **Frontend**: Flutter (iOS, Android, Web)
- **Backend**: Supabase (Auth, PostgreSQL Database, Edge Functions)
- **State Management**: flutter_bloc
- **Audio**: just_audio, audio_service
- **Local Storage**: Hive
- **Bible Content**: Bible Brain API (via Supabase Edge Functions)

## Project Structure

```
bible-app/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── app.dart                     # Main app widget
│   ├── dependency_injection.dart    # GetIt service locator setup
│   ├── core/                        # Core utilities and config
│   │   ├── config/                  # App configuration
│   │   ├── theme/                   # App theming
│   │   ├── network/                 # Network utilities
│   │   └── utils/                   # Helper functions
│   ├── features/                    # Feature modules
│   │   ├── auth/                    # Authentication feature
│   │   ├── bible_reader/            # Bible reading feature
│   │   ├── audio_player/            # Audio playback feature
│   │   ├── downloads/               # Offline downloads feature
│   │   ├── reading_plans/           # Reading plans feature
│   │   ├── search/                  # Search feature
│   │   └── ai_assistant/            # AI study assistant (stretch)
│   ├── shared/                      # Shared code across features
│   │   ├── models/                  # Shared data models
│   │   ├── repositories/            # Shared repository interfaces
│   │   ├── services/                # Shared services
│   │   └── widgets/                 # Reusable widgets
│   └── routes/                      # App routing configuration
├── supabase/
│   ├── migrations/                  # Database schema migrations
│   └── functions/                   # Supabase Edge Functions
│       ├── get-bible-versions/      # Fetch available Bible versions
│       ├── get-books/               # Fetch books for a version
│       ├── get-chapter/             # Fetch chapter text
│       ├── get-audio-url/           # Get audio file URL
│       └── get-audio-timing/        # Get verse-level audio timing
├── assets/                          # App assets (images, fonts, etc.)
├── test/                            # Unit and widget tests
└── pubspec.yaml                     # Flutter dependencies
```

## Getting Started

### Prerequisites

1. Flutter SDK (>=3.0.0)
2. Supabase account and project
3. Bible Brain API key (free for non-commercial use)
4. Android Studio / Xcode for mobile development

### Setup Instructions

1. **Clone the repository**
   ```bash
   cd bible-app
   ```

2. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up Supabase**
   - Create a new Supabase project at [supabase.com](https://supabase.com)
   - Run the database migration in `supabase/migrations/001_initial_schema.sql`
   - Note your Supabase URL and anon key

4. **Configure environment variables**
   
   Create a `.env` file or use Flutter's `--dart-define` flag:
   ```bash
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   EDGE_FUNCTION_URL=https://your-project-id.supabase.co/functions/v1
   ```

5. **Deploy Edge Functions**
   ```bash
   # Install Supabase CLI
   npm install -g supabase
   
   # Login to Supabase
   supabase login
   
   # Deploy all edge functions
   supabase functions deploy get-bible-versions
   supabase functions deploy get-books
   supabase functions deploy get-chapter
   supabase functions deploy get-audio-url
   supabase functions deploy get-audio-timing
   ```

6. **Set Edge Function secrets**
   ```bash
   supabase secrets set BIBLE_BRAIN_API_KEY=your_bible_brain_api_key
   ```

7. **Run the app**
   ```bash
   # For development with environment variables
   flutter run \
     --dart-define=SUPABASE_URL=your_url \
     --dart-define=SUPABASE_ANON_KEY=your_key \
     --dart-define=EDGE_FUNCTION_URL=your_edge_function_url
   ```

## Configuration

### Bible Brain API

1. Sign up for a free API key at [Bible Brain](https://biblebrain.com)
2. Review the license terms for your intended use (non-commercial vs commercial)
3. Only cache/download content that is explicitly marked as downloadable

### Supabase Setup

The app requires the following Supabase tables (created by the migration):
- `profiles` - User profiles extending auth.users
- `bookmarks` - User bookmarks
- `highlights` - Verse highlights with colors
- `notes` - Personal notes on passages
- `reading_plans` - Reading plan definitions
- `reading_plan_days` - Daily readings within plans
- `downloads` - Cross-device download tracking
- `user_preferences` - User settings

All tables have Row Level Security (RLS) policies enabled to ensure users can only access their own data.

## Architecture

The app follows Clean Architecture principles with these layers:

1. **Presentation Layer**: UI widgets, screens, and BLoC state management
2. **Domain Layer**: Business logic entities, repositories interfaces, and use cases
3. **Data Layer**: Repository implementations, data sources, and models

### State Management

Uses flutter_bloc for predictable state management:
- Each feature has its own BLoC (Business Logic Component)
- Events trigger state changes
- UI reacts to state changes via BlocBuilder/BlocListener

### Offline-First Design

- Text content cached locally using Hive
- Audio files downloaded to device storage
- Download manager tracks cached content
- License compliance enforced (only cache what's permitted)

## Build Roadmap

### Phase 1: Core Reader (Weeks 1-3)
- [x] Project scaffolding
- [x] Supabase integration
- [x] Basic scripture reader
- [ ] Multiple translations support
- [ ] Theme switching

### Phase 2: Audio System (Weeks 4-6)
- [ ] Audio player implementation
- [ ] Verse-by-verse synchronization
- [ ] Background playback
- [ ] Download manager

### Phase 3: Personalization (Weeks 7-8)
- [ ] Bookmarks system
- [ ] Highlights with colors
- [ ] Notes functionality
- [ ] Reading plans

### Phase 4: Advanced Features (Weeks 9-10)
- [ ] Full-text search
- [ ] AI study assistant
- [ ] Accessibility improvements

### Phase 5: Polish & Deploy (Weeks 11-12)
- [ ] Performance optimization
- [ ] Testing
- [ ] App store submissions

## License Considerations

This app uses Bible Brain API content which has specific license terms:
- Free for non-commercial use
- Only filesets explicitly flagged as downloadable may be cached offline
- Commercial use requires separate licensing
- Always verify current license terms before distribution

## Contributing

Contributions are welcome! Please follow these guidelines:
1. Follow Clean Architecture principles
2. Write tests for new features
3. Update documentation as needed
4. Ensure RLS policies are updated for new tables

## Support

For issues or questions:
- Check existing GitHub issues
- Review Supabase and Flutter documentation
- Consult Bible Brain API documentation
