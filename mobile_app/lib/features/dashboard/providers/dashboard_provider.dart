import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/auth_provider.dart';

// Provides the dashboard data asynchronously from Supabase directly
final dashboardDataProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final isDemo = ref.watch(isDemoProvider);
  
  if (isDemo) {
    // Return realistic mock data for Demo Mode
    return {
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
