import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SugarAiAlertScreen extends StatelessWidget {
  final int sugarValue;
  const SugarAiAlertScreen({super.key, required this.sugarValue});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCriticalVitalBlock(context),
              const SizedBox(height: 24),
              _buildDoctorContact(context),
              const SizedBox(height: 32),
              _buildAiNarrative(context),
              const SizedBox(height: 24),
              _buildActionableStepsGrid(context),
              const SizedBox(height: 48),
              _buildConfirmButton(context),
              const SizedBox(height: 48),
              _buildTrendVisualization(context),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.95),
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

  Widget _buildCriticalVitalBlock(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff191c1d).withOpacity(0.06),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'CRITICAL ALERT',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
          ),
          const SizedBox(height: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                      blurRadius: 40,
                      spreadRadius: 20,
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    sugarValue.toString(),
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 80,
                          height: 1.0,
                          letterSpacing: -2,
                        ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'mg/dL',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.error,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'High',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onError,
                  ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Measured 2 mins ago via Manual Input',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorContact(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onTertiaryContainer.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.medical_services_rounded, color: Theme.of(context).colorScheme.onTertiaryContainer, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Contact Doctor',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onTertiaryContainer,
                      ),
                ),
                Text(
                  'Immediate advice recommended if levels persist above 200.',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onTertiaryContainer.withOpacity(0.9),
                      ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onTertiaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.call_rounded, color: Theme.of(context).colorScheme.tertiaryContainer, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildAiNarrative(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sugar AI Analysis',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                '"Your current blood glucose level is significantly elevated. This requires immediate corrective action to ensure your safety and comfort."',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLowest.withOpacity(0.6),
                  borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  border: Border(
                    left: BorderSide(color: Theme.of(context).colorScheme.error, width: 4),
                  ),
                ),
                child: Text(
                  'Drink water, take your prescribed insulin, and avoid sugary snacks. Contact your doctor if it stays above 200.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
              ),
            ],
          ),
          Positioned(
            top: -20,
            right: -20,
            child: Icon(
              Icons.psychology_rounded,
              size: 100,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionableStepsGrid(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStepCard(
                context,
                title: 'Hydrate Now',
                sub: 'Drink 16oz of water to help your kidneys flush excess glucose.',
                icon: Icons.water_drop_rounded,
                iconColor: Colors.blue.shade700,
                bgColor: Colors.blue.shade100,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStepCard(
                context,
                title: 'Administer Insulin',
                sub: 'Check your sliding scale for your corrective dose.',
                icon: Icons.medication_rounded,
                iconColor: Theme.of(context).colorScheme.error,
                bgColor: Theme.of(context).colorScheme.errorContainer,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStepCard(
                context,
                title: 'Zero Sugar',
                sub: 'Avoid snacks for the next 2 hours. Rest and monitor.',
                icon: Icons.block_rounded,
                iconColor: Theme.of(context).colorScheme.onSecondaryContainer,
                bgColor: Theme.of(context).colorScheme.secondaryContainer,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStepCard(
                context,
                title: 'Recheck in 30m',
                sub: 'We\'ll alert you to test again shortly.',
                icon: Icons.timer_rounded,
                iconColor: Theme.of(context).colorScheme.onTertiaryContainer, // tertiary-fixed-variant equivalent
                bgColor: Theme.of(context).colorScheme.tertiaryContainer.withOpacity(0.2),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStepCard(BuildContext context, {
    required String title,
    required String sub,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            sub,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async {
        final user = Supabase.instance.client.auth.currentUser;
        if (user != null) {
          try {
            await Supabase.instance.client.from('notifications').insert({
              'patient_id': user.id,
              'type': 'high_sugar',
              'message': 'Critical Sugar Alert: $sugarValue mg/dL detected.',
            });
          } catch (e) {
            debugPrint('Failed to send caregiver notification: $e');
          }
        }
        
        if (context.mounted) {
          context.pop(); // Go back to dashboard or home
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Action confirmed. Caregiver notified!')),
          );
        }
      },

      icon: const Icon(Icons.check_circle_rounded),
      label: const Text('I Have Followed These Steps'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 24),
        backgroundColor: Theme.of(context).colorScheme.error,
        foregroundColor: Theme.of(context).colorScheme.onError,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        elevation: 8,
        shadowColor: Theme.of(context).colorScheme.error.withOpacity(0.5),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTrendVisualization(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Last 4 Hours',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 300,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Stack(
            children: [
              // Trend bars
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      height: 64,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary.withOpacity(0.4),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary.withOpacity(0.4),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 128,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.tertiary.withOpacity(0.6),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Stack(
                      alignment: Alignment.topCenter,
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          height: 224,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.error,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).colorScheme.error.withOpacity(0.4),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: -30,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.error,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'NOW',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onError,
                                  ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              
              // Guide Lines
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildGuideLine(context, 'CRITICAL (200)', Theme.of(context).colorScheme.error),
                  _buildGuideLine(context, 'NORMAL (120)', Theme.of(context).colorScheme.onSurfaceVariant),
                  _buildGuideLine(context, '80', Theme.of(context).colorScheme.onSurfaceVariant),
                ],
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _buildGuideLine(BuildContext context, String label, Color color) {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: color.withOpacity(0.2))),
      ),
      child: Align(
        alignment: Alignment.topRight,
        child: Container(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          transform: Matrix4.translationValues(0, -10, 0), // Shift up to align
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 10,
                ),
          ),
        ),
      ),
    );
  }
}
