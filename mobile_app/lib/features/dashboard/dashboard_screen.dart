import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/bento_card.dart';
import '../../core/widgets/custom_bottom_nav.dart';
import 'providers/dashboard_provider.dart';
import '../profile/providers/profile_provider.dart';
import 'dart:math';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardDataAsync = ref.watch(dashboardDataProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: _buildAppBar(context, ref),
      body: dashboardDataAsync.when(
        data: (data) => _buildBody(context, ref, data),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 0),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final avatarUrl = profileAsync.value?['avatar_url'];

    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.95),
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_rounded, color: Theme.of(context).colorScheme.primaryContainer),
        onPressed: () {},
      ),
      title: Text(
        'CareTrack',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () => context.push('/profile'),
          child: Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
              backgroundImage: avatarUrl != null
                  ? NetworkImage(avatarUrl)
                  : const NetworkImage('https://i.pravatar.cc/150?u=placeholder'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, Map data) {
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
        children: [
          _buildHeroGreeting(context, ref),
          const SizedBox(height: 32),
          _buildVitalsGrid(context, data),
          const SizedBox(height: 48),
          _buildQuickActions(context),
          const SizedBox(height: 48),
          _buildCaregiverNote(context),
        ],
      ),
    );
  }

  Widget _buildHeroGreeting(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final fullName = profileAsync.value?['full_name'] ?? 'User';
    final firstName = fullName.split(' ').first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Good Morning, $firstName.',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface,
                height: 1.1,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'You\'re doing great today. Here\'s your health snapshot.',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  Widget _buildVitalsGrid(BuildContext context, Map data) {
    final sugar = data['sugar'] ?? {};
    final steps = data['steps'] ?? {};
    final water = data['water'] ?? {};
    
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _buildSugarStatus(context, sugar)),
              const SizedBox(width: 16),
              Expanded(child: _buildMedicinesStatus(context)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _buildStepsStatus(context, steps)),
              const SizedBox(width: 16),
              Expanded(child: _buildWaterStatus(context, water)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSugarStatus(BuildContext context, Map sugar) {
    final reading = sugar['lastReading']?.toString() ?? '--';
    final status = sugar['status'] ?? 'Normal';
    
    return BentoCard(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'SUGAR STATUS',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          letterSpacing: 2,
                        ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.water_drop_rounded, color: Theme.of(context).colorScheme.tertiary, size: 20),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  status,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: status.toLowerCase() == 'high' ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.secondary,
                      ),
                ),
              ),
              Text(
                '$reading mg/dL',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: 0.65,
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(12),
                  minHeight: 8,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '2h ago',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMedicinesStatus(BuildContext context) {
    return BentoCard(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'MEDICINES',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          letterSpacing: 2,
                        ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.medication_rounded, color: Theme.of(context).colorScheme.primary, size: 20),
            ],
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '2',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                Text(
                  '/5',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w300,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: List.generate(5, (index) {
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: index < 4 ? 4 : 0),
                      height: 12,
                      decoration: BoxDecoration(
                        color: index < 2 ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 12),
              Text(
                'Next: Blood Pressure at 1PM',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepsStatus(BuildContext context, Map steps) {
    final currentSteps = steps['current'] ?? 0;
    final goalSteps = steps['goal'] ?? 5000;
    final progress = currentSteps / goalSteps;

    return BentoCard(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress > 1 ? 1.0 : progress.toDouble(),
                  strokeWidth: 8,
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                Icon(Icons.directions_walk_rounded, color: Theme.of(context).colorScheme.secondary, size: 32),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: FittedBox(
                    alignment: Alignment.centerLeft,
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'STEPS',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            letterSpacing: 2,
                          ),
                    ),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '$currentSteps',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                    maxLines: 1,
                  ),
                ),
                Text(
                  'Goal: $goalSteps',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaterStatus(BuildContext context, Map water) {
    final glasses = water['glasses'] ?? 0;
    return BentoCard(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 90,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                FractionallySizedBox(
                  heightFactor: (glasses / 8).clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.tertiary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                Center(
                  child: Icon(Icons.local_drink_rounded, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2), size: 32),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: FittedBox(
                    alignment: Alignment.centerLeft,
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'HYDRATION',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            letterSpacing: 2,
                          ),
                    ),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '$glasses',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                      Text(
                        '/8',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w300,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Glasses',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What would you like to do?',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        const SizedBox(height: 24),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.8,
          children: [
            _buildActionBtn(context, 'Check Sugar', Icons.water_drop_rounded, Theme.of(context).colorScheme.errorContainer, Theme.of(context).colorScheme.onErrorContainer, '/track/sugar'),
            _buildActionBtn(context, 'Log Meal', Icons.restaurant_rounded, const Color(0xffffeed9), const Color(0xff934b00), '/track/meal'),
            _buildActionBtn(context, 'Medicine', Icons.medication_rounded, Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2), Theme.of(context).colorScheme.primaryContainer, '/track/medicine'),
            _buildActionBtn(context, 'Drink Water', Icons.local_drink_rounded, Theme.of(context).colorScheme.tertiaryContainer.withOpacity(0.2), Theme.of(context).colorScheme.tertiary, '/track/water'),
            _buildActionBtn(context, 'Start Walk', Icons.directions_walk_rounded, Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.3), Theme.of(context).colorScheme.secondary, '/track/walk'),
          ],
        ),
      ],
    );
  }

  Widget _buildActionBtn(BuildContext context, String label, IconData icon, Color bgColor, Color fgColor, String route) {
    return InkWell(
      onTap: () => context.push(route),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28, color: fgColor),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: fgColor,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaregiverNote(BuildContext context) {
    return Column(
      children: [
        const Divider(),
        const SizedBox(height: 32),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.stars_rounded, size: 16, color: Theme.of(context).colorScheme.onSecondaryContainer),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Insight from Nurse Sarah',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Your activity levels are up by 15% this week. This is helping stabilize your afternoon sugar levels significantly.',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Keep up the morning walks around the garden. Consistency is your greatest medicine right now, Ali.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 2,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.network(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuAzA5x5N1ycbVP9ZsmOsmj5kqN2Xuc3KyHU8ttozVB5xl719I8gWWuLEMLkUHL2s5w2gArUA021NXLTqvkdOSfpYhK_uQtNC4de2yKVY6Y8Z7qA0iFwcnZQnVtCYDdVYhAvne0yWCsrPCZuT37-T9NTPFG_ilAmrGC7cMCsh6rWMejIMTUt9sxCw7dYj0njE1GUvcVt8aJZdt9AlPjCe3TMIM3VF_O5agligikIPsT55QhKtmXv_S_nk9QzWAcKPXv4YtZ_KRK1Aw',
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

