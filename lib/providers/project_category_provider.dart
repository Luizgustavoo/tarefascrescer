import 'package:flutter/material.dart';
import 'package:tarefas_projetocrescer/models/project.dart';
import 'package:tarefas_projetocrescer/models/project_category_model.dart';
import 'package:tarefas_projetocrescer/services/project_category_service.dart';
import 'package:tarefas_projetocrescer/services/project_service.dart';
import 'auth_provider.dart';

class ProjectCategoryProvider with ChangeNotifier {
  final ProjectCategoryService _service = ProjectCategoryService();
  final ProjectService _projectService = ProjectService();

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

  Future<bool> updateCategory(
    int categoryId,
    String newName,
    AuthProvider authProvider,
  ) async {
    if (!authProvider.isAuthenticated) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final index = _projectCategories.indexWhere((c) => c.id == categoryId);
      if (index == -1) {
        throw Exception("Categoria não encontrada para atualizar.");
      }

      final List<Project> oldProjects = _projectCategories[index].projects;

      final updatedCategoryFromApi = await _service.update(
        categoryId,
        newName,
        authProvider.token!,
      );

      final ProjectCategoryModel completeUpdatedCategory =
          updatedCategoryFromApi.copyWith(projects: oldProjects);

      _projectCategories.removeAt(index);

      _projectCategories.insert(0, completeUpdatedCategory);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCategory(int categoryId, AuthProvider authProvider) async {
    if (!authProvider.isAuthenticated) {
      _errorMessage = "Usuário não autenticado.";
      return false;
    }

    _errorMessage = null;
    notifyListeners();

    try {
      await _service.delete(categoryId, authProvider.token!);

      _projectCategories.removeWhere((c) => c.id == categoryId);

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProject(Project project, AuthProvider authProvider) async {
    if (!authProvider.isAuthenticated || project.id == null) return false;

    _isLoading = true; // Mostra loading (opcional, pode ser granular)
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Chama a API para deletar o projeto
      await _projectService.delete(project.id!, authProvider.token!);

      // 2. Encontra a categoria à qual o projeto pertence
      ProjectCategoryModel? targetCategory;
      for (var category in _projectCategories) {
        // A API de listagem de categoria precisa retornar project_category_id no projeto
        // ou teremos que assumir o ID da categoria que estamos
        if (category.id == project.categoryId) {
          // Assumindo que o Project Model tem categoryId
          targetCategory = category;
          break;
        }
      }

      // 3. Remove o projeto da lista local NAQUELE objeto de categoria
      if (targetCategory != null) {
        targetCategory.projects.removeWhere((p) => p.id == project.id);
      } else {
        // Se não encontrar, apenas recarrega tudo por segurança
        await fetchCategories(authProvider);
      }

      _isLoading = false;
      notifyListeners(); // 4. Notifica a HomeScreen e a ProjectListScreen
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
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
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newProjectFromApi = await _projectService.register(
        project,
        authProvider.token!,
      );

      // ## CORREÇÃO AQUI ##
      // Embrulha os objetos em uma função () => ...
      final completeNewProject = newProjectFromApi.copyWith(
        status: project.status,
        category: project.category,
      );

      final index = _projectCategories.indexWhere(
        (c) => c.id == completeNewProject.categoryId,
      );

      if (index != -1) {
        _projectCategories[index].projects.insert(0, completeNewProject);
      } else {
        await fetchCategories(authProvider);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProject(Project project, AuthProvider authProvider) async {
    if (!authProvider.isAuthenticated) return false;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedProjectFromApi = await _projectService.update(
        project,
        authProvider.token!,
      );

      // ## CORREÇÃO AQUI ##
      // Embrulha os objetos em uma função () => ...
      final completeUpdatedProject = updatedProjectFromApi.copyWith(
        status: project.status,
        category: project.category,
      );

      final category = _projectCategories.firstWhere(
        (c) => c.id == completeUpdatedProject.categoryId,
      );
      final projectIndex = category.projects.indexWhere(
        (p) => p.id == completeUpdatedProject.id,
      );

      if (projectIndex != -1) {
        category.projects[projectIndex] = completeUpdatedProject;
      } else {
        await fetchCategories(authProvider);
      }

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
