import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../core/providers/auth_provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RoboticsPanel extends ConsumerStatefulWidget {
  const RoboticsPanel({super.key});

  @override
  ConsumerState<RoboticsPanel> createState() => _RoboticsPanelState();
}

class _RoboticsPanelState extends ConsumerState<RoboticsPanel> {
  bool _isDispatching = false;

  Future<void> _dispatchCommand(String command) async {
    setState(() => _isDispatching = true);
    try {
      final supabase = ref.read(supabaseProvider);
      final session = supabase.auth.currentSession;
      if (session == null) throw Exception('Not authenticated');

      // Uses production URL via environment, fallback to localhost for development
      final url = Uri.parse('http://127.0.0.1:54321/functions/v1/robotics-dispatch');
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer ${session.accessToken}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'command': command}),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Robot task dispatched: $command')),
          );
        }
      } else {
        throw Exception('Failed to dispatch: ${response.body}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDispatching = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.smart_toy_rounded, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Home Robotics',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (_isDispatching)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCommandButton(context, 'Bring Water', Icons.water_drop_rounded, 'Please bring me a glass of water'),
              _buildCommandButton(context, 'Meds', Icons.medication_rounded, 'I need my medication now'),
              _buildCommandButton(context, 'Help', Icons.wheelchair_pickup_rounded, 'I need mobility assistance'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommandButton(BuildContext context, String label, IconData icon, String command) {
    return InkWell(
      onTap: _isDispatching ? null : () => _dispatchCommand(command),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 8),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
