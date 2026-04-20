import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/task_model.dart';
import '../models/schedule_analysis.dart';

class AiScheduleService extends ChangeNotifier {
  ScheduleAnalysis? _currentAnalysis;
  bool _isLoading = false;
  String? _errorMessage;


  final String _apiKey = 'AIzaSyACA9o3VTFE24FLvsbb7YRfCgAp8TkTRkA';

  ScheduleAnalysis? get currentAnalysis => _currentAnalysis;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> analyzeSchedule(List<TaskModel> tasks) async {
    if (_apiKey.isEmpty || _apiKey.startsWith('YOUR_')) {
      _errorMessage = 'Please provide a valid Gemini API Key in ai_schedule_service.dart';
      notifyListeners();
      return;
    }

    if (tasks.isEmpty) {
      _errorMessage = 'No tasks to analyze';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: _apiKey,
      );

      final taskJson = jsonEncode(tasks.map((e) => e.toJson()).toList());

      final prompt = '''
You are an expert student scheduling assistant. The user has provided the following tasks in JSON format:

$taskJson

Analyze these tasks and provide exactly 4 sections. Use the EXACT headers "### Detected conflicts", "### Ranked Tasks", "### Recommended Schedule", and "### Explanation".

### Detected conflicts
Identify any overlapping times or unreasonable deadlines.

### Ranked Tasks
Prioritize tasks based on urgency (1-5) and importance (1-5).

### Recommended Schedule
Suggest a specific time-blocked schedule for today.

### Explanation
Explain why you organized the schedule this way, considering energy levels and effort.
''';

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      
      if (response.text != null && response.text!.isNotEmpty) {
        _currentAnalysis = _parseResponse(response.text!);
      } else {
        _errorMessage = 'AI returned an empty response.';
      }
    } catch (e) {
      _errorMessage = 'Failed to analyze: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

ScheduleAnalysis _parseResponse(String fullText) {
  String conflicts = 'No conflicts detected.';
  String rankedTasks = 'No ranking provided.';
  String recommendedSchedule = 'No schedule generated.';
  String explanation = 'No explanation provided.';

  // Split by the specific headers used in the prompt
  final sections = fullText.split('###');
  
  for (var section in sections) {
    final trimmed = section.trim();
    if (trimmed.isEmpty) continue;

    if (trimmed.startsWith('Detected conflicts')) {
      conflicts = trimmed.replaceFirst('Detected conflicts', '').trim();
    } else if (trimmed.startsWith('Ranked Tasks')) {
      rankedTasks = trimmed.replaceFirst('Ranked Tasks', '').trim();
    } else if (trimmed.startsWith('Recommended Schedule')) {
      recommendedSchedule = trimmed.replaceFirst('Recommended Schedule', '').trim();
    } else if (trimmed.startsWith('Explanation')) {
      explanation = trimmed.replaceFirst('Explanation', '').trim();
    }
  }

  return ScheduleAnalysis(
    conflicts: conflicts,
    rankedTasks: rankedTasks,
    recommendedSchedule: recommendedSchedule,
    explanation: explanation,
  );
}
