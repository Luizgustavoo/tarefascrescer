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

  Future<bool> deleteProject(int projectId, AuthProvider authProvider) async {
    if (!authProvider.isAuthenticated) return false;

    _errorMessage = null;

    notifyListeners();

    try {
      await _service.delete(projectId, authProvider.token!);

      _projects.removeWhere((project) => project.id == projectId);

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProject(Project project, AuthProvider authProvider) async {
    if (!authProvider.isAuthenticated) return false;

    _errorMessage = null;
    notifyListeners();

    try {
      final updatedProjectFromApi = await _service.update(
        project,
        authProvider.token!,
      );

      final completeUpdatedProject = updatedProjectFromApi.copyWith(
        status: project.status,
      );

      final index = _projects.indexWhere(
        (p) => p.id == completeUpdatedProject.id,
      );
      if (index != -1) {
        _projects[index] = completeUpdatedProject;
        notifyListeners();
      } else {
        await fetchProjects(authProvider);
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
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
