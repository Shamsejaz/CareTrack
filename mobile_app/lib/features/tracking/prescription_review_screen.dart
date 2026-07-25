import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/auth_provider.dart';

class PrescriptionReviewScreen extends ConsumerStatefulWidget {
  final List<dynamic> medications;
  final List<dynamic> warnings;

  const PrescriptionReviewScreen({
    super.key, 
    required this.medications,
    required this.warnings,
  });

  @override
  ConsumerState<PrescriptionReviewScreen> createState() => _PrescriptionReviewScreenState();
}

class _PrescriptionReviewScreenState extends ConsumerState<PrescriptionReviewScreen> {
  bool _isSaving = false;

  Future<void> _saveMedications() async {
    setState(() => _isSaving = true);
    try {
      final supabase = ref.read(supabaseProvider);
      final user = ref.read(currentUserProvider);
      
      if (user == null) throw Exception('User not authenticated');

      for (var med in widget.medications) {
        await supabase.from('medications').insert({
          'patient_id': user.id,
          'name': med['name'],
          'dose': med['dose'],
          'timing': med['timing'],
          'frequency': med['frequency'],
        });
      }

      if (mounted) {
        context.pop(); // Pop review screen
        context.pop(); // Pop camera screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${widget.medications.length} medications saved successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review & Confirm'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.warnings.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Theme.of(context).colorScheme.onErrorContainer),
                        const SizedBox(width: 8),
                        Text(
                          'Clinical Safety Warning',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onErrorContainer,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...widget.warnings.map((w) => Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        '- ${w['warning']} (Interaction: ${w['drug1']} & ${w['drug2']})',
                        style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
                      ),
                    )),
                  ],
                ),
              ),
            
            Text(
              'Extracted Medications',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...widget.medications.map((med) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(Icons.medication, color: Theme.of(context).colorScheme.onPrimaryContainer),
                ),
                title: Text('${med['name']} ${med['dose']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${med['timing']} • ${med['frequency']}'),
              ),
            )),
            
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isSaving ? null : _saveMedications,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              child: _isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Confirm and Save', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
