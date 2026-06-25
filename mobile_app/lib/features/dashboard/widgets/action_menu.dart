import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ActionMenu extends StatelessWidget {
  const ActionMenu({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ActionMenu(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            'What do you need to do?',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildMenuGrid(context),
        ],
      ),
    );
  }

  Widget _buildMenuGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 24,
      crossAxisSpacing: 16,
      children: [
        _buildActionItem(context, 'Sugar', Icons.water_drop_rounded, Colors.red, '/track/sugar'),
        _buildActionItem(context, 'Meal', Icons.restaurant_rounded, Colors.green, '/track/meal'),
        _buildActionItem(context, 'Medicine', Icons.medication_rounded, Colors.orange, '/track/medicine'),
        _buildActionItem(context, 'Craving', Icons.icecream_rounded, Colors.purple, '/track/craving'),
        _buildActionItem(context, 'Walk', Icons.directions_walk_rounded, Colors.blue, '/track/walk'),
        _buildActionItem(context, 'Water', Icons.local_drink_rounded, Colors.cyan, '/track/water'),
      ],
    );
  }

  Widget _buildActionItem(BuildContext context, String title, IconData icon, Color color, String route) {
    return InkWell(
      onTap: () {
        Navigator.pop(context); // Close sheet
        context.push(route);
      },
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
