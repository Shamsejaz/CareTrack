import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/auth_provider.dart';
import '../../profile/providers/profile_provider.dart';

// Provides the dashboard data asynchronously from Supabase directly
final dashboardDataProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final isDemo = ref.watch(isDemoProvider);
  
  if (isDemo) {
    // Return realistic mock data for Demo Mode
    return {
      'isCaregiver': false,
      'sugar': { 
          'lastReading': '105',
          'status': 'Normal'
      },
      'steps': { 
          'current': 3420, 
          'goal': 5000 
      },
      'water': { 
          'glasses': 6
      },
      'sleep': { 
          'duration': '7h 20m' 
      },
      'medications': [
        {'name': 'Metformin', 'time': '08:00 AM', 'status': 'Taken'},
        {'name': 'Vitamin D', 'time': '09:30 AM', 'status': 'Taken'},
        {'name': 'Metformin', 'time': '08:00 PM', 'status': 'Pending'},
      ],
      'recentActivity': [
        {'title': 'Morning Walk', 'subtitle': '30 mins activity', 'time': '07:30 AM', 'value': '+1200 steps'},
        {'title': 'Breakfast', 'subtitle': 'Oatmeal & Berries', 'time': '08:15 AM', 'value': '340 kcal'},
      ]
    };
  }

  final supabase = ref.watch(supabaseProvider);
  final user = ref.watch(currentUserProvider);
  
  if (user == null) return {};

  final profile = await ref.watch(profileProvider.future);
  final isCaregiver = profile['role'] == 'caregiver';

  if (isCaregiver) {
    try {
      // 1. Fetch care links
      final linksResponse = await supabase
          .from('care_links')
          .select('patient_id')
          .eq('caregiver_id', user.id);
      
      final List<String> patientIds = (linksResponse as List)
          .map((e) => e['patient_id'].toString())
          .toList();

      if (patientIds.isEmpty) {
        return {
          'isCaregiver': true,
          'patients': <Map<String, dynamic>>[],
          'pendingAlerts': 0,
        };
      }

      // 2. Fetch profiles of linked patients
      final patientsResponse = await supabase
          .from('profiles')
          .select('*')
          .inFilter('id', patientIds);
          
      final List<Map<String, dynamic>> patientProfiles = (patientsResponse as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      // 3. Fetch count of pending alerts for these patients
      final alertsResponse = await supabase
          .from('notifications')
          .select('id')
          .eq('is_read', false)
          .inFilter('patient_id', patientIds);
          
      final pendingAlertsCount = (alertsResponse as List).length;

      // 4. Fetch latest health logs for each patient
      final List<Map<String, dynamic>> patientsWithLogs = [];
      for (var patient in patientProfiles) {
        final latestLogRes = await supabase
            .from('health_logs')
            .select()
            .eq('patient_id', patient['id'])
            .order('created_at', ascending: false)
            .limit(1)
            .maybeSingle();

        patientsWithLogs.add({
          ...patient,
          'latest_log': latestLogRes,
        });
      }

      return {
        'isCaregiver': true,
        'patients': patientsWithLogs,
        'pendingAlerts': pendingAlertsCount,
      };
    } catch (e) {
      throw Exception('Failed to load caregiver dashboard data: $e');
    }
  }

  // Patient user flow
  final startOfDay = DateTime.now().toUtc().subtract(Duration(
    hours: DateTime.now().hour,
    minutes: DateTime.now().minute,
    seconds: DateTime.now().second,
  ));

  try {
    final response = await supabase
        .from('health_logs')
        .select()
        .eq('patient_id', user.id)
        .gte('created_at', startOfDay.toIso8601String());

    final List<Map<String, dynamic>> logs = (response as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();

    // Aggregate statistics
    final sugarLogs = logs.where((l) => l['log_type'] == 'Sugar').toList();
    sugarLogs.sort((a, b) => b['created_at'].compareTo(a['created_at']));
    final latestSugar = sugarLogs.isNotEmpty ? sugarLogs.first : null;
    
    final totalSteps = logs
        .where((l) => l['log_type'] == 'Walk')
        .fold<int>(0, (sum, l) => sum + (int.tryParse(l['value']?.toString() ?? '0') ?? 0));
        
    final totalWater = logs
        .where((l) => l['log_type'] == 'Water')
        .fold<int>(0, (sum, l) => sum + (int.tryParse(l['value']?.toString() ?? '0') ?? 0));

    final sleepLog = logs.where((l) => l['log_type'] == 'Sleep').isNotEmpty 
        ? logs.firstWhere((l) => l['log_type'] == 'Sleep') 
        : null;

    return {
      'isCaregiver': false,
      'sugar': { 
          'lastReading': latestSugar?['value'] ?? '--',
          'status': latestSugar?['intervention_alert']?['severity'] ?? 'Normal'
      },
      'steps': { 
          'current': totalSteps, 
          'goal': 5000 
      },
      'water': { 
          'glasses': totalWater
      },
      'sleep': { 
          'duration': sleepLog?['value'] ?? '--' 
      },
    };
  } catch (e) {
    throw Exception('Failed to load dashboard data from Supabase: $e');
  }
});
