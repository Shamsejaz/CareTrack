import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Pricing Plans'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            children: [
              Text(
                'Simple pricing. Real care.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                'Start free. Upgrade when you\'re ready for AI superpowers and family-level care.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 48),
              _buildPlanCard(
                context,
                title: 'Free',
                price: '\$0',
                period: 'forever',
                description: 'Manual tracking for individuals getting started.',
                buttonText: 'Get Started',
                features: [
                  'Manual medicine tracking',
                  'Basic reminders',
                  '1 user',
                  'Health log',
                ],
                isPopular: false,
              ),
              const SizedBox(height: 24),
              _buildPlanCard(
                context,
                title: 'Premium',
                price: '\$9',
                period: '/month',
                description: 'AI-powered care for one person.',
                buttonText: 'Start 14-day Trial',
                features: [
                  'Everything in Free',
                  'Prescription AI & OCR',
                  'Smart adaptive reminders',
                  'Food photo analysis',
                  'Health insights & reports',
                ],
                isPopular: true,
              ),
              const SizedBox(height: 24),
              _buildPlanCard(
                context,
                title: 'Family',
                price: '\$19',
                period: '/month',
                description: 'For caregivers looking after loved ones.',
                buttonText: 'Start Family Plan',
                features: [
                  'Everything in Premium',
                  'Up to 5 users',
                  'Real-time caregiver alerts',
                  'Remote monitoring dashboard',
                  'Priority support',
                ],
                isPopular: false,
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context, {
    required String title,
    required String price,
    required String period,
    required String description,
    required String buttonText,
    required List<String> features,
    required bool isPopular,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: isPopular ? const Color(0xFF1E3A8A) : colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isPopular ? Colors.transparent : colorScheme.outlineVariant,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          if (isPopular)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE4C4),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star_rounded, size: 14, color: Color(0xFF934B00)),
                    SizedBox(width: 4),
                    Text(
                      'Most Popular',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF934B00),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isPopular ? Colors.white : colorScheme.onSurface,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isPopular ? Colors.white70 : colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      price,
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: isPopular ? Colors.white : colorScheme.onSurface,
                          ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      period,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: isPopular ? Colors.white70 : colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isPopular ? const Color(0xFFFFE4C4) : colorScheme.surfaceContainerHigh,
                      foregroundColor: isPopular ? const Color(0xFF1E3A8A) : colorScheme.onSurface,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(buttonText, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 32),
                ...features.map((feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_rounded,
                            size: 18,
                            color: isPopular ? Colors.white70 : colorScheme.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              feature,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: isPopular ? Colors.white70 : colorScheme.onSurface,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
