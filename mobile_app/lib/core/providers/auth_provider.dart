import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';// Provider for the Supabase instance
final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// Stream provider to listen to authentication state changes
final authStateProvider = StreamProvider<AuthState>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return supabase.auth.onAuthStateChange;
});

// Provider for the current user, supports Demo Mode
class DemoNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  set state(bool value) => super.state = value;
}

final isDemoProvider = NotifierProvider<DemoNotifier, bool>(DemoNotifier.new);

final currentUserProvider = Provider<User?>((ref) {
  final isDemo = ref.watch(isDemoProvider);
  if (isDemo) {
    // Return a mock user for demo purposes
    return const User(
      id: '00000000-0000-0000-0000-000000000000',
      appMetadata: {},
      userMetadata: {'full_name': 'Demo User'},
      aud: 'authenticated',
      createdAt: '1970-01-01T00:00:00Z',
    );
  }
  final supabase = ref.watch(supabaseProvider);
  return supabase.auth.currentUser;
});

class AuthController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    return null;
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final supabase = ref.read(supabaseProvider);
      await supabase.auth.signInWithPassword(email: email, password: password);
    });
  }

  Future<void> signUp(String email, String password, Map<String, dynamic> metadata) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final supabase = ref.read(supabaseProvider);
      await supabase.auth.signUp(
        email: email,
        password: password,
        data: metadata,
      );
    });
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final supabase = ref.read(supabaseProvider);
      await supabase.auth.signOut();
    });
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, void>(() {
  return AuthController();
});
