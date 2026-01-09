import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/habit.dart';

class ProgressView extends StatelessWidget {
  final List<Task> tasks;
  final List<Habit> habits;

  const ProgressView({
    super.key,
    required this.tasks,
    required this.habits,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateTime.now();

    final todayTasks = tasks.where((task) =>
        task.createdAt.year == today.year &&
        task.createdAt.month == today.month &&
        task.createdAt.day == today.day);

    final completed = todayTasks.where((t) => t.isDone).length;
    final total = todayTasks.length;
    final progress = total == 0 ? 0.0 : completed / total;

    final hasData = tasks.isNotEmpty || habits.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: hasData
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TaskProgressCard(
                  completed: completed,
                  total: total,
                  progress: progress,
                ),
                const SizedBox(height: 28),
                if (habits.isNotEmpty) ...[
                  Text(
                    'Habit Streaks',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  ...habits.map(_HabitTile.new),
                ],
                const SizedBox(height: 32),
                Center(
                  child: Text(
                    'Consistency beats motivation.',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: Colors.grey.shade600),
                  ),
                ),
              ],
            )
          : _EmptyState(),
    );
  }
}
class _TaskProgressCard extends StatelessWidget {
  final int completed;
  final int total;
  final double progress;

  const _TaskProgressCard({
    required this.completed,
    required this.total,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🎉 Today’s Progress',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              '$completed of $total tasks completed',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: Colors.grey.shade200,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class _HabitTile extends StatelessWidget {
  final Habit habit;

  const _HabitTile(this.habit);

  @override
  Widget build(BuildContext context) {
    final color = _habitColor(habit.name);
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              // ignore: deprecated_member_use
              backgroundColor: color.withOpacity(0.12),
              child: Icon(_habitIcon(habit.name), color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                habit.name,
                style: theme.textTheme.bodyLarge,
              ),
            ),
            Row(
              children: [
                const Icon(Icons.local_fire_department,
                    color: Colors.orange, size: 18),
                const SizedBox(width: 4),
                Text(
                  '${habit.streak} days',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.insights_rounded,
              size: 72, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No progress yet',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Start adding tasks and habits\nto view your progress',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
Color _habitColor(String name) {
  switch (name.toLowerCase()) {
    case 'drink water':
      return Colors.blue;
    case 'study':
      return Colors.indigo;
    case 'exercise':
      return Colors.orange;
    default:
      return Colors.green;
  }
}

IconData _habitIcon(String name) {
  switch (name.toLowerCase()) {
    case 'drink water':
      return Icons.water_drop;
    case 'study':
      return Icons.menu_book;
    case 'exercise':
      return Icons.local_fire_department;
    default:
      return Icons.emoji_events;
  }
}
