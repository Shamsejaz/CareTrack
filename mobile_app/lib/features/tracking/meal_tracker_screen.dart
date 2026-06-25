import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'dart:ui';
import 'package:go_router/go_router.dart';
import '../../core/api/api_client.dart';
import '../dashboard/providers/dashboard_provider.dart';
import '../../core/providers/auth_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/ai_service.dart';
import '../../core/services/common_service.dart';

class MealTrackerScreen extends ConsumerStatefulWidget {
  const MealTrackerScreen({super.key});

  @override
  ConsumerState<MealTrackerScreen> createState() => _MealTrackerScreenState();
}

class _MealTrackerScreenState extends ConsumerState<MealTrackerScreen> {
  XFile? _imageFile;
  bool _isAnalyzing = false;
  bool _isSaving = false;
  Map<String, dynamic>? _aiAnalysis;

  final ImagePicker _picker = ImagePicker();

  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(
      source: (!kIsWeb && Platform.isWindows) ? ImageSource.gallery : ImageSource.camera,
      imageQuality: 70,
    );

    if (photo != null) {
      setState(() {
        _imageFile = photo;
        _isAnalyzing = true;
      });

      // Simulate AI Analysis
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isAnalyzing = false;
      });
      await _analyzeMeal(photo);
    }
  }

  Future<void> _analyzeMeal(XFile photo) async {
    setState(() => _isAnalyzing = true);
    
    try {
      final result = await AIService.analyzeMeal(photo.path);
      
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _aiAnalysis = {
            'meal_name': result['mealName'] ?? 'Unknown Dish',
            'calories': result['calories'] ?? 0,
            'carbs': result['carbs'] ?? 0,
            'status': result['healthStatus'] ?? 'Unknown',
            'tags': result['tags'] ?? ['Meal'],
            'suggestion': result['advice'] ?? '',
          };
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAnalyzing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('AI Analysis failed: $e')),
        );
      }
    }
  }



  Future<void> _saveMeal() async {
    if (_aiAnalysis == null) return;

    setState(() => _isSaving = true);
    try {
      final supabase = ref.read(supabaseProvider);
      final user = ref.read(currentUserProvider);
      
      if (user == null) throw Exception('User not authenticated');

      final response = await supabase.from('health_logs').insert({
        'patient_id': user.id,
        'log_type': 'Meal',
        'value': _aiAnalysis!['meal_name'],
        'metadata': {
          'calories': _aiAnalysis!['calories'],
          'carbs': _aiAnalysis!['carbs'],
          'ai_status': _aiAnalysis!['status'],
          'suggestion': _aiAnalysis!['suggestion'],
        },
        'manual_confirm': true,
      }).select().single();

      final logId = response['id'];

      // Analyze reading immediately using CommonService
      await ref.read(commonServiceProvider).analyzeHealthLog(logId, 'Meal', _aiAnalysis!['meal_name']);

      ref.invalidate(dashboardDataProvider);

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('AI Meal log saved successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving meal: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildPhotoSection(context),
                  if (_isAnalyzing) ...[
                    const SizedBox(height: 32),
                    _buildAnalyzingState(context),
                  ] else if (_aiAnalysis != null) ...[
                    const SizedBox(height: 24),
                    _buildAiStatusBox(context),
                    const SizedBox(height: 24),
                    _buildNutritionGrid(context),
                    const SizedBox(height: 24),
                    _buildSuggestionCard(context),
                    const SizedBox(height: 48),
                    _buildActions(context),
                  ] else ...[
                    const SizedBox(height: 100),
                    _buildEmptyState(context),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.9),
      elevation: 0,
      centerTitle: false,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_rounded, color: Theme.of(context).colorScheme.primary),
        onPressed: () => context.pop(),
      ),
      title: Text(
        'AI Meal Tracker',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPhotoSection(BuildContext context) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (_imageFile != null)
            Image.file(
              File(_imageFile!.path),
              fit: BoxFit.cover,
            )
          else
            Container(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt_rounded, size: 64, color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
                  const SizedBox(height: 16),
                  Text(
                    'No Photo Taken',
                    style: TextStyle(color: Theme.of(context).colorScheme.primary.withOpacity(0.4)),
                  ),
                ],
              ),
            ),
          
          if (_aiAnalysis != null)
            Positioned(
              top: 24,
              left: 24,
              child: Row(
                children: (_aiAnalysis!['tags'] as List<String>)
                    .map((tag) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _buildFloatingLabel(context, tag),
                        ))
                    .toList(),
              ),
            ),
            
          if (_imageFile == null)
            Center(
              child: ElevatedButton.icon(
                onPressed: _takePhoto,
                icon: const Icon(Icons.add_a_photo_rounded),
                label: const Text('Capture Meal'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFloatingLabel(BuildContext context, String label) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyzingState(BuildContext context) {
    return Column(
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        Text(
          'AI is analyzing your meal...',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Calculating calories and carbohydrate levels',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Column(
      children: [
        Icon(Icons.auto_awesome_rounded, size: 48, color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
        const SizedBox(height: 16),
        const Text(
          'Take a photo of your food to get\ninstant AI nutrition analysis',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildAiStatusBox(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_circle_rounded, color: Theme.of(context).colorScheme.secondary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HEALTH RATING',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        letterSpacing: 2,
                      ),
                ),
                Text(
                  _aiAnalysis!['status'],
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionGrid(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildNutritionCard(
            context,
            icon: Icons.local_fire_department_rounded,
            iconColor: Colors.orange,
            value: '${_aiAnalysis!['calories']}',
            label: 'Calories',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildNutritionCard(
            context,
            icon: Icons.grain_rounded,
            iconColor: Colors.blue,
            value: '${_aiAnalysis!['carbs']}g',
            label: 'Carbs',
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionCard(BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 16),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSuggestionCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_rounded, color: Theme.of(context).colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'AI Insight',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _aiAnalysis!['suggestion'],
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _isSaving ? null : _saveMeal,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
          ),
          child: Center(
            child: _isSaving
                ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Confirm & Log Meal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: _takePhoto,
          child: const Text('Retake Photo'),
        ),
      ],
    );
  }
}
