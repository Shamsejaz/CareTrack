import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/api/api_client.dart';
import '../dashboard/providers/dashboard_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/widgets/custom_bottom_nav.dart';
import '../../core/services/common_service.dart';

class SugarTrackerScreen extends ConsumerStatefulWidget {
  const SugarTrackerScreen({super.key});

  @override
  ConsumerState<SugarTrackerScreen> createState() => _SugarTrackerScreenState();
}

class _SugarTrackerScreenState extends ConsumerState<SugarTrackerScreen> {
  String _sugarValueStr = '';
  String _selectedTag = 'BBF';
  bool _isSaving = false;

  void _onKeypadTap(String val) {
    if (_sugarValueStr.length < 3) {
      setState(() {
        _sugarValueStr += val;
      });
    }
  }

  void _onBackspace() {
    if (_sugarValueStr.isNotEmpty) {
      setState(() {
        _sugarValueStr = _sugarValueStr.substring(0, _sugarValueStr.length - 1);
      });
    }
  }



  Future<void> _saveReading() async {
    if (_sugarValueStr.isEmpty) return;
    
    int sugarValue = int.tryParse(_sugarValueStr) ?? 0;

    setState(() => _isSaving = true);
    try {
      final supabase = ref.read(supabaseProvider);
      final user = ref.read(currentUserProvider);
      
      if (user == null) throw Exception('User not authenticated');

      final response = await supabase.from('health_logs').insert({
        'patient_id': user.id,
        'log_type': 'Sugar',
        'value': '$sugarValue mg/dL ($_selectedTag)',
        'manual_confirm': true,
      }).select().single();

      final logId = response['id'];

      // Analyze reading immediately using CommonService
      await ref.read(commonServiceProvider).analyzeHealthLog(logId, 'Sugar', '$sugarValue');

      // Refresh dashboard
      ref.invalidate(dashboardDataProvider);

      if (mounted) {
        if (sugarValue >= 200) {
          // Go to Critical Alert screen
          context.pushReplacement('/track/sugar/alert', extra: sugarValue);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sugar reading saved successfully!')),
          );
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving reading: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: _buildAppBar(context),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                children: [
                  _buildEditorialHeader(context),
                  const SizedBox(height: 32),
                  _buildNumericalDisplay(context),
                  const SizedBox(height: 32),
                  _buildTagSelection(context),
                  const SizedBox(height: 32),
                  _buildNumericalKeypad(context),
                  const SizedBox(height: 120), // bottom nav space
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 1), // Optional, context
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 80.0), // push above nav
        child: SizedBox(
          width: double.infinity,
          height: 64,
          child: ElevatedButton.icon(
            onPressed: _isSaving || _sugarValueStr.isEmpty ? null : _saveReading,
            icon: _isSaving 
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                : const Icon(Icons.check_circle_rounded),
            label: Text(
              _isSaving ? 'Saving...' : 'Save Reading',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.95),
      elevation: 0,
      centerTitle: false,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_rounded, color: Theme.of(context).colorScheme.primaryContainer),
        onPressed: () => context.pop(),
      ),
      title: Text(
        'CareTrack',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildEditorialHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DAILY LOG',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                letterSpacing: 1.5,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter Sugar Level',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(Icons.calendar_today_rounded, color: Theme.of(context).colorScheme.tertiary, size: 20),
            const SizedBox(width: 8),
            Text(
              'Today, Oct 24', // Static for prototype, normally DateFormat format
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.tertiary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNumericalDisplay(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
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
          Text(
            'BLOOD GLUCOSE',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _sugarValueStr.isEmpty ? '---' : _sugarValueStr,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 72,
                      letterSpacing: -2,
                    ),
              ),
              const SizedBox(width: 8),
              Text(
                'mg/dL',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTagSelection(BuildContext context) {
    final tags = [
      {'id': 'BBF', 'title': 'BBF', 'sub': '(Before Breakfast)'},
      {'id': 'ABF', 'title': 'ABF', 'sub': '(After Breakfast)'},
      {'id': 'BL', 'title': 'BL', 'sub': '(Before Lunch)'},
      {'id': 'AL', 'title': 'AL', 'sub': '(After Lunch)'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'EVENT TAG',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: tags.map((tag) {
              final isSelected = _selectedTag == tag['id'];
              return Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: InkWell(
                  onTap: () => setState(() => _selectedTag = tag['id']!),
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      children: [
                        Text(
                          tag['title']!,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          tag['sub']!,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: isSelected ? Theme.of(context).colorScheme.onPrimary.withOpacity(0.8) : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildNumericalKeypad(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildKeypadButton('1'),
        _buildKeypadButton('2'),
        _buildKeypadButton('3'),
        _buildKeypadButton('4'),
        _buildKeypadButton('5'),
        _buildKeypadButton('6'),
        _buildKeypadButton('7'),
        _buildKeypadButton('8'),
        _buildKeypadButton('9'),
        const SizedBox(), // Empty Spacer
        _buildKeypadButton('0'),
        _buildBackspaceButton(),
      ],
    );
  }

  Widget _buildKeypadButton(String num) {
    return InkWell(
      onTap: () => _onKeypadTap(num),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            num,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton() {
    return InkWell(
      onTap: _onBackspace,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Icon(Icons.backspace_rounded, color: Theme.of(context).colorScheme.error, size: 28),
        ),
      ),
    );
  }
}
