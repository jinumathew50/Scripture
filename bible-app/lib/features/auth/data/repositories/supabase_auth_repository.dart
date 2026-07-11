import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../domain/entities/user_entity.dart';
import '../auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient supabase;

  SupabaseAuthRepository({required this.supabase});

  @override
  Future<UserEntity?> getCurrentUser() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    // Fetch additional profile data from Supabase
    try {
      final response = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      return UserEntity.fromMap({
        ...user.toMap(),
        ...response,
      });
    } catch (e) {
      // If profile doesn't exist yet, return basic user info
      return UserEntity(
        id: user.id,
        email: user.email,
        displayName: user.userMetadata?['display_name'],
        photoUrl: user.userMetadata?['avatar_url'],
        createdAt: user.createdAt ?? DateTime.now(),
      );
    }
  }

  @override
  Future<UserEntity> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final response = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Failed to sign in');
    }

    // Update last login timestamp
    await _updateLastLogin(response.user!.id);

    return await getCurrentUser() as UserEntity;
  }

  @override
  Future<UserEntity> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Failed to sign up');
    }

    // Create profile record (trigger should handle this, but being explicit)
    await _createProfile(response.user!.id, email: email);

    return await getCurrentUser() as UserEntity;
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    final response = await supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'bibleapp://callback',
    );

    // For OAuth, we need to wait for the session to be established
    // This is handled by the deep link callback
    // Return current user after successful OAuth flow
    final currentUser = await getCurrentUser();
    if (currentUser == null) {
      throw Exception('OAuth sign in failed');
    }
    return currentUser;
  }

  @override
  Future<UserEntity> signInWithApple() async {
    final response = await supabase.auth.signInWithOAuth(
      OAuthProvider.apple,
      redirectTo: 'bibleapp://callback',
    );

    // Similar to Google OAuth
    final currentUser = await getCurrentUser();
    if (currentUser == null) {
      throw Exception('Apple sign in failed');
    }
    return currentUser;
  }

  @override
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  @override
  Future<void> resetPassword(String email) async {
    await supabase.auth.resetPasswordForEmail(
      email,
      redirectTo: 'bibleapp://reset-password',
    );
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return supabase.auth.onAuthStateChange.map((data) async {
      final session = data.session;
      if (session?.user != null) {
        await _updateLastLogin(session!.user.id);
        return await getCurrentUser();
      }
      return null;
    }).asyncMap((event) => event as UserEntity?);
  }

  Future<void> _createProfile(String userId, {String? email}) async {
    await supabase.from('profiles').upsert({
      'id': userId,
      'email': email,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> _updateLastLogin(String userId) async {
    await supabase
        .from('profiles')
        .update({'last_login_at': DateTime.now().toIso8601String()})
        .eq('id', userId);
  }
}
