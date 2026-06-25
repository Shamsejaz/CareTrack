import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/auth_provider.dart';

class PrescriptionConfirmationScreen extends ConsumerWidget {
  const PrescriptionConfirmationScreen({super.key});

  Future<void> _onConfirm(WidgetRef ref, BuildContext context) async {
    final user = ref.read(currentUserProvider);
    
    if (user != null) {
      try {
        final supabase = ref.read(supabaseProvider);
        // Save some default extracted meds as a result of the AI scan
        final meds = [
          {'patient_id': user.id, 'name': 'Metformin', 'dose': '500mg', 'timing': 'After Breakfast', 'frequency': 'Daily'},
          {'patient_id': user.id, 'name': 'Lisinopril', 'dose': '10mg', 'timing': 'Morning', 'frequency': 'Daily'},
          {'patient_id': user.id, 'name': 'Atorvastatin', 'dose': '20mg', 'timing': 'Before Bed', 'frequency': 'Nightly'},
        ];

        await supabase.from('medications').insert(meds);
      } catch (e) {
        debugPrint('Error saving medications: $e');
      }
    }
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Prescription setup completed!')));
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          _buildBackgroundAesthetics(context),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 48),
                  _buildAssistantMessage(context),
                  const SizedBox(height: 24),
                  _buildContextualCard(context),
                  const SizedBox(height: 48),
                  _buildActions(context, ref),
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
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_rounded, color: Theme.of(context).colorScheme.primaryContainer),
        onPressed: () => context.pop(),
      ),
      title: Text(
        'CareTrack',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildBackgroundAesthetics(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 100,
          right: -50,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                  blurRadius: 100,
                  spreadRadius: 50,
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PRESCRIPTION UPDATE',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Medication Check-In',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.primary,
                height: 1.1,
              ),
        ),
      ],
    );
  }

  Widget _buildAssistantMessage(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2), // primary-fixed equivalent
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.smart_toy_rounded, color: Theme.of(context).colorScheme.primary, size: 20),
            ),
            const SizedBox(width: 8),
            Text(
              'Care Assistant',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: MediaQuery.of(context).size.width * 0.8,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(24),
              bottomRight: Radius.circular(8),
              bottomLeft: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xff191c1d).withOpacity(0.06),
                blurRadius: 32,
                offset: const Offset(0, 12),
              ),
            ],
            border: Border(left: BorderSide(color: Theme.of(context).colorScheme.primary, width: 4)),
          ),
          child: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1.5,
                  ),
              children: [
                const TextSpan(text: 'Did you buy '),
                TextSpan(
                  text: 'Metformin 500mg',
                  style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                ),
                const TextSpan(text: ' from the pharmacy?'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContextualCard(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.medication_rounded, color: Theme.of(context).colorScheme.tertiary, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Metformin',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '500mg • Oral Tablet',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Refill Ready',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSecondaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Pharmacy: Central Health',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                fontStyle: FontStyle.italic,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest.withOpacity(0.8),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
            blurRadius: 48,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Please confirm your purchase',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Container(width: 48, height: 4, decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withOpacity(0.2), borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 32),
          
          ElevatedButton(
            onPressed: () => _onConfirm(ref, context),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(0), // Removed padding to use Container inside
              backgroundColor: Colors.transparent,
              elevation: 8,
              shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
            ),
            child: Container(
              height: 84,
              padding: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primaryContainer],
                ),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Yes',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                    child: const Icon(Icons.check_circle_rounded, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.go('/dashboard');
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(0), // Removed padding to use Container inside
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
            ),
            child: Container(
              height: 84,
              padding: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Not Yet',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.05), shape: BoxShape.circle),
                    child: Icon(Icons.schedule_rounded, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Confirming helps CareTrack manage your daily schedule and medication reminders.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
