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

  Future<bool> registerTask(Task task, AuthProvider authProvider) async {
    if (!authProvider.isAuthenticated) return false;

    _errorMessage = null;
    // Não ativamos o isLoading para uma UI mais fluida

    try {
      // 1. Envia a tarefa para a API. O objeto 'task' aqui tem o objeto Status completo.
      final newTaskFromApi = await _service.register(task, authProvider.token!);

      // 2. 'newTaskFromApi' tem o ID e timestamps corretos, mas 'status' é nulo.
      //    Criamos uma versão final combinando os dados da API com o objeto Status que já tínhamos.
      final completeNewTask = newTaskFromApi.copyWith(status: task.status);

      // 3. Adiciona a tarefa completa à lista local.
      _tasks.insert(0, completeNewTask);

      notifyListeners(); // Notifica a UI que a lista foi atualizada com o objeto completo.
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
