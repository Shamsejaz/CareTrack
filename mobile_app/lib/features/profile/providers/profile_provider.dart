import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/auth_provider.dart';

final profileProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final isDemo = ref.watch(isDemoProvider);
  if (isDemo) {
    return {
      'full_name': 'Demo User',
      'avatar_url': 'https://i.pravatar.cc/150?u=demo',
      'role': 'patient',
      'wake_up_time': '07:00',
      'gender': 'United States',
      'conditions': ['Diabetes'],
    };
  }

  final supabase = ref.watch(supabaseProvider);
  final user = ref.watch(currentUserProvider);

  if (user == null) {
    return {};
  }

  try {
    final response = await supabase
        .from('profiles')
        .select('*')
        .eq('id', user.id)
        .maybeSingle();

    if (response != null) {
      return response;
    }
  } catch (e) {
    debugPrint('Error fetching profile: $e');
  }

  return {
    'full_name': user.email?.split('@').first ?? 'User',
  };
});
