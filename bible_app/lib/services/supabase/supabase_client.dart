import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase client singleton for the Bible App.
/// 
/// Handles authentication, database connections, storage, and realtime subscriptions.
/// Initialize this in main() before running the app.
class SupabaseClient {
  SupabaseClient._();

  static final SupabaseClient _instance = SupabaseClient._();

  static SupabaseClient get instance => _instance;

  late final SupabaseClient _supabase;

  /// Initialize Supabase with your project credentials.
  /// 
  /// Call this in main() before runApp().
  Future<void> initialize({
    required String supabaseUrl,
    required String supabaseAnonKey,
  }) async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    
    _supabase = Supabase.instance.client;
  }

  /// Get the underlying Supabase client instance.
  SupabaseClient get client {
    if (!_supabaseInitialized) {
      throw Exception('Supabase not initialized. Call initialize() first.');
    }
    return _supabase;
  }

  bool get _supabaseInitialized => _supabase != null;

  /// Auth methods
  Future<User?> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    final response = await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response.user;
  }

  Future<User?> signUpWithEmailPassword({
    required String email,
    required String password,
  }) async {
    final response = await client.auth.signUp(
      email: email,
      password: password,
    );
    return response.user;
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  User? get currentUser => client.auth.currentUser;

  Stream<User?> get authStateChanges => client.auth.onAuthStateChange.map((data) => data.session?.user);

  /// Database methods
  Future<List<Map<String, dynamic>>> query({
    required String table,
    String? columns,
    dynamic Function(PostgrestFilterBuilder)? filter,
  }) async {
    var query = client.from(table).select(columns ?? '*');
    
    if (filter != null) {
      query = filter(query as PostgrestFilterBuilder) as PostgrestQueryBuilder;
    }
    
    final response = await query;
    return response as List<Map<String, dynamic>>;
  }

  Future<void> insert({
    required String table,
    required Map<String, dynamic> value,
  }) async {
    await client.from(table).insert(value);
  }

  Future<void> update({
    required String table,
    required dynamic id,
    required Map<String, dynamic> value,
  }) async {
    await client.from(table).update(value).eq('id', id);
  }

  Future<void> delete({
    required String table,
    required dynamic id,
  }) async {
    await client.from(table).delete().eq('id', id);
  }

  /// Storage methods
  Future<String?> uploadFile({
    required String bucketId,
    required String path,
    required String filePath,
  }) async {
    final file = await client.storage.from(bucketId).upload(path, filePath);
    return file.path;
  }

  Future<String> getPublicUrl({
    required String bucketId,
    required String path,
  }) async {
    return client.storage.from(bucketId).getPublicUrl(path);
  }

  /// Realtime subscriptions
  void subscribeToChannel({
    required String channelName,
    required String tableName,
    required String event,
    required Function(Map<String, dynamic>) callback,
  }) {
    client.channel(channelName)
      .onPostgresChanges(
        event: event,
        schema: 'public',
        table: tableName,
        callback: (payload) {
          callback(payload.newRecord);
        },
      )
      .subscribe();
  }
}

/// Extension to make Supabase client easily accessible
extension SupabaseExtension on SupabaseClient {
  SupabaseClient get client => SupabaseClient.instance.client;
}
