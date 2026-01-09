import 'package:flutter/material.dart';
import '../models/habit.dart';

class HabitTile extends StatelessWidget {
  final Habit habit;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const HabitTile({
    super.key,
    required this.habit,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.blue.shade50,
            child: const Icon(
              Icons.local_fire_department,
              color: Colors.orange,
            ),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "🔥 ${habit.streak}-day streak",
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),

          Switch(
            value: habit.isCompletedToday,
            activeThumbColor: Colors.green,
            onChanged: (_) => onToggle(),
          ),

          // more options
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.grey),
            onPressed: () => _showOptions(context),
          ),
        ],
      ),
    );
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text("Edit"),
              onTap: () {
                Navigator.pop(context);
                onEdit();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text("Delete", style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                onDelete();
              },
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}
