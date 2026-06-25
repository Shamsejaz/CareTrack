import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/api/api_client.dart';
import '../dashboard/providers/dashboard_provider.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/providers/auth_provider.dart';

class MedicineTrackerScreen extends ConsumerStatefulWidget {
  const MedicineTrackerScreen({super.key});

  @override
  ConsumerState<MedicineTrackerScreen> createState() => _MedicineTrackerScreenState();
}

class _MedicineTrackerScreenState extends ConsumerState<MedicineTrackerScreen> {
  bool _isSaving = false;

  Future<void> _logMedicine(String style) async {
    setState(() => _isSaving = true);
    try {
      final supabase = ref.read(supabaseProvider);
      final user = ref.read(currentUserProvider);
      
      if (user == null) throw Exception('User not authenticated');

      await supabase.from('health_logs').insert({
        'patient_id': user.id,
        'log_type': 'Medicine',
        'value': 'Metformin 500mg',
        'manual_confirm': style == 'manual',
        'photo_url': style == 'photo' ? 'https://placeholder.com/med_proof.jpg' : null,
      });

      ref.invalidate(dashboardDataProvider);

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Metformin 500mg logged successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error logging medicine: $e')),
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: Theme.of(context).colorScheme.onSurfaceVariant),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          _buildBackgroundAesthetics(context),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildVisualAnchor(context),
                  const SizedBox(height: 32),
                  _buildHeadlineArea(context),
                  const SizedBox(height: 32),
                  _buildCountdown(context),
                  const SizedBox(height: 32),
                  _buildPrimaryActions(context),
                  const SizedBox(height: 24),
                  _buildTertiaryAction(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundAesthetics(BuildContext context) {
    return Positioned(
      top: 100,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.2),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.2),
                blurRadius: 100,
                spreadRadius: 50,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVisualAnchor(BuildContext context) {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.surfaceContainer,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 32,
                  offset: const Offset(0, 16),
                )
              ],
              image: const DecorationImage(
                image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuB9WYUi9wf6-6c_NMq3CBgzsZIrGzE_RLIUKzkLxwMhD-Xjoa8Y7-XKM4r2iMMKGs7rzxX5PxUko7lTp7-YO4pkehZ6iLX7WuXo9JvRvFKhbMQevytSmveMv_KNP64bTwzuy5wsKOpb2Q5BpruSPU3jEoYuvmrnsSK-_yTwd1skuTsGeoTbQMh7YqRCPVKi4zLG78YVkRDnImq8Y6RiDk_379O__g6OJ4CZ0X_smaeatoo6JIk-aAlNhPgeRtPk0YmEuobZGFS55w'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            bottom: -8,
            right: -8,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Icon(Icons.medical_services_rounded, color: Theme.of(context).colorScheme.onSecondary, size: 28),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeadlineArea(BuildContext context) {
    return Column(
      children: [
        Text(
          'Time to take',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Metformin 500mg',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.primary,
                height: 1.1,
              ),
        ),
        const SizedBox(height: 16),
        Text(
          'Take 1 tablet with a full glass of water.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  Widget _buildCountdown(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            'SCHEDULED FOR',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '08:00',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 64,
                      letterSpacing: -2,
                    ),
              ),
              const SizedBox(width: 4),
              Text(
                'AM',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.alarm_rounded, color: Theme.of(context).colorScheme.onErrorContainer, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Due in 5 minutes',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onErrorContainer,
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

  Widget _buildPrimaryActions(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _isSaving ? null : () => _logMedicine('manual'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(0),
            backgroundColor: Colors.transparent,
            elevation: 8,
            shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Container(
            height: 96,
            padding: const EdgeInsets.symmetric(horizontal: 32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primaryContainer],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mark as Done',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Icon(Icons.check_circle_rounded, color: Theme.of(context).colorScheme.onPrimary, size: 40),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _isSaving ? null : () async {
            final ImagePicker picker = ImagePicker();
            final XFile? photo = await picker.pickImage(
              source: (!kIsWeb && Platform.isWindows) ? ImageSource.gallery : ImageSource.camera,
              imageQuality: 50,
            );
            if (photo != null) {
              _logMedicine('photo');
            }
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(0),
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Container(
            height: 96,
            padding: const EdgeInsets.symmetric(horizontal: 32),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Take Photo Confirmation',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Icon(Icons.photo_camera_rounded, color: Theme.of(context).colorScheme.primary, size: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTertiaryAction(BuildContext context) {
    return Center(
      child: TextButton.icon(
        onPressed: () {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Snoozed for 15 minutes.')));
        },
        icon: Icon(Icons.snooze_rounded, color: Theme.of(context).colorScheme.tertiary),
        label: Text(
          'Remind in 15 mins',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.tertiary,
                fontWeight: FontWeight.bold,
              ),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        ),
      ),
    );
  }
}
