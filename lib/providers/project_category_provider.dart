// FILE: lib/providers/task_status_provider.dart

import 'package:flutter/material.dart';
import 'package:tarefas_projetocrescer/models/project_category_model.dart';
import 'package:tarefas_projetocrescer/models/status.dart';
import 'package:tarefas_projetocrescer/services/project_category_service.dart';
import 'package:tarefas_projetocrescer/services/task_status_service.dart';
import 'auth_provider.dart';

class ProjectCategoryProvidser with ChangeNotifier {
  final ProjectCategoryService _service = ProjectCategoryService();

  List<ProjectCategoryModel> _projectCategories = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ProjectCategoryModel> get categories => _projectCategories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchCategories(AuthProvider authProvider) async {
    if (!authProvider.isAuthenticated) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _projectCategories = await _service.list(authProvider.token!);
    } catch (e) {
      print(e.toString());
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ProjectCategoryModel?> registerCategory(
    String name,
    AuthProvider authProvider,
  ) async {
    if (!authProvider.isAuthenticated) return null;

    _isLoading = true;
    notifyListeners();

    try {
      final category = await _service.register(name, authProvider.token!);
      _projectCategories.add(category);
      _projectCategories.sort((a, b) => a.name.compareTo(b.name));
      _isLoading = false;
      notifyListeners();
      return category;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
}
