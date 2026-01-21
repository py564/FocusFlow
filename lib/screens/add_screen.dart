// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/notification_service.dart';
import 'dart:developer' as developer;

class AddTaskBottomSheet extends StatefulWidget {
  final Function(Task) onTaskAdded;

  const AddTaskBottomSheet({super.key, required this.onTaskAdded});

  @override
  State<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends State<AddTaskBottomSheet> {
  final TextEditingController taskController = TextEditingController();
  TimeOfDay selectedTime = TimeOfDay.now();
  int? selectedTargetMinutes;

  Future<void> pickTime() async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );

    if (time != null) {
      setState(() => selectedTime = time);
    }
  }

  Widget _buildTargetTimeSection(ThemeData theme) {
    // Check if the current selection is one of our presets
    final List<int> presets = [15, 30, 60, 120];
    final bool isCustom =
        selectedTargetMinutes != null &&
        !presets.contains(selectedTargetMinutes);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Target Time (Optional)", style: theme.textTheme.titleSmall),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...presets.map((mins) {
              final isSelected = selectedTargetMinutes == mins;
              return ChoiceChip(
                label: Text(mins >= 60 ? '${mins ~/ 60}h' : '${mins}m'),
                selected: isSelected,
                onSelected: (selected) {
                  setState(
                    () => selectedTargetMinutes = selected ? mins : null,
                  );
                },
                selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                checkmarkColor: theme.colorScheme.primary,
              );
            }),
            // --- CUSTOM CHIP ---
            ChoiceChip(
              label: Text(isCustom ? "${selectedTargetMinutes}m" : "Custom"),
              selected: isCustom,
              onSelected: (selected) {
                if (selected) {
                  _showCustomTimeDialog(theme);
                } else {
                  setState(() => selectedTargetMinutes = null);
                }
              },
              selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
              checkmarkColor: theme.colorScheme.primary,
            ),
          ],
        ),
      ],
    );
  }

  void _showCustomTimeDialog(ThemeData theme) {
    // Renamed from _customController to customController
    final TextEditingController customController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Set Custom Target"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("How many minutes would you like to focus?"),
            const SizedBox(height: 16),
            TextField(
              controller: customController,
              keyboardType: TextInputType.number,
              autofocus: true,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: "00",
                suffixText: "mins",
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.3,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final int? val = int.tryParse(customController.text);
              if (val != null && val > 0) {
                setState(() => selectedTargetMinutes = val);
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
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
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Text(
            "New Task",
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: taskController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: "Add task..",
              prefixIcon: const Icon(Icons.edit_note_rounded),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.3,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildTargetTimeSection(theme), // Added to UI
          const SizedBox(height: 16),
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
          Row(
            children: [
              Expanded(
                child: TextButton(
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {  // Make this async
                    if (taskController.text.isNotEmpty) {
                      final newTask = Task(
                        title: taskController.text,
                        time: selectedTime.format(context),
                        targetMinutes: selectedTargetMinutes,
                        createdAt: DateTime.now(),
                      );
    
                      // 1. Call the callback to add task (to save in Hive)
                      widget.onTaskAdded(newTask);
    
                      // 2. SCHEDULE NOTIFICATION if target time is set
                      if (selectedTargetMinutes != null) {
                        try {
                          // Schedule notification
                            await NotificationService.scheduleTaskReminder(
                            taskController.text,
                            selectedTargetMinutes!,
                          );
        
                          // Show success message
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('⏰ Reminder set for $selectedTargetMinutes minutes'),
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          }
        
                          developer.log('Notification scheduled for "${taskController.text}" in $selectedTargetMinutes minutes');
        
                        } catch (e) {
                          developer.log('Failed to schedule notification: $e');
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('⚠️ Could not set reminder: $e'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          }
                        }
                      }
    
                      if (mounted) Navigator.pop(context);
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
