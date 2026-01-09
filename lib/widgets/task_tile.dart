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

    if (hours > 0) {
      return 'Completed in ${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return 'Completed in ${minutes}m';
    } else {
      return 'Completed in < 1m'; 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0, // Modern flat look
      color: task.isDone ? Colors.grey.shade50 : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // Softer corners
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Checkbox(
          value: task.isDone,
          onChanged: onChanged,
          activeColor: const Color(0xFF3F51B5), // Using FocusFlow Tonal Indigo
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isDone ? TextDecoration.lineThrough : null,
            color: task.isDone ? Colors.grey : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: task.isDone && task.completedAt != null
            ? Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 14, color: Color(0xFF3F51B5)),
                  const SizedBox(width: 4),
                  Text(
                    // UPDATED: Show "Took X mins" instead of "at 5:10"
                    getCompletionDuration(task.createdAt, task.completedAt!),
                    style: const TextStyle(
                      color: Color(0xFF3F51B5), 
                      fontSize: 13,
                      fontWeight: FontWeight.w500
                    ),
                  ),
                ],
              )
            : task.time != null
                ? Text(task.time!, style: const TextStyle(color: Colors.grey))
                : null,
        trailing: PopupMenuButton<String>(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          icon: const Icon(Icons.more_vert, color: Colors.grey),
          onSelected: (value) {
            if (value == 'delete') {
              if (onDelete != null) onDelete!();
            } else if (value == 'edit') {
              _showEditSheet(context);
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
          ],
        ),
      ),
    );
  }

  void _showEditSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final TextEditingController controller = TextEditingController(
          text: task.title,
        );
        String? selectedTime = task.time;

        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              Future<void> pickTime() async {
                final TimeOfDay? time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (time != null) {
                  setState(() {
                    selectedTime = time.format(context);
                  });
                }
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Edit Task",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: "Task name",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: pickTime,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, color: Colors.grey),
                          const SizedBox(width: 12),
                          Text(selectedTime ?? "Select time"),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (controller.text.isNotEmpty) {
                              final updated = Task(
                                title: controller.text,
                                isDone: task.isDone,
                                time: selectedTime,
                                completedAt: task.completedAt,
                              );
                              if (onEdit != null) onEdit!(updated);
                              Navigator.pop(context);
                            }
                          },
                          child: const Text("Save"),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  String formatCompletedTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';

    return "$hour:$minute $period";
  }
}