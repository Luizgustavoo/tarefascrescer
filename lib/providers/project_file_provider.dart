// FILE: lib/providers/project_file_provider.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tarefas_projetocrescer/models/project_file_model.dart'; // Ajuste o import
import 'package:tarefas_projetocrescer/services/project_file_service.dart'; // Ajuste o import
import 'auth_provider.dart';

class ProjectFileProvider with ChangeNotifier {
  final ProjectFileService _service = ProjectFileService();

  // Armazena os arquivos por ID do PROJETO
  final Map<int, List<ProjectFile>> _projectFiles = {};
  final Map<int, bool> _isLoadingFiles = {};
  final Map<int, String?> _errorLoadingFiles = {};

  bool _isUploading = false;
  String? _uploadError;

  // Getters
  List<ProjectFile> getFilesForProject(int projectId) =>
      _projectFiles[projectId] ?? [];
  bool isLoadingFiles(int projectId) => _isLoadingFiles[projectId] ?? false;
  String? getFileLoadingError(int projectId) => _errorLoadingFiles[projectId];
  bool get isUploading => _isUploading;
  String? get uploadError => _uploadError;

  // Carrega os arquivos para UM projeto específico
  Future<void> fetchFiles(int projectId, AuthProvider authProvider) async {
    if (!authProvider.isAuthenticated) return;

    _isLoadingFiles[projectId] = true;
    _errorLoadingFiles[projectId] = null;
    notifyListeners();

    try {
      final files = await _service.listFiles(projectId, authProvider.token!);
      _projectFiles[projectId] = files;
    } catch (e) {
      _errorLoadingFiles[projectId] = e.toString().replaceFirst(
        'Exception: ',
        '',
      );
      _projectFiles[projectId] = []; // Limpa em caso de erro
    } finally {
      _isLoadingFiles[projectId] = false;
      notifyListeners();
    }
  }

  // Faz upload de um arquivo para UM projeto
  Future<bool> uploadFile(
    int projectId,
    File file,
    AuthProvider authProvider,
  ) async {
    if (!authProvider.isAuthenticated) {
      _uploadError = "Usuário não autenticado.";
      notifyListeners();
      return false;
    }

    _isUploading = true;
    _uploadError = null;
    notifyListeners();

    try {
      final newFile = await _service.upload(
        projectId,
        file,
        authProvider.token!,
      );
      _projectFiles[projectId] ??= [];
      _projectFiles[projectId]!.insert(0, newFile);

      _isUploading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _uploadError = e.toString().replaceFirst('Exception: ', '');
      _isUploading = false;
      notifyListeners();
      return false;
    }
  }
}
