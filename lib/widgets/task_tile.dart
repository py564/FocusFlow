import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final ValueChanged<bool?> onChanged;
  final ValueChanged<Task>? onEdit;
  final VoidCallback? onDelete;

  const TaskTile({
    super.key,
    required this.task,
    required this.onChanged,
    this.onEdit,
    this.onDelete,
  });

  // Helper to calculate the difference between creation and completion
  String getCompletionDuration(DateTime created, DateTime completed) {
    final duration = completed.difference(created);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) return 'Took ${hours}h ${minutes}m';
    if (minutes > 0) return 'Took ${minutes}m';
    return 'Took < 1m';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDone = task.isDone;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: isDone ? theme.colorScheme.surface : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDone ? Colors.transparent : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: [
          if (!isDone)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onLongPress: () => _showEditSheet(context),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Custom Checkbox Animation
                GestureDetector(
                  onTap: () => onChanged(!isDone),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: isDone ? theme.colorScheme.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDone ? theme.colorScheme.primary : Colors.grey.shade400,
                        width: 2,
                      ),
                    ),
                    child: isDone 
                        ? const Icon(Icons.check, size: 18, color: Colors.white) 
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Task Title and Subtitle Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          decoration: isDone ? TextDecoration.lineThrough : null,
                          color: isDone ? Colors.grey : theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          // Normal Scheduled Time
                          if (task.time != null) ...[
                            Icon(Icons.calendar_today, size: 12, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Text(task.time!, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                          ],

                          // TARGET TIME BADGE (New V2 Feature)
                          if (!isDone && task.targetMinutes != null) ...[
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.timer_outlined, size: 12, color: theme.colorScheme.primary),
                                  const SizedBox(width: 4),
                                  Text(
                                    "${task.targetMinutes}m",
                                    style: TextStyle(
                                      fontSize: 11, 
                                      fontWeight: FontWeight.bold, 
                                      color: theme.colorScheme.primary
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          // Completion Info
                          if (isDone && task.completedAt != null) ...[
                            Icon(Icons.done_all, size: 14, color: theme.colorScheme.primary),
                            const SizedBox(width: 4),
                            Text(
                              getCompletionDuration(task.createdAt, task.completedAt!),
                              style: TextStyle(fontSize: 12, color: theme.colorScheme.primary),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Actions Menu
                PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.more_horiz, color: Colors.grey),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  onSelected: (value) {
                    if (value == 'edit') _showEditSheet(context);
                    if (value == 'delete') onDelete?.call();
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text("Edit")),
                    const PopupMenuItem(
                      value: 'delete', 
                      child: Text("Delete", style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Edit logic remains largely the same but styled for V2
  void _showEditSheet(BuildContext context) {
    // ... (Use the same logic from your previous code but update the 'Task' 
    // creation to include 'targetMinutes: task.targetMinutes')
  }
}