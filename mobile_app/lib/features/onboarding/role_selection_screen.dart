import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import '../../core/providers/auth_provider.dart';

class RoleSelectionScreen extends ConsumerWidget {
  const RoleSelectionScreen({super.key});

  Future<void> _selectRole(WidgetRef ref, BuildContext context, String role) async {
    final user = ref.read(currentUserProvider);
    
    if (user != null) {
      try {
        final supabase = ref.read(supabaseProvider);
        await supabase.from('profiles').update({
          'role': role,
        }).eq('id', user.id);
      } catch (e) {
        debugPrint('Error saving role: $e');
      }
    }
    
    if (context.mounted) {
      context.push('/setup/conditions');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          _buildBackgroundGrids(context),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    children: [
                      _buildHeaderTexts(context),
                      const SizedBox(height: 48),
                      // Role Cards
                      _buildRoleCard(
                        context,
                        title: 'I am a Patient',
                        description: 'I want to track my health, manage my meds, and see my progress.',
                        icon: Icons.person_rounded,
                        baseColor: Theme.of(context).colorScheme.primary,
                        fixedColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2), 
                        onTap: () => _selectRole(ref, context, 'patient'),
                      ),
                      const SizedBox(height: 24),
                      _buildRoleCard(
                        context,
                        title: 'I am a Caregiver',
                        description: 'I am helping a loved one stay on track with their wellness goals.',
                        icon: Icons.volunteer_activism_rounded,
                        baseColor: Theme.of(context).colorScheme.secondary,
                        fixedColor: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.3), 
                        onTap: () => _selectRole(ref, context, 'caregiver'),
                      ),
                      const SizedBox(height: 64),
                      _buildProgressBar(context),
                    ],
                  ),
                ),
                _buildFooter(context),
              ],
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
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => context.pop(),
      ),
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
              'Step 2 of 5',
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
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
            child: Container(color: Colors.transparent),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderTexts(BuildContext context) {
    return Column(
      children: [
        Text(
          'Who will be using this app?',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface,
                height: 1.2,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'We\'ll customize your experience based on how you plan to use CareTrack.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color baseColor,
    required Color fixedColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xff191c1d).withOpacity(0.06),
              offset: const Offset(0, 12),
              blurRadius: 32,
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: fixedColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: baseColor),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Get started',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: baseColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 16, color: baseColor),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 150,
        child: LinearProgressIndicator(
          value: 3/6,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
          minHeight: 6,
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Already have an account? ',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          InkWell(
            onTap: () => context.go('/login'),
            child: Text(
              'Log in',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
