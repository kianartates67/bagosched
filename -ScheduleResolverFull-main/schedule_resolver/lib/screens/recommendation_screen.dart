import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ai_schedule_service.dart';

class RecommendationScreen extends StatelessWidget {
  const RecommendationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final aiService = Provider.of<AiScheduleService>(context);
    final analysis = aiService.currentAnalysis;

    if (analysis == null) return const Scaffold(body: Center(child: Text('No Data')));

    return Scaffold(
      appBar: AppBar(title: const Text('AI Schedule Recommendation')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSection(context, 'Detected Conflicts', analysis.conflicts, Colors.red.shade100, Icons.warning_amber_rounded),
            _buildSection(context, 'Ranked Task', analysis.rankedTasks, const Color.fromARGB(255, 4, 4, 126), Icons.format_list_numbered),
            _buildSection(context, 'Recommended Schedule', analysis.recommendedSchedule, const Color.fromARGB(255, 4, 126, 8), Icons.calendar_today),
            _buildSection(context, 'Explanation', analysis.explanation, const Color.fromARGB(255, 169, 69, 8), Icons.lightbulb_outline),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content, Color color, IconData icon) {
    return Card(
      color: color,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 28),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(),
            Text(content, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
