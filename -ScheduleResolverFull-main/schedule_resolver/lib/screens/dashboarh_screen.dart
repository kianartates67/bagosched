import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/schedule_provider.dart';
import '../services/ai_schedule_service.dart';
import '../models/task_model.dart';
import 'task_input_screen.dart';
import 'recommendation_screen.dart';

class DashboarhScreen extends StatelessWidget {
  const DashboarhScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheduleProvider = Provider.of<ScheduleProvider>(context);
    final aiService = Provider.of<AiScheduleService>(context);
    final sortedTasks = List<TaskModel>.from(scheduleProvider.task);
    sortedTasks.sort((a, b) {
      final aTime = a.startTime.hour * 60 + a.startTime.minute;
      final bTime = b.startTime.hour * 60 + b.startTime.minute;
      return aTime.compareTo(bTime);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule App'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (aiService.currentAnalysis != null)
              Card(
                color: Colors.green.shade200,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text('Recommendation Ready!!', style: TextStyle(fontWeight: FontWeight.bold)),
                      ElevatedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RecommendationScreen(),
                          ),
                        ),
                        child: const Text('View Recommendation'),
                      )
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Expanded(
              child: sortedTasks.isEmpty
                  ? const Center(child: Text('No added Task Yet'))
                  : ListView.builder(
                      itemCount: sortedTasks.length,
                      itemBuilder: (context, index) {
                        final task = sortedTasks[index];
                        return ListTile(
                          title: Text(task.title),
                          subtitle: Text(
                              '| ${task.category} | ${task.startTime.hour}:${task.startTime.minute.toString().padLeft(2, '0')} - ${task.endTime.hour}:${task.endTime.minute.toString().padLeft(2, '0')}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            color: Colors.red,
                            onPressed: () => scheduleProvider.removeTask(task.id),
                          ),
                        );
                      },
                    ),
            ),
            if (sortedTasks.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: aiService.isLoading
                        ? null
                        : () async {
                            await aiService.analyzeSchedule(scheduleProvider.task);
                            if (!context.mounted) return;
                            if (aiService.errorMessage != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(aiService.errorMessage!)),
                              );
                            } else if (aiService.currentAnalysis != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RecommendationScreen(),
                                ),
                              );
                            }
                          },
                    child: aiService.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Check for Improvements'),
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TaskInputScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
