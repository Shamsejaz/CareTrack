import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../dashboard/providers/dashboard_provider.dart';
import '../../core/providers/auth_provider.dart';

class WaterTrackerScreen extends ConsumerStatefulWidget {
  const WaterTrackerScreen({super.key});

  @override
  ConsumerState<WaterTrackerScreen> createState() => _WaterTrackerScreenState();
}

class _WaterTrackerScreenState extends ConsumerState<WaterTrackerScreen> {
  int _glasses = 0;
  bool _isSaving = false;
  final int _goal = 8;

  void _addGlass() {
    if (_glasses < 12) {
      setState(() => _glasses++);
    }
  }

  void _removeGlass() {
    if (_glasses > 0) {
      setState(() => _glasses--);
    }
  }

  Future<void> _saveWater() async {
    setState(() => _isSaving = true);
    try {
      final supabase = ref.read(supabaseProvider);
      final user = ref.read(currentUserProvider);
      
      if (user == null) throw Exception('User not authenticated');

      await supabase.from('health_logs').insert({
        'patient_id': user.id,
        'log_type': 'Water',
        'value': '$_glasses',
        'manual_confirm': true,
      });

      ref.invalidate(dashboardDataProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Water intake saved to Supabase!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating water: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Water Intake')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildWaterRing(context),
              const SizedBox(height: 48),
              _buildControls(context),
              const Spacer(),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveWater,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan),
                child: _isSaving
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Update Daily Goal'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWaterRing(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 250,
          height: 250,
          child: CircularProgressIndicator(
            value: (_glasses / _goal).clamp(0.0, 1.0),
            strokeWidth: 24,
            backgroundColor: Colors.cyan.withOpacity(0.1),
            color: Colors.cyan,
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_drink_rounded, size: 64, color: Colors.cyan.shade600),
            const SizedBox(height: 8),
            Text(
              '$_glasses / $_goal',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.cyan.shade700),
            ),
            const Text('Glasses', style: TextStyle(color: Colors.grey, fontSize: 18)),
          ],
        ),
      ],
    );
  }

  Widget _buildControls(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FloatingActionButton.large(
          heroTag: 'minus',
          onPressed: _removeGlass,
          backgroundColor: Colors.grey.shade200,
          child: const Icon(Icons.remove_rounded, color: Colors.black54),
        ),
        const SizedBox(width: 48),
        FloatingActionButton.large(
          heroTag: 'plus',
          onPressed: _addGlass,
          backgroundColor: Colors.cyan,
          child: const Icon(Icons.add_rounded, color: Colors.white),
        ),
      ],
    );
  }
}
