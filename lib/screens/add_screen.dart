import 'package:flutter/material.dart';
import '../models/task.dart';

class AddTaskBottomSheet extends StatefulWidget {
  final Function(Task) onTaskAdded;

  const AddTaskBottomSheet({super.key, required this.onTaskAdded});

  @override
  State<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends State<AddTaskBottomSheet> {
  final TextEditingController taskController = TextEditingController();

  // Initialize with the current device time instead of null
  TimeOfDay selectedTime = TimeOfDay.now();

  Future<void> pickTime() async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );

    if (time != null) {
      setState(() {
        selectedTime = time;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Modern Handle Bar for Bottom Sheets
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          Text(
            "New Task",
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),

          const SizedBox(height: 20),

          // Modern Input Field
          TextField(
            controller: taskController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: "Add task..",
              prefixIcon: const Icon(Icons.edit_note_rounded),
              filled: true,
              // ignore: deprecated_member_use
              fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(
                0.3,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Elegant Time Picker Trigger
          InkWell(
            onTap: pickTime,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.outlineVariant),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    // Shows the current time by default
                    selectedTime.format(context),
                    style: theme.textTheme.bodyLarge,
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                ],
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Prominent Action Buttons
          Row(
            children: [
              Expanded(
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (taskController.text.isNotEmpty) {
                      widget.onTaskAdded(
                        Task(
                          title: taskController.text,
                          time: selectedTime.format(context),
                          createdAt: DateTime.now(),
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text(
                    "Create Task",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
