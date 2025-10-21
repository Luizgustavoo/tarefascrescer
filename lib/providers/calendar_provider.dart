import 'package:flutter/material.dart';
import 'package:tarefas_projetocrescer/models/task.dart';
import 'package:tarefas_projetocrescer/services/task_service.dart';
import 'auth_provider.dart';
import 'package:collection/collection.dart';

class CalendarProvider with ChangeNotifier {
  final TaskService _taskService = TaskService();

  Map<DateTime, List<Task>> _monthlyTasks = {};
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _currentlyLoadedMonth;

  Map<DateTime, List<Task>> get monthlyTasks => _monthlyTasks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchTasksForMonth(
    DateTime month,
    AuthProvider authProvider,
  ) async {
    if (!authProvider.isAuthenticated) return;

    if (_currentlyLoadedMonth != null &&
        _currentlyLoadedMonth!.year == month.year &&
        _currentlyLoadedMonth!.month == month.month) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetchedTasks = await _taskService.listByMonth(
        month.month,
        month.year,
        authProvider.token!,
      );

      _monthlyTasks = groupBy(fetchedTasks, (Task task) {
        return DateTime.utc(
          task.scheduledAt.year,
          task.scheduledAt.month,
          task.scheduledAt.day,
        );
      });

      _currentlyLoadedMonth = DateTime(month.year, month.month);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _monthlyTasks = {};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Task> getEventsForDay(DateTime day) {
    final normalizedDay = DateTime.utc(day.year, day.month, day.day);
    return _monthlyTasks[normalizedDay] ?? [];
  }
}
