import 'package:health/health.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class HealthService {
  static final Health _health = Health();

  /// Requests permissions and fetches total steps for today.
  static Future<int> getTodaySteps() async {
    // Health package is mostly for iOS and Android
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      return 0; // Return 0 for unsupported platforms like Web/Windows
    }

    try {
      final types = [HealthDataType.STEPS];
      
      // Request permissions
      bool hasPermissions = await _health.hasPermissions(types) ?? false;
      if (!hasPermissions) {
        hasPermissions = await _health.requestAuthorization(types);
      }

      if (!hasPermissions) {
        debugPrint("Health permissions not granted.");
        return 0;
      }

      // Fetch steps from midnight to now
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);
      
      int? steps = await _health.getTotalStepsInInterval(midnight, now);
      return steps ?? 0;
    } catch (e) {
      debugPrint("Error reading health data: $e");
      return 0;
    }
  }
}
