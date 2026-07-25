import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/bento_card.dart';
import '../../core/widgets/custom_bottom_nav.dart';
import 'providers/dashboard_provider.dart';
import '../profile/providers/profile_provider.dart';
import '../../core/utils/error_handler.dart';
import '../../core/providers/auth_provider.dart';
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
      bottomNavigationBar: dashboardDataAsync.when(
        data: (data) => data['isCaregiver'] == true
            ? const SizedBox.shrink()
            : const CustomBottomNav(currentIndex: 0),
        loading: () => const SizedBox.shrink(),
        error: (err, stack) => const SizedBox.shrink(),
      ),
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
    if (data['isCaregiver'] == true) {
      return _buildCaregiverDashboard(context, ref, data);
    }

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

  Widget _buildCaregiverDashboard(BuildContext context, WidgetRef ref, Map data) {
    final List patients = data['patients'] ?? [];
    final int pendingAlerts = data['pendingAlerts'] ?? 0;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Clinical Overview',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Real-time patient diagnostics and care portal',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          // Stats Row
          Row(
            children: [
              Expanded(
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Patients', style: TextStyle(color: Colors.grey, fontSize: 14)),
                            Icon(Icons.people_rounded, color: Theme.of(context).colorScheme.primary),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${patients.length}',
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        const Text('Active Monitored', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: pendingAlerts > 0
                        ? const BorderSide(color: Color(0xFFD32F2F), width: 1.5)
                        : BorderSide.none,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Pending Alerts', style: TextStyle(color: Colors.grey, fontSize: 14)),
                            Icon(
                              Icons.warning_amber_rounded,
                              color: pendingAlerts > 0 ? const Color(0xFFD32F2F) : Colors.orange,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '$pendingAlerts',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: pendingAlerts > 0 ? const Color(0xFFD32F2F) : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          pendingAlerts > 0 ? 'Action Required' : 'All Clear',
                          style: TextStyle(
                            color: pendingAlerts > 0 ? const Color(0xFFD32F2F) : Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Linked Patients Directory',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: () => _showAddPatientDialog(context, ref),
                icon: const Icon(Icons.add_circle_outline_rounded),
                label: const Text('Add Patient'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (patients.isEmpty)
            Card(
              elevation: 0,
              color: Colors.grey.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 48.0, horizontal: 24),
                child: Column(
                  children: [
                    const Icon(Icons.person_add_disabled_rounded, size: 48, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'No patients linked yet.',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please click "Add Patient" and type the 6-digit patient code to begin monitoring.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: patients.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final patient = patients[index];
                final patientId = patient['id'];
                final fullName = patient['full_name'] ?? 'Anonymous Patient';
                final List conditions = patient['conditions'] ?? [];
                final latestLog = patient['latest_log'];
                
                String latestVitalsText = 'No readings logged today.';
                if (latestLog != null) {
                  final logType = latestLog['log_type'] ?? '';
                  final val = latestLog['value'] ?? '';
                  latestVitalsText = 'Latest: $val ($logType)';
                }

                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                              child: Text(
                                fullName[0].toUpperCase(),
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    fullName,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    latestVitalsText,
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        // Conditions Chips
                        if (conditions.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: conditions.map((c) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.indigo.shade50,
                                  borderRadius: BorderRadius.circular(9999),
                                ),
                                child: Text(
                                  c.toString(),
                                  style: TextStyle(color: Colors.indigo.shade700, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                        
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 8),
                        
                        // Action row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () => context.push('/chat/$patientId'),
                              icon: Icon(Icons.chat_bubble_outline_rounded, size: 18, color: Theme.of(context).colorScheme.primary),
                              label: const Text('Open Chat'),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              onPressed: () => _showPatientHistorySheet(context, ref, patientId, fullName),
                              icon: const Icon(Icons.history_toggle_off_rounded, size: 18),
                              label: const Text('View History'),
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Future<void> _showAddPatientDialog(BuildContext context, WidgetRef ref) async {
    final codeController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Link New Patient'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Enter the 6-digit invitation code generated by the patient on their mobile app.',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: codeController,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 8,
                    ),
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      hintText: '000000',
                      border: OutlineInputBorder(),
                      counterText: '',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          final code = codeController.text.trim();
                          if (code.length != 6) {
                            showErrorSnackBar(context, 'Validation failed', Exception('Please enter a 6-digit code.'));
                            return;
                          }

                          setState(() => isSubmitting = true);

                          try {
                            final supabase = ref.read(supabaseProvider);
                            final user = ref.read(currentUserProvider);

                            if (user == null) throw Exception('Caregiver not authenticated');

                            // 1. Fetch invitation code details
                            final codeResponse = await supabase
                                .from('invitation_codes')
                                .select('*')
                                .eq('code', code)
                                .maybeSingle();

                            if (codeResponse == null) {
                              throw Exception('Invalid or expired invitation code.');
                            }

                            // Check expiration
                            final expiresAt = DateTime.parse(codeResponse['expires_at']);
                            if (expiresAt.isBefore(DateTime.now())) {
                              throw Exception('This invitation code has expired.');
                            }

                            final patientId = codeResponse['patient_id'];

                            // 2. Check if already linked
                            final existingLink = await supabase
                                .from('care_links')
                                .select('*')
                                .eq('patient_id', patientId)
                                .eq('caregiver_id', user.id)
                                .maybeSingle();

                            if (existingLink != null) {
                              throw Exception('This patient is already linked to your profile.');
                            }

                            // 3. Create care link
                            await supabase.from('care_links').insert({
                              'patient_id': patientId,
                              'caregiver_id': user.id,
                              'role': 'caregiver',
                              'status': 'active',
                            });

                            // 4. Delete the used code
                            await supabase
                                .from('invitation_codes')
                                .delete()
                                .eq('code', code);

                            if (dialogContext.mounted) {
                              Navigator.pop(dialogContext);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Patient linked successfully!')),
                              );
                              ref.invalidate(dashboardDataProvider);
                            }
                          } catch (e) {
                            if (dialogContext.mounted) {
                              showErrorSnackBar(context, 'Linking failed', e);
                            }
                          } finally {
                            setState(() => isSubmitting = false);
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Link Patient'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showPatientHistorySheet(BuildContext context, WidgetRef ref, String patientId, String patientName) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: () async {
            final supabase = ref.read(supabaseProvider);
            final response = await supabase
                .from('health_logs')
                .select('*')
                .eq('patient_id', patientId)
                .order('created_at', ascending: false)
                .limit(10);
            return (response as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
          }(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 300,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return Container(
                height: 300,
                padding: const EdgeInsets.all(24),
                child: Center(child: Text('Error loading history: ${snapshot.error}')),
              );
            }
            final logs = snapshot.data ?? [];
            return Container(
              padding: const EdgeInsets.all(24),
              height: 450,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '$patientName\'s History',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(sheetContext),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: logs.isEmpty
                        ? const Center(child: Text('No health readings logged yet.', style: TextStyle(color: Colors.grey)))
                        : ListView.separated(
                            itemCount: logs.length,
                            separatorBuilder: (context, index) => const Divider(),
                            itemBuilder: (context, index) {
                              final log = logs[index];
                              final logType = log['log_type'] ?? 'Log';
                              final value = log['value'] ?? 'N/A';
                              final dateStr = DateTime.parse(log['created_at'])
                                  .toLocal()
                                  .toString()
                                  .substring(5, 16); // e.g. "06-25 15:30"
                              
                              IconData typeIcon = Icons.stars_rounded;
                              Color iconColor = Colors.blue;
                              if (logType == 'Sugar') {
                                typeIcon = Icons.health_and_safety_rounded;
                                iconColor = Colors.red;
                              } else if (logType == 'Meal') {
                                typeIcon = Icons.restaurant_rounded;
                                iconColor = Colors.orange;
                              } else if (logType == 'Medicine') {
                                typeIcon = Icons.medical_services_rounded;
                                iconColor = Colors.purple;
                              } else if (logType == 'Walk') {
                                typeIcon = Icons.directions_walk_rounded;
                                iconColor = Colors.green;
                              } else if (logType == 'Water') {
                                typeIcon = Icons.water_drop_rounded;
                                iconColor = Colors.teal;
                              }

                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: iconColor.withOpacity(0.1),
                                  child: Icon(typeIcon, color: iconColor),
                                ),
                                title: Text(
                                  value,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(logType),
                                trailing: Text(
                                  dateStr,
                                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

