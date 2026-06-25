import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/auth_provider.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Image.asset(
                'assets/images/caretrack_logo.png',
                height: 100, // Adjust height as appropriate
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),
              Text(
                'Your Smart Daily Health,\nMemory & Care Assistant',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  context.push('/setup/language');
                },
                child: const Text('Sign Up'),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  context.push('/login');
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Login', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  ref.read(isDemoProvider.notifier).state = true;
                  context.go('/dashboard');
                },
                child: const Text('Try Demo (No Login)', style: TextStyle(fontSize: 16, color: Colors.grey)),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
