import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets/custom_bottom_nav.dart';
import 'providers/tasks_provider.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Daily Tasks'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: tasksAsync.when(
        data: (data) {
          if (data.isEmpty) {
            return const Center(child: Text('No tasks available'));
          }
          return ListView(
            padding: const EdgeInsets.all(24),
            children: data.entries.map((entry) {
              final category = entry.key;
              final tasks = entry.value;
              if (tasks.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: _buildTaskCategory(
                  context,
                  category,
                  tasks.map((t) => _buildTaskItem(
                    context,
                    t['title'] ?? '',
                    t['sub'] ?? '',
                    t['time'] ?? '',
                    t['isDone'] ?? false,
                  )).toList(),
                ),
              );
            }).toList(),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 2),
    );
  }

  Widget _buildTaskCategory(BuildContext context, String title, List<Widget> tasks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...tasks,
      ],
    );
  }

  Widget _buildTaskItem(BuildContext context, String title, String sub, String time, bool isDone) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDone ? Colors.green.shade50 : Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDone ? Colors.green.shade200 : Colors.transparent),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDone ? Colors.green : Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isDone ? Icons.check_rounded : Icons.access_time_rounded,
              color: isDone ? Colors.white : Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                    color: isDone ? Colors.grey : null,
                  ),
                ),
                Text(
                  sub,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDone ? Colors.grey : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDone ? Colors.grey : Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
