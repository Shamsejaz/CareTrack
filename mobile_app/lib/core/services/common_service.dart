import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/auth_provider.dart';

/**
 * Common Logic Layer (Client-Side implementation of the logic layer)
 * This service provides high-level business logic that coordinates multiple 
 * Supabase operations or internal AI processing.
 * 
 * Since we are simplifying the deployment, this logic is moved directly into 
 * the client applications (Mobile/Web) while sharing the same database.
 */
class CommonService {
  final SupabaseClient _supabase;

  CommonService(this._supabase);

  /**
   * Analyzes a health log entry for potential medical alerts.
   */
  Future<Map<String, dynamic>> analyzeHealthLog(String logId, String logType, String value) async {
    Map<String, dynamic>? interventionAlert;
    
    if (logType == 'Sugar') {
      final sugarValue = double.tryParse(value.split(' ').first) ?? 0;
      if (sugarValue > 180) {
        interventionAlert = { 
          'severity': 'High', 
          'message': 'Alert: High Sugar detected. Please hydrate and consult your medication schedule.' 
        };
      } else if (sugarValue < 70) {
        interventionAlert = { 
          'severity': 'Danger', 
          'message': 'Alert: Low Sugar detected! Please consume 15g of fast-acting carbs immediately.' 
        };
      }
    }

    // If an alert is detected, log it to the notifications table
    if (interventionAlert != null) {
      try {
        final response = await _supabase.from('health_logs').select('patient_id').eq('id', logId).single();
        final patientId = response['patient_id'];
        
        await _supabase.from('notifications').insert({
          'patient_id': patientId,
          'type': interventionAlert['severity'] == 'Danger' ? 'critical_sugar' : 'high_sugar',
          'message': interventionAlert['message'],
        });

        // Also update the health log with the alert info
        await _supabase.from('health_logs').update({
          'intervention_alert': interventionAlert,
        }).eq('id', logId);
      } catch (e) {
        print('Error creating notification: $e');
      }
    }

    return {'success': true, 'interventionAlert': interventionAlert};
  }
}

final commonServiceProvider = Provider<CommonService>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return CommonService(supabase);
});
