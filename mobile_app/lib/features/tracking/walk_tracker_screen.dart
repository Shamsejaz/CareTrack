import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../dashboard/providers/dashboard_provider.dart';
import '../../core/providers/auth_provider.dart';

class WalkTrackerScreen extends ConsumerWidget {
  const WalkTrackerScreen({super.key});

  Future<void> _logWalk(BuildContext context, WidgetRef ref) async {
    try {
      final supabase = ref.read(supabaseProvider);
      final user = ref.read(currentUserProvider);
      
      if (user == null) throw Exception('User not authenticated');

      await supabase.from('health_logs').insert({
        'patient_id': user.id,
        'log_type': 'Walk',
        'value': '1500', // Mock data for now
        'manual_confirm': true,
      });

      ref.invalidate(dashboardDataProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Walk saved to Supabase!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error logging walk: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Activity Tracker')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildStats(context),
              const SizedBox(height: 48),
              _buildSyncOptions(context),
              const Spacer(),
              ElevatedButton(
                onPressed: () => _logWalk(context, ref),
                child: const Text('Confirm & Log Action'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStats(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.directions_walk_rounded, size: 80, color: Colors.blue),
        ),
        const SizedBox(height: 40),
        Text(
          'Today\'s Steps',
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          '3,450 / 5,000',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.blue),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSyncOptions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('How to update your progress:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 16),
        ListTile(
          leading: const Icon(Icons.sync_rounded),
          title: const Text('Sync with Google Fit / Health'),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () {},
          tileColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade300)),
        ),
        const SizedBox(height: 16),
        ListTile(
          leading: const Icon(Icons.camera_alt_rounded),
          title: const Text('Upload Pedometer Photo'),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () {},
          tileColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade300)),
        ),
      ],
    );
  }
}
