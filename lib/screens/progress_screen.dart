import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/habit.dart';

class ProgressView extends StatelessWidget {
  final List<Task> tasks;
  final List<Habit> habits;

  const ProgressView({super.key, required this.tasks, required this.habits});

  @override
  Widget build(BuildContext context) {
    // 1. LOGIC SECTION (Calculated every time the screen builds)
    final now = DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);

    // Filter for Today
    final todaysTasks = tasks.where((t) {
      final tDate = DateTime(t.createdAt.year, t.createdAt.month, t.createdAt.day);
      return tDate.isAtSameMomentAs(todayDate);
    }).toList();

    final todayCompleted = todaysTasks.where((t) => t.isDone).length;
    final todayTotal = todaysTasks.length;

    // Overall Stats
    final completedTasks = tasks.where((t) => t.isDone).length;
    final totalTasks = tasks.length;
    final taskCompletionRate = totalTasks == 0 ? 0.0 : (completedTasks / totalTasks);
    final totalHabitStreaks = habits.fold<int>(0, (sum, h) => sum + h.streak);

    // 2. UI SECTION
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          
          // NEW: Today's Result Card at the very top
          _buildTodayResultCard(todayCompleted, todayTotal),
          
          const SizedBox(height: 24),
          _buildHeader("Overview"),
          const SizedBox(height: 16),
          
          Row(
            children: [
              _buildStatCard("Total Done", "$completedTasks", Icons.assignment_turned_in, const Color(0xFF2E7D32)),
              const SizedBox(width: 12),
              _buildStatCard("Streaks", "$totalHabitStreaks", Icons.local_fire_department_rounded, Colors.orange),
            ],
          ),

          const SizedBox(height: 24),
          _buildHeader("Last 7 Days Activity"),
          const SizedBox(height: 16),
          _buildWeeklyChart(tasks),

          const SizedBox(height: 24),
          _buildHeader("Focus Efficiency"),
          const SizedBox(height: 16),
          _buildEfficiencyCard(taskCompletionRate),

          const SizedBox(height: 24),
          _buildHeader("Habit Progress"),
          const SizedBox(height: 16),
          ...habits.map((habit) => _buildHabitProgressTile(habit)),

          const SizedBox(height: 100), 
        ],
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildTodayResultCard(int completed, int total) {
    double percent = total == 0 ? 0.0 : completed / total;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("🎉TODAY'S SCORE", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("$completed of $total tasks", style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              Text("${(percent * 100).toInt()}%", style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 8,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)));
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChart(List<Task> allTasks) {
    final now = DateTime.now();
    final last7Days = List.generate(7, (i) => DateTime(now.year, now.month, now.day).subtract(Duration(days: 6 - i)));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: last7Days.map((date) {
          final dayTasks = allTasks.where((t) => 
            t.createdAt.year == date.year && t.createdAt.month == date.month && t.createdAt.day == date.day
          ).toList();
          final doneCount = dayTasks.where((t) => t.isDone).length;
          double barHeight = dayTasks.isEmpty ? 4 : (doneCount / dayTasks.length) * 80;

          return Column(
            children: [
              Container(
                width: 12, height: 80,
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
                alignment: Alignment.bottomCenter,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  width: 12, height: barHeight,
                  decoration: BoxDecoration(color: const Color(0xFF2E7D32), borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 8),
              Text(['M','T','W','T','F','S','S'][date.weekday-1], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEfficiencyCard(double rate) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF1F2937), borderRadius: BorderRadius.circular(24)),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(width: 50, height: 50, child: CircularProgressIndicator(value: rate, strokeWidth: 5, backgroundColor: Colors.white10, color: const Color(0xFF2E7D32))),
              Text("${(rate * 100).toInt()}%", style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(width: 16),
          const Expanded(child: Text("Focus Score\nGreat consistency!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildHabitProgressTile(Habit habit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          const Icon(Icons.bolt, color: Color(0xFF2E7D32)),
          const SizedBox(width: 12),
          Text(habit.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          const Spacer(),
          Text("${habit.streak}d streak", style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }
}