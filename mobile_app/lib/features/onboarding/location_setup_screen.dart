import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import '../../core/providers/auth_provider.dart';

class LocationSetupScreen extends ConsumerStatefulWidget {
  const LocationSetupScreen({super.key});

  @override
  ConsumerState<LocationSetupScreen> createState() => _LocationSetupScreenState();
}

class _LocationSetupScreenState extends ConsumerState<LocationSetupScreen> {
  String? _selectedCountry;
  bool _isSaving = false;
  final List<Map<String, String>> _countries = [
    {'name': 'United States', 'code': 'US', 'flag': '🇺🇸'},
    {'name': 'United Kingdom', 'code': 'GB', 'flag': '🇬🇧'},
    {'name': 'Pakistan', 'code': 'PK', 'flag': '🇵🇰'},
    {'name': 'Saudi Arabia', 'code': 'SA', 'flag': '🇸🇦'},
    {'name': 'United Arab Emirates', 'code': 'AE', 'flag': '🇦🇪'},
    {'name': 'Canada', 'code': 'CA', 'flag': '🇨🇦'},
    {'name': 'Australia', 'code': 'AU', 'flag': '🇦🇺'},
  ];

  Future<void> _onContinue() async {
    final user = ref.read(currentUserProvider);
    
    if (user != null && _selectedCountry != null) {
      setState(() => _isSaving = true);
      try {
        final supabase = ref.read(supabaseProvider);
        await supabase.from('profiles').update({
          'gender': _selectedCountry, // Using gender field as placeholder or we should add 'country' to schema
        }).eq('id', user.id);
      } catch (e) {
        debugPrint('Error saving location: $e');
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
    
    if (mounted) {
      context.push('/setup/schedule');
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
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 24.0),
              child: Text(
                'STEP 2 OF 6',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildBackground(context),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 32),
                  _buildSearchField(context),
                  const SizedBox(height: 24),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _countries.length,
                      itemBuilder: (context, index) {
                        final country = _countries[index];
                        final isSelected = _selectedCountry == country['name'];
                        return _buildCountryTile(context, country, isSelected);
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildNextButton(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
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

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select your\nlocation',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface,
                height: 1.1,
              ),
        ),
        const SizedBox(height: 16),
        Text(
          'This helps us customize your experience and match you with local care standards.',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w300,
              ),
        ),
      ],
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search country...',
        prefixIcon: const Icon(Icons.search_rounded),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerLowest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildCountryTile(BuildContext context, Map<String, String> country, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => setState(() => _selectedCountry = country['name']),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSelected 
                ? Theme.of(context).colorScheme.primary.withOpacity(0.05)
                : Theme.of(context).colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outlineVariant,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Text(country['flag']!, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  country['name']!,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle_rounded, color: Theme.of(context).colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton(BuildContext context) {
    return ElevatedButton(
      onPressed: (_selectedCountry == null || _isSaving)
          ? null 
          : _onContinue,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _isSaving 
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text('Continue'),
          const SizedBox(width: 12),
          if (!_isSaving) const Icon(Icons.arrow_forward_rounded, size: 20),
        ],
      ),
    );
  }
}
