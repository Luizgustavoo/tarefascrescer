// FILE: lib/providers/project_filter_provider.dart

import 'package:flutter/material.dart';
import 'package:tarefas_projetocrescer/models/project.dart';
import 'package:tarefas_projetocrescer/services/project_service.dart';
import 'auth_provider.dart';

class ProjectFilterProvider with ChangeNotifier {
  final ProjectService _service = ProjectService();

  List<Project> _filteredProjects = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Project> get filteredProjects => _filteredProjects;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchProjectsByStatus(
    int statusId,
    AuthProvider authProvider,
  ) async {
    if (!authProvider.isAuthenticated) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _filteredProjects = await _service.listByStatus(
        statusId,
        authProvider.token!,
      );
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _filteredProjects = []; // Limpa em caso de erro
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
