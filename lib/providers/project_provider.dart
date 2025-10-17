import 'package:flutter/material.dart';
import 'package:tarefas_projetocrescer/models/project.dart';
import '../services/project_service.dart';
import 'auth_provider.dart';

class ProjectProvider with ChangeNotifier {
  final ProjectService _service = ProjectService();

  List<Project> _projects = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Project> get projects => _projects;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchProjects(AuthProvider authProvider) async {
    if (!authProvider.isAuthenticated) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _projects = await _service.list(authProvider.token!);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> registerProject(
    Project project,
    AuthProvider authProvider,
  ) async {
    if (!authProvider.isAuthenticated) {
      _errorMessage = "Usuário não autenticado.";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newProjectFromApi = await _service.register(
        project,
        authProvider.token!,
      );

      final completeNewProject = newProjectFromApi.copyWith(
        status: project.status,
      );

      _projects.insert(0, completeNewProject);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
