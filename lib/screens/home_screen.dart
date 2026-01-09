// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:focus_flow/models/task.dart';
import 'package:focus_flow/services/storage_service.dart';
import 'package:focus_flow/widgets/task_tile.dart';
import 'add_screen.dart';
import 'package:focus_flow/screens/habit_screen.dart';
import 'progress_screen.dart';
import 'package:focus_flow/models/habit.dart';
import 'package:hive/hive.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<Task> tasks = [];
  List<Habit> habits = [];
  final GlobalKey<HabitViewState> _habitKey = GlobalKey<HabitViewState>();

  @override
  void initState() {
    super.initState();

    StorageService.loadTasks().then((loadedTasks) {
      final habitBox = Hive.box<Habit>('habits');
      final loadedhabits = habitBox.values.toList();

      setState(() {
        tasks = loadedTasks;
        habits = loadedhabits;
      });
    });
  }

  void showAddTaskBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return AddTaskBottomSheet(
          onTaskAdded: (task) {
            setState(() {
              tasks.add(task);
              StorageService.saveTasks(tasks);
            });

            ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(
                 behavior: SnackBarBehavior.floating,
                 backgroundColor: const Color(0xFFF0F4F8), // Cloud Blue
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                 content: const Text(
                   "Task added successfully!",
                   style: TextStyle(color: Color(0xFF455A64)),
                 ),
               ),
            );
          },
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    // HABITS TAB
    if (_currentIndex == 1) {
      return AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(12),
          child: const SizedBox(),
        ),
        title: Column(
          children: const [
            Text(
              "Habits",
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
              ),
            ),
            SizedBox(height: 3),
            Text(
              "Make habit of making good habits 😉",
              style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
          ],
        ),
      );
    }
    // Progress bar
    else if (_currentIndex == 2) {
      return AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(12),
          child: const SizedBox(),
        ),
        title: Column(
          children: const [
            Text(
              "Progress",
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w700,
                color: Color.fromARGB(255, 27, 37, 51),
              ),
            ),
            SizedBox(height: 3),
            Text(
              "Keep moving forward.",
              style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
          ],
        ),
      );
    }

    // DEFAULT (Today & Progress)
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      titleSpacing: 20,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "FocusFlow",
            style: TextStyle(
              color: Color(0xFF2E7D32),
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 2),
          Text(
            "Focus on what matters today",
            style: TextStyle(color: Colors.black54, fontSize: 13),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black54),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    backgroundColor: const Color(0xFFF8F9FA), // Your modern BG color
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 1. Your Custom Logo
                        Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                // ignore: deprecated_member_use
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        const SizedBox(height: 20),
            
                        // 2. App Name & Version
                        const Text(
                          "FocusFlow",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const Text(
                          "Version 1.0.0",
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
            
                        const SizedBox(height: 16),
            
                        // 3. Simple Description
                        const Text(
                          "Small steps, every day.\nBuilt for focus and calm.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xFF455A64), height: 1.5),
                        ),
            
                        const SizedBox(height: 24),
            
                        // 4. Close Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3F51B5), // Tonal Indigo
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Close"),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 242, 245, 247),
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_currentIndex == 0) ...[
              const Text(
                "My Tasks 🐱‍🚀",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: tasks.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.track_changes_rounded,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 12),
                            Text(
                              "No tasks yet",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Start building tasks today",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Builder(
                        builder: (context) {
                          final grouped = StorageService.groupTasksByDay(tasks);
                          final dates = grouped.keys.toList();
                          return ListView.builder(
                            physics: const BouncingScrollPhysics(), //makes fell smooth
                            padding: const EdgeInsets.only(bottom: 80),
                            itemCount: dates.length,
                            itemBuilder: (context, sectionIndex) {
                              final date = dates[sectionIndex];
                              final dayTasks = grouped[date]!;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4,
                                      ),
                                      child: Text(
                                        StorageService.dateLabel(date),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    ...dayTasks.map((task) {
                                      return TaskTile(
                                        task: task,
                                        onChanged: (value) {
                                          final prevIsDone = task.isDone;
                                          final prevCompletedAt =
                                              task.completedAt;
                                          final newValue = value ?? false;

                                          setState(() {
                                            final idx = tasks.indexOf(task);
                                            if (idx == -1) return;
                                            tasks[idx].isDone = value!;
                                            tasks[idx].completedAt = value
                                                ? DateTime.now()
                                                : null;
                                            StorageService.saveTasks(tasks);
                                          });

                                          ScaffoldMessenger.of(
                                            context,
                                          ).hideCurrentSnackBar();
                                          final _snackCtrl1 =
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  behavior: SnackBarBehavior.floating,
                                                  content: Text(
                                                    newValue
                                                        ? 'Marked "${task.title}" as completed'
                                                        : 'Marked "${task.title}" as incompleted',
                                                    style: const TextStyle(
                                                      color: Color(0xFF455A64),
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  backgroundColor:
                                                      const Color(0xFFF0F4F8),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                  margin: const EdgeInsets.all(16),
                                                  elevation: 2,
                                                  action: SnackBarAction(
                                                    label: 'UNDO',
                                                    textColor:
                                                        Color(0xFF3F51B5),
                                                    onPressed: () {
                                                      setState(() {
                                                        final idx = tasks
                                                            .indexOf(task);
                                                        if (idx == -1) return;
                                                        tasks[idx].isDone =
                                                            prevIsDone;
                                                        tasks[idx].completedAt =
                                                            prevCompletedAt;
                                                        StorageService.saveTasks(
                                                          tasks,
                                                        );
                                                      });
                                                    },
                                                  ),
                                                  duration: const Duration(
                                                    seconds: 5,
                                                  ),
                                                ),
                                              );
                                          Future.delayed(
                                            const Duration(seconds: 5),
                                            () {
                                              _snackCtrl1.close();
                                            },
                                          );
                                        },
                                        
                                        onDelete: () async {
                                          // 1. Show the modern confirmation dialog
                                       final bool? confirm = await showDialog<bool>(
                                         context: context,
                                         builder: (context) => AlertDialog(
                                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                           title: const Text("Delete Task?"),
                                           content: const Text("This action cannot be undone. Would you like to remove this task?"),
                                           actions: [
                                             TextButton(
                                               onPressed: () => Navigator.pop(context, false),
                                               child: Text("Keep it", style: TextStyle(color: Colors.grey.shade600)),
                                             ),
                                             TextButton(
                                               onPressed: () => Navigator.pop(context, true),
                                               child: const Text(
                                                 "Delete", 
                                                 style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)
                                               ),
                                             ),
                                           ],
                                         ),
                                       );

                                      // 2. If confirmed, perform the deletion and show the calm Snackbar
                                      if (confirm == true) {
                                        final removedIndex = tasks.indexOf(task);
                                        if (removedIndex == -1) return;

                                        setState(() {
                                          tasks.removeAt(removedIndex);
                                          StorageService.saveTasks(tasks);
                                        });

                                        // 3. Show the calm snackbar with the Undo option
                                        // ignore: use_build_context_synchronously
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            behavior: SnackBarBehavior.floating,
                                            backgroundColor: const Color(0xFFF0F4F8), // Cloud Blue
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            content: const Text(
                                              "Task deleted successfully!",
                                              style: TextStyle(color: Color(0xFF455A64)),
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                        onEdit: (updated) {
                                          setState(() {
                                            final idx = tasks.indexOf(task);
                                            if (idx == -1) return;
                                            // Ensure createdAt is preserved if not provided
                                            final newTask = Task(
                                              title: updated.title,
                                              isDone: updated.isDone,
                                              time: updated.time,
                                              completedAt: updated.completedAt,
                                              createdAt: task.createdAt,
                                            );
                                            tasks[idx] = newTask;
                                            StorageService.saveTasks(tasks);
                                          });
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            behavior: SnackBarBehavior.floating,
                                            backgroundColor: const Color(0xFFF0F4F8), // Cloud Blue
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            content: const Text(
                                              "Task edited successfully!",
                                              style: TextStyle(color: Color(0xFF455A64)),
                                            ),
                                          ),
                                        );
                                    
                                        },
                                      );
                                      // ignore: unnecessary_to_list_in_spreads
                                    }).toList(),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ] else if (_currentIndex == 1) ...[
              const SizedBox(height: 12),
              Expanded(child: HabitView(key: _habitKey)),
            ] else ...[
              Expanded(
                child: ProgressView(tasks: tasks, habits: habits),
              ),
            ],
          ],
        ),
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: showAddTaskBottomSheet,
              backgroundColor: Colors.blue,
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: "Habits",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: "Progress",
          ),
        ],
      ),
    );
  }
}
