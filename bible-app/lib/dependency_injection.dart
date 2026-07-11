import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Auth Feature
import 'features/auth/data/repositories/supabase_auth_repository.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

// Bible Reader Feature
import 'features/bible_reader/data/repositories/supabase_bible_repository.dart';
import 'features/bible_reader/domain/repositories/bible_repository.dart';
import 'features/bible_reader/presentation/bloc/bible_reader_bloc.dart';

// Core Config
import 'core/config/app_config.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  // Supabase Client
  final supabase = Supabase.instance.client;
  sl.registerSingleton<SupabaseClient>(supabase);

  // Dio HTTP Client
  final dio = Dio();
  sl.registerSingleton<Dio>(dio);

  // Edge Function URL
  const edgeFunctionUrl = String.fromEnvironment(
    'EDGE_FUNCTION_URL',
    defaultValue: 'https://YOUR_PROJECT_ID.supabase.co/functions/v1',
  );

  /////////////////////////////
  // Auth Feature
  /////////////////////////////
  
  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => SupabaseAuthRepository(supabase: sl<SupabaseClient>()),
  );

  // Bloc
  sl.registerFactory(
    () => AuthBloc(authRepository: sl<AuthRepository>()),
  );

  /////////////////////////////
  // Bible Reader Feature
  /////////////////////////////
  
  // Repository
  sl.registerLazySingleton<BibleRepository>(
    () => SupabaseBibleRepository(
      supabase: sl<SupabaseClient>(),
      dio: sl<Dio>(),
      edgeFunctionUrl: edgeFunctionUrl,
    ),
  );

  // Bloc
  sl.registerFactory(
    () => BibleReaderBloc(bibleRepository: sl<BibleRepository>()),
  );

  /////////////////////////////
  // Other Features (to be implemented)
  /////////////////////////////
  // - Audio Player
  // - Downloads
  // - Reading Plans
  // - Search
  // - AI Assistant
}
