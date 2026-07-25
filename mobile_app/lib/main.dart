import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme/app_theme.dart';
import 'features/onboarding/welcome_screen.dart';
import 'features/onboarding/role_selection_screen.dart';
import 'features/onboarding/conditions_setup_screen.dart';
import 'features/onboarding/prescription_upload_screen.dart';
import 'features/onboarding/prescription_review_screen.dart';
import 'features/onboarding/prescription_confirmation_screen.dart';
import 'features/onboarding/language_selection_screen.dart';
import 'features/onboarding/location_setup_screen.dart';
import 'features/onboarding/daily_schedule_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/dashboard/vitals_dashboard_screen.dart';
import 'features/dashboard/tasks_screen.dart';
import 'features/profile/subscription_screen.dart';
import 'features/profile/edit_profile_screen.dart';
import 'features/tracking/sugar_tracker_screen.dart';
import 'features/tracking/sugar_ai_alert_screen.dart';
import 'features/tracking/meal_tracker_screen.dart';
import 'features/tracking/medicine_tracker_screen.dart';
import 'features/tracking/craving_screen.dart';
import 'features/tracking/walk_tracker_screen.dart';
import 'features/tracking/water_tracker_screen.dart';
import 'features/profile/care_team_screen.dart';
import 'features/profile/profile_screen.dart';

import 'features/chat/chat_screen.dart';
import 'features/auth/login_screen.dart';



import 'core/services/notification_service.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await NotificationService().init();

  try {
    // Check if already initialized by trying to access instance
    Supabase.instance;
  } catch (e) {
    // If it throws, it's not initialized yet
    const String supabaseUrl = String.fromEnvironment(
      'SUPABASE_URL',
      defaultValue: 'https://svuruefzexxbyetpbixh.supabase.co',
    );
    const String supabaseAnonKey = String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue: 'sb_publishable_OvFPaFXN3LA78Xbqqza9uA_MgcYP8jY',
    );
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  // Initialize RevenueCat
  try {
    await Purchases.setLogLevel(LogLevel.debug);
    
    // Replace with your real API keys
    PurchasesConfiguration configuration;
    if (Platform.isAndroid) {
      configuration = PurchasesConfiguration('goog_dummy_key');
    } else {
      configuration = PurchasesConfiguration('appl_dummy_key');
    }
    
    await Purchases.configure(configuration);
    
    // Attempt to log in to RevenueCat if the user is already authenticated in Supabase
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      await Purchases.logIn(session.user.id);
    }
  } catch (e) {
    debugPrint('RevenueCat initialization failed: $e');
  }

  runApp(
    const ProviderScope(
      child: CareTrackApp(),
    ),
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/setup/language',
        builder: (context, state) => const LanguageSelectionScreen(),
      ),
      GoRoute(
        path: '/setup/location',
        builder: (context, state) => const LocationSetupScreen(),
      ),
      GoRoute(
        path: '/setup/schedule',
        builder: (context, state) => const DailyScheduleScreen(),
      ),
      GoRoute(
        path: '/setup/role',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/setup/conditions',
        builder: (context, state) => const ConditionsSetupScreen(),
      ),
      GoRoute(
        path: '/setup/prescription',
        builder: (context, state) => const PrescriptionUploadScreen(),
      ),
      GoRoute(
        path: '/setup/prescription/review',
        builder: (context, state) => const PrescriptionReviewScreen(),
      ),
      GoRoute(
        path: '/setup/prescription/confirm',
        builder: (context, state) => const PrescriptionConfirmationScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/dashboard/vitals',
        builder: (context, state) => const VitalsDashboardScreen(),
      ),
      GoRoute(
        path: '/dashboard/tasks',
        builder: (context, state) => const TasksScreen(),
      ),
      GoRoute(
        path: '/track/sugar',
        builder: (context, state) => const SugarTrackerScreen(),
      ),
      GoRoute(
        path: '/track/sugar/alert',
        builder: (context, state) {
          final sugarValue = state.extra as int? ?? 250;
          return SugarAiAlertScreen(sugarValue: sugarValue);
        },
      ),
      GoRoute(
        path: '/track/meal',
        builder: (context, state) => const MealTrackerScreen(),
      ),
      GoRoute(
        path: '/track/medicine',
        builder: (context, state) => const MedicineTrackerScreen(),
      ),
      GoRoute(
        path: '/track/craving',
        builder: (context, state) => const CravingScreen(),
      ),
      GoRoute(
        path: '/track/walk',
        builder: (context, state) => const WalkTrackerScreen(),
      ),
      GoRoute(
        path: '/track/water',
        builder: (context, state) => const WaterTrackerScreen(),
      ),
      GoRoute(
        path: '/profile/care-team',
        builder: (context, state) => const CareTeamScreen(),
      ),
      GoRoute(
        path: '/profile/subscription',
        builder: (context, state) => const SubscriptionScreen(),
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/chat/:userId',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return ChatScreen(receiverId: userId);
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/profile/care-team',
        builder: (context, state) => const CareTeamScreen(),
      ),
      GoRoute(
        path: '/tasks',
        builder: (context, state) => const DashboardScreen(), // Placeholder for now
      ),

    ],
  );
});

class CareTrackApp extends ConsumerWidget {
  const CareTrackApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'CareTrack',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // For a clinical/elderly app, enforcing light mode initially might be safer, 
      // but we will support dark mode later as per requirements.
      themeMode: ThemeMode.light, 
      routerConfig: router,
      builder: (context, child) {
        return Container(
          color: Colors.grey[100], // Light background outside the mobile frame
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450), // Mobile width limit
              child: ClipRect(
                child: child ?? const SizedBox(),
              ),
            ),
          ),
        );
      },
    );
  }
}
