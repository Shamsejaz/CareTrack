import 'dart:io';
import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';

class AIService {
  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: 'YOUR_API_KEY_HERE');
  
  static Future<Map<String, dynamic>> analyzeMeal(String imagePath) async {
    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: _apiKey,
      );

      final imageBytes = await File(imagePath).readAsBytes();
      
      final prompt = TextPart('''
        Analyze this meal photo for a diabetes management app. 
        Provide the following details in a JSON format:
        {
          "mealName": "Name of the dish",
          "calories": "estimated calories with unit",
          "carbs": "estimated carbohydrates with unit",
          "healthStatus": "Healthy, Moderate, or Warning",
          "advice": "Short health tip for a diabetic patient"
        }
        Only return the JSON.
      ''');

      final content = [
        Content.multi([
          prompt,
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      final response = await model.generateContent(content);
      final text = response.text;
      
      if (text == null) throw Exception('Empty response from AI');

      // Simple JSON extraction (more robust regex could be used)
      final jsonStart = text.indexOf('{');
      final jsonEnd = text.lastIndexOf('}') + 1;
      final jsonStr = text.substring(jsonStart, jsonEnd);
      
      return json.decode(jsonStr);
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
