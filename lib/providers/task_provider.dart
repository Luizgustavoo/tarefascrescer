import 'package:flutter/material.dart';
import 'package:tarefas_projetocrescer/models/task.dart';
import 'package:tarefas_projetocrescer/services/task_service.dart';
import 'auth_provider.dart';

class TaskProvider with ChangeNotifier {
  final TaskService _service = TaskService();

  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchTasks(int projectId, AuthProvider authProvider) async {
    if (!authProvider.isAuthenticated) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _tasks = await _service.list(projectId, authProvider.token!);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteTask(int taskId, AuthProvider authProvider) async {
    if (!authProvider.isAuthenticated) return false;

    _errorMessage = null;

    notifyListeners();

    try {
      await _service.delete(taskId, authProvider.token!);

      _tasks.removeWhere((task) => task.id == taskId);

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTask(Task task, AuthProvider authProvider) async {
    if (!authProvider.isAuthenticated) return false;

    _errorMessage = null;
    notifyListeners();

    try {
      final updatedTaskFromApi = await _service.update(
        task,
        authProvider.token!,
      );

      final completeUpdatedTask = updatedTaskFromApi.copyWith(
        status: task.status,
      );

      final index = _tasks.indexWhere((t) => t.id == completeUpdatedTask.id);
      if (index != -1) {
        _tasks[index] = completeUpdatedTask;
        notifyListeners();
      } else {
        await fetchTasks(task.projectId, authProvider);
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> registerTask(Task task, AuthProvider authProvider) async {
    if (!authProvider.isAuthenticated) return false;

    _errorMessage = null;

    try {
      final newTaskFromApi = await _service.register(task, authProvider.token!);

      final completeNewTask = newTaskFromApi.copyWith(status: task.status);

      _tasks.insert(0, completeNewTask);

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
