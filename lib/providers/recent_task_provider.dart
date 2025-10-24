import 'package:flutter/material.dart';
import 'package:tarefas_projetocrescer/models/task.dart';
import 'package:tarefas_projetocrescer/services/recent_task_service.dart';
import 'auth_provider.dart';

class RecentTaskProvider with ChangeNotifier {
  final RecentTaskService _service = RecentTaskService();

  List<Task> _recentTasks = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Task> get recentTasks => List.unmodifiable(_recentTasks);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchRecentTasks(AuthProvider authProvider) async {
    if (!authProvider.isAuthenticated) return;

    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _recentTasks = await _service.listRecents(authProvider.token!);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _recentTasks = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
