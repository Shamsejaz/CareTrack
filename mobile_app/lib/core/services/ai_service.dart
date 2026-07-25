import 'dart:convert';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class AIService {
  static Future<Map<String, dynamic>> analyzeMeal(Uint8List imageBytes) async {
    try {
      final response = await Supabase.instance.client.functions.invoke(
        'analyze-meal',
        body: {'imageBase64': base64Encode(imageBytes)},
      );

      final data = response.data;
      if (data == null) throw Exception('Empty response from AI Edge Function');

      return data as Map<String, dynamic>;
    } catch (e) {
      debugPrint('AI Analysis Error: $e');
      return {
        'mealName': 'Analysis Failed',
        'calories': '--',
        'carbs': '--',
        'healthStatus': 'Unknown',
        'advice': 'Could not analyze image. Please try again.'
      };
    }
  }
}
