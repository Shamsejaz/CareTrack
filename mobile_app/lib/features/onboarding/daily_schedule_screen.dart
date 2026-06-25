import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/auth_provider.dart';

class DailyScheduleScreen extends ConsumerStatefulWidget {
  const DailyScheduleScreen({super.key});

  @override
  ConsumerState<DailyScheduleScreen> createState() => _DailyScheduleScreenState();
}

class _DailyScheduleScreenState extends ConsumerState<DailyScheduleScreen> {
  TimeOfDay _wakeUpTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _breakfastTime = const TimeOfDay(hour: 8, minute: 30);
  TimeOfDay _lunchTime = const TimeOfDay(hour: 12, minute: 30);
  TimeOfDay _dinnerTime = const TimeOfDay(hour: 18, minute: 30);
  TimeOfDay _bedTime = const TimeOfDay(hour: 22, minute: 0);
  bool _isSaving = false;

  Future<void> _selectTime(BuildContext context, TimeOfDay initialTime, ValueChanged<TimeOfDay> onTimeChanged) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).colorScheme.primaryContainer,
                  onPrimary: Theme.of(context).colorScheme.onPrimaryContainer,
                  surface: Theme.of(context).colorScheme.surfaceContainerLowest,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != initialTime) {
      onTimeChanged(picked);
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute'; 
  }

  Future<void> _onContinue() async {
    final user = ref.read(currentUserProvider);
    
    if (user != null) {
      setState(() => _isSaving = true);
      try {
        final supabase = ref.read(supabaseProvider);
        await supabase.from('profiles').update({
          'wake_up_time': _formatTime(_wakeUpTime),
          'meal_time': {
            'breakfast': _formatTime(_breakfastTime),
            'lunch': _formatTime(_lunchTime),
            'dinner': _formatTime(_dinnerTime),
            'bedtime': _formatTime(_bedTime),
          },
        }).eq('id', user.id);
      } catch (e) {
        debugPrint('Error saving schedule: $e');
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
    
    if (mounted) {
      context.push('/setup/role');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildProgress(context),
              const SizedBox(height: 48),
              _buildHeader(context),
              const SizedBox(height: 48),
              _buildTimePickerGrid(context),
              const SizedBox(height: 64),
              _buildActions(context),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
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

  Widget _buildProgress(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'STEP 5 OF 6',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              '83% Complete',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        LinearProgressIndicator(
          value: 5/6,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
          color: Theme.of(context).colorScheme.primary,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your daily routine is the heart of your care.',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface,
                height: 1.2,
              ),
        ),
        const SizedBox(height: 16),
        Text(
          'This helps us set your reminders so you never miss a beat.',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w300,
              ),
        ),
      ],
    );
  }

  Widget _buildTimePickerGrid(BuildContext context) {
    return Column(
      children: [
        _buildWakeUpCard(context),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _buildSmallTimeCard(
                context,
                title: 'Breakfast',
                icon: Icons.breakfast_dining_rounded,
                time: _breakfastTime,
                onTimeChanged: (t) => setState(() => _breakfastTime = t),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: _buildSmallTimeCard(
                context,
                title: 'Lunch',
                icon: Icons.lunch_dining_rounded,
                time: _lunchTime,
                onTimeChanged: (t) => setState(() => _lunchTime = t),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildSmallTimeCard(
                context,
                title: 'Dinner',
                icon: Icons.dinner_dining_rounded,
                time: _dinnerTime,
                onTimeChanged: (t) => setState(() => _dinnerTime = t),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: _buildBedtimeCard(context),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWakeUpCard(BuildContext context) {
    return InkWell(
      onTap: () => _selectTime(context, _wakeUpTime, (t) => setState(() => _wakeUpTime = t)),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xff191c1d).withOpacity(0.06),
              blurRadius: 32,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2), // primary-fixed
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.wb_sunny_rounded,
                      color: Theme.of(context).colorScheme.primaryContainer, // on-primary-fixed
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Wake-up Time',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 18, // Slightly smaller to fit better
                              ),
                          maxLines: 2, // Allow wrapping if needed
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Start your morning track',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _formatTime(_wakeUpTime),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallTimeCard(BuildContext context, {
    required String title,
    required IconData icon,
    required TimeOfDay time,
    required ValueChanged<TimeOfDay> onTimeChanged,
  }) {
    return InkWell(
      onTap: () => _selectTime(context, time, onTimeChanged),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.secondary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: FittedBox(
                    alignment: Alignment.centerLeft,
                    fit: BoxFit.scaleDown,
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _formatTime(time),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBedtimeCard(BuildContext context) {
    return InkWell(
      onTap: () => _selectTime(context, _bedTime, (t) => setState(() => _bedTime = t)),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bedtime_rounded, color: Theme.of(context).colorScheme.onPrimaryContainer, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Bedtime',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _formatTime(_bedTime),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Rest is essential for recovery.',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.8), // primary-fixed equivalent
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _isSaving ? null : _onContinue,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
            elevation: 8,
            shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          child: Center(
            child: _isSaving
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text(
                  'Save and Continue',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
          ),
        ),
        const SizedBox(height: 24),
        TextButton(
          onPressed: () {
            // skip to prescription
            context.push('/setup/prescription');
          },
          child: Text(
            'I\'ll do this later',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  decoration: TextDecoration.underline,
                ),
          ),
        ),
      ],
    );
  }
}
