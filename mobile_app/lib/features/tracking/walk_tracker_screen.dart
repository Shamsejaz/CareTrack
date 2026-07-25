import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../dashboard/providers/dashboard_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/health_service.dart';

class WalkTrackerScreen extends ConsumerStatefulWidget {
  const WalkTrackerScreen({super.key});

  @override
  ConsumerState<WalkTrackerScreen> createState() => _WalkTrackerScreenState();
}

class _WalkTrackerScreenState extends ConsumerState<WalkTrackerScreen> {
  final TextEditingController _stepsController = TextEditingController();
  bool _isSyncing = false;

  Future<void> _syncHealthData() async {
    setState(() => _isSyncing = true);
    
    final steps = await HealthService.getTodaySteps();
    
    if (mounted) {
      setState(() {
        _isSyncing = false;
        if (steps > 0) {
          _stepsController.text = steps.toString();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Synced $steps steps from Health Connect / Apple Health!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No steps found or permissions not granted.')),
          );
        }
      });
    }
  }

  Future<void> _logWalk(BuildContext context) async {
    final stepsStr = _stepsController.text.trim();
    if (stepsStr.isEmpty) return;
    
    try {
      final supabase = ref.read(supabaseProvider);
      final user = ref.read(currentUserProvider);
      
      if (user == null) throw Exception('User not authenticated');

      await supabase.from('health_logs').insert({
        'patient_id': user.id,
        'log_type': 'Walk',
        'value': stepsStr,
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
  void dispose() {
    _stepsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              TextField(
                controller: _stepsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Steps taken',
                  hintText: 'e.g. 2000',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _logWalk(context),
                child: const Text('Confirm & Log Action'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStats(BuildContext context) {
    final dashDataAsync = ref.watch(dashboardDataProvider);
    final dashData = dashDataAsync.value;
    final currentSteps = dashData?['steps']?['current'] ?? 0;
    final goalSteps = dashData?['steps']?['goal'] ?? 5000;

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
          '${currentSteps.toString().replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), ',')} / ${goalSteps.toString().replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), ',')}',
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
          trailing: _isSyncing 
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.chevron_right_rounded),
          onTap: _isSyncing ? null : _syncHealthData,
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
