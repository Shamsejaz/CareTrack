import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/auth_provider.dart';

final tasksProvider = FutureProvider<Map<String, List<Map<String, dynamic>>>>((ref) async {
  final isDemo = ref.watch(isDemoProvider);
  
  if (isDemo) {
    return {
      'Medications': [
        {'title': 'Metformin (500mg)', 'sub': 'Take after breakfast', 'time': '08:30 AM', 'isDone': true},
        {'title': 'Lisinopril (10mg)', 'sub': 'Take with water', 'time': '09:00 AM', 'isDone': false},
        {'title': 'Multivitamin', 'sub': 'Daily supplement', 'time': '10:00 AM', 'isDone': false},
      ],
      'Health Checks': [
        {'title': 'Blood Sugar Check', 'sub': 'Fastest reading', 'time': '07:30 AM', 'isDone': true},
        {'title': 'Blood Pressure', 'sub': 'Evening monitoring', 'time': '08:00 PM', 'isDone': false},
      ],
      'Wellness': [
        {'title': 'Morning Walk', 'sub': '15 mins in garden', 'time': '09:30 AM', 'isDone': false},
        {'title': 'Hydration Goal', 'sub': '8 glasses of water', 'time': 'All Day', 'isDone': false},
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
    // Fetch medications
    final medsResponse = await supabase
        .from('medications')
        .select()
        .eq('patient_id', user.id)
        .eq('is_active', true);
        
    final List<Map<String, dynamic>> meds = (medsResponse as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();

    // Fetch today's health logs
    final logsResponse = await supabase
        .from('health_logs')
        .select()
        .eq('patient_id', user.id)
        .gte('created_at', startOfDay.toIso8601String());

    final List<Map<String, dynamic>> logs = (logsResponse as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();

    // Process Medications
    final medsTasks = meds.map((med) {
      final name = med['name'] ?? 'Unknown Med';
      final isDone = logs.any((log) => log['log_type'] == 'Medicine' && (log['value']?.toString().contains(name) ?? false));
      return {
        'title': '$name ${med['dose'] != null ? '(${med['dose']})' : ''}',
        'sub': med['timing'] ?? 'As prescribed',
        'time': med['frequency'] ?? 'Daily',
        'isDone': isDone,
      };
    }).toList();

    // Process Health Checks
    final sugarDone = logs.any((log) => log['log_type'] == 'Sugar');
    final healthChecksTasks = [
      {
        'title': 'Blood Sugar Check',
        'sub': 'Daily reading',
        'time': 'Anytime',
        'isDone': sugarDone,
      }
    ];

    // Process Wellness
    final walkDone = logs.any((log) => log['log_type'] == 'Walk');
    final waterDone = logs.where((log) => log['log_type'] == 'Water').fold<int>(0, (sum, l) => sum + (int.tryParse(l['value']?.toString() ?? '0') ?? 0)) >= 8;
    
    final wellnessTasks = [
      {
        'title': 'Morning Walk',
        'sub': 'Stay active',
        'time': 'Morning',
        'isDone': walkDone,
      },
      {
        'title': 'Hydration Goal',
        'sub': '8 glasses of water',
        'time': 'All Day',
        'isDone': waterDone,
      }
    ];

    return {
      'Medications': medsTasks,
      'Health Checks': healthChecksTasks,
      'Wellness': wellnessTasks,
    };

  } catch (e) {
    print('Error loading tasks: $e');
    return {};
  }
});
