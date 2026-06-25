import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/auth_provider.dart';
import 'dart:ui';

class ConditionsSetupScreen extends ConsumerStatefulWidget {
  const ConditionsSetupScreen({super.key});

  @override
  ConsumerState<ConditionsSetupScreen> createState() => _ConditionsSetupScreenState();
}

class _ConditionsSetupScreenState extends ConsumerState<ConditionsSetupScreen> {
  final Set<String> _selectedConditions = {};
  bool _isLoading = false;

  final List<Map<String, dynamic>> _conditions = [
    {
      'id': 'diabetes',
      'title': 'Diabetes',
      'desc': 'Blood sugar tracking and insulin reminders.',
      'icon': Icons.water_drop_rounded,
    },
    {
      'id': 'blood_pressure',
      'title': 'Blood Pressure',
      'desc': 'Hypertension monitoring and trend analysis.',
      'icon': Icons.monitor_heart_rounded,
    },
    {
      'id': 'heart_health',
      'title': 'Heart Health',
      'desc': 'Pulse rate, cardio activity, and cardiac risk assessment.',
      'icon': Icons.favorite_rounded,
    },
    {
      'id': 'weight',
      'title': 'Weight',
      'desc': 'BMI management, nutrition logs, and weight goals.',
      'icon': Icons.scale_rounded,
    },
    {
      'id': 'sleep',
      'title': 'Sleep',
      'desc': 'Sleep cycles, insomnia tracking, and rest quality.',
      'icon': Icons.bedtime_rounded,
    },
    {
      'id': 'stress',
      'title': 'Stress',
      'desc': 'Mental wellness, cortisol logs, and breathing exercises.',
      'icon': Icons.psychology_rounded,
    },
  ];

  Future<void> _saveConditions() async {
    if (_selectedConditions.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final user = ref.read(currentUserProvider);
      if (user != null) {
        final supabase = ref.read(supabaseProvider);
        await supabase.from('profiles').upsert({
          'id': user.id,
          'conditions': _selectedConditions.toList(),
        });
      }
      
      if (mounted) {
        // According to the new task structure, we should go to Daily Schedule instead of prescriptions
        // We'll update the router next
        context.push('/setup/schedule'); // assuming new route
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save conditions: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          _buildBackgroundGrids(context),
          SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.only(left: 24, right: 24, top: 32, bottom: 120),
              children: [
                _buildHeaderTexts(context),
                const SizedBox(height: 32),
                _buildConditionsGrid(context),
                const SizedBox(height: 48),
                _buildEditorialQuote(context),
              ],
            ),
          ),
          _buildBottomBar(context),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      leading: context.canPop() 
        ? IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: Theme.of(context).colorScheme.primaryContainer),
            onPressed: () => context.pop(),
          )
        : null,
      title: Text(
        'CareTrack',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
      actions: [
        Center(
          child: Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: Text(
              'Step 4 of 6',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBackgroundGrids(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 300,
              height: 400,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              width: 250,
              height: 300,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  colors: [
                    Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
            child: Container(color: Colors.transparent),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderTexts(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What should we help you manage?',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface,
                height: 1.1,
              ),
        ),
        const SizedBox(height: 16),
        Text(
          'Select one or more areas of focus for your personalized care journey.',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  Widget _buildConditionsGrid(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch, // Ensure cards fill the width
      children: _conditions.map((condition) {
        final isSelected = _selectedConditions.contains(condition['id']);
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildConditionCard(context, condition, isSelected),
        );
      }).toList(),
    );
  }

  Widget _buildConditionCard(BuildContext context, Map<String, dynamic> condition, bool isSelected) {
    final colors = [
      Theme.of(context).colorScheme.primary,
      Theme.of(context).colorScheme.secondary,
      Theme.of(context).colorScheme.tertiary,
      Theme.of(context).colorScheme.onSurfaceVariant,
      Theme.of(context).colorScheme.primary,
      Theme.of(context).colorScheme.onPrimaryContainer,
    ];
    final bgColors = [
      Theme.of(context).colorScheme.primary.withOpacity(0.1),
      Theme.of(context).colorScheme.secondary.withOpacity(0.1),
      Theme.of(context).colorScheme.tertiary.withOpacity(0.1),
      Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.1),
      Theme.of(context).colorScheme.primary.withOpacity(0.1),
      Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.1),
    ];
    
    int cIndex = _conditions.indexOf(condition);

    return InkWell(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedConditions.remove(condition['id']);
          } else {
            _selectedConditions.add(condition['id']);
          }
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.primaryContainer : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xff191c1d).withOpacity(isSelected ? 0.12 : 0.06),
              offset: Offset(0, isSelected ? 16 : 12),
              blurRadius: isSelected ? 48 : 32,
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: bgColors[cIndex],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(condition['icon'], color: colors[cIndex], size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            condition['title'],
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            condition['desc'],
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (isSelected)
              Positioned(
                top: 0,
                right: 0,
                child: Icon(
                  Icons.check_circle_rounded,
                  color: Theme.of(context).colorScheme.secondary,
                  size: 28,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditorialQuote(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: Theme.of(context).colorScheme.primary, width: 4),
        ),
      ),
      child: Text(
        '"Dignity is not a feature; it\'s the foundation of every heartbeat we track."',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.2),
                ),
              ),
            ),
            child: ElevatedButton(
              onPressed: _selectedConditions.isEmpty || _isLoading ? null : _saveConditions,
              child: _isLoading 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Next Step'),
                  SizedBox(width: 12),
                  Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
