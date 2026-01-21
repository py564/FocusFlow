import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../widgets/habit_tile.dart';
import '../models/habit.dart';

class HabitScreen extends StatefulWidget {
  const HabitScreen({super.key});

  @override
  State<HabitScreen> createState() => _HabitScreenState();
}

class _HabitScreenState extends State<HabitScreen> {
  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    _storageService.resetDailyHabitsIfNeeded();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: HabitView(),
      ),
    );
  }
}

class HabitView extends StatefulWidget {
  const HabitView({super.key});

  @override
  HabitViewState createState() => HabitViewState();
}

class HabitViewState extends State<HabitView> {
  final StorageService _storageService = StorageService();
  final TextEditingController _controller = TextEditingController();

  void showAddHabitDialog() {
    _showAddHabitDialog();
  }

 void _showAddHabitDialog() {
  showModalBottomSheet(
    context: context,
    // 1. THIS IS CRUCIAL: Allows the sheet to move above the keyboard
    isScrollControlled: true, 
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return Padding(
        // 2. DYNAMIC PADDING: Adds bottom padding equal to the keyboard height
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Keep the sheet compact
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Add Habit",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              autofocus: true, // Optional: Opens keyboard automatically
              decoration: InputDecoration(
                hintText: "Habit name",
                prefixIcon: const Icon(Icons.emoji_emotions_outlined),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _controller.clear();
                    },
                    child: const Text("CANCEL"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      if (_controller.text.isNotEmpty) {
                        setState(() {
                          _storageService.addHabit(_controller.text);
                        });
                        Navigator.pop(context);
                        _controller.clear();

                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                           behavior: SnackBarBehavior.floating,
                           backgroundColor: const Color(0xFFF0F4F8), // Cloud Blue
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            content: const Text(
                             "Habit added successfully!",
                             style: TextStyle(color: Color(0xFF455A64)),
                            ),
                          ),
                        );
                      }
                    },
                    child: const Text("SAVE"),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

  void _showEditHabitDialog(Habit habit) {
  final controller = TextEditingController(text: habit.name);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Required to move above keyboard
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return Padding(
        // DYNAMIC PADDING: This pushes the content above the keyboard
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start, // Modern alignment
          children: [
            const Text(
              "Edit Habit",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true, // Good UX to focus immediately when editing
              decoration: InputDecoration(
                hintText: "Habit name",
                prefixIcon: const Icon(Icons.edit_note_rounded),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity, // Make the button easier to tap on mobile
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3F51B5), // Tonal Indigo
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  if (controller.text.isNotEmpty) {
                    setState(() {
                      _storageService.editHabit(habit, controller.text);
                    });

                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: const Color(0xFFF0F4F8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        content: const Text(
                          "Habit updated successfully!",
                          style: TextStyle(color: Color(0xFF455A64)),
                        ),
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text("SAVE CHANGES"),
              ),
            ),
          ],
        ),
      );
    },
  );
}
  @override
  Widget build(BuildContext context) {
    List<Habit> habits = _storageService.getHabits();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Text(
          "My Habits 😀",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),

        const SizedBox(height: 12),

        Expanded(
          child: habits.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.track_changes, size: 64, color: Colors.grey),
                      SizedBox(height: 12),
                      Text(
                        "No habits yet",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Start building good habits today",
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: habits.length,
                  itemBuilder: (context, index) {
                    return HabitTile(
                      habit: habits[index],
                      onToggle: () {
                        setState(() {
                          _storageService.toggleHabit(habits[index]);
                        });
                      },
                      onEdit: () => _showEditHabitDialog(habits[index]),
                      onDelete: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("Delete Habit"),
                            content: const Text(
                              "Are you sure you want to delete this habit?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text("Delete"),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          setState(() {
                            _storageService.deleteHabit(habits[index].id);
                          });
                        
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: const Color(0xFFF0F4F8), // Cloud Blue
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              content: const Text(
                                "Habit deleted successfully!",
                                style: TextStyle(color: Color(0xFF455A64)),
                              ),
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
        ),

        Center(
          child: TextButton.icon(
            onPressed: _showAddHabitDialog,
            icon: const Icon(Icons.add),
            label: const Text("Add Habit"),
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }
}

