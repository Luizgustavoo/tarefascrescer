// FILE: lib/providers/task_file_provider.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tarefas_projetocrescer/models/task_file_model.dart'; // Ajuste o import
import 'package:tarefas_projetocrescer/services/task_file_service.dart'; // Ajuste o import
import 'auth_provider.dart';

class TaskFileProvider with ChangeNotifier {
  final TaskFileService _service = TaskFileService();

  // Armazena os arquivos por ID da tarefa
  final Map<int, List<TaskFile>> _taskFiles = {};
  final Map<int, bool> _isLoadingFiles = {};
  final Map<int, String?> _errorLoadingFiles = {};

  bool _isUploading = false;
  String? _uploadError;

  // Getters
  List<TaskFile> getFilesForTask(int taskId) => _taskFiles[taskId] ?? [];
  bool isLoadingFiles(int taskId) => _isLoadingFiles[taskId] ?? false;
  String? getFileLoadingError(int taskId) => _errorLoadingFiles[taskId];
  bool get isUploading => _isUploading;
  String? get uploadError => _uploadError;

  // Carrega os arquivos para UMA tarefa específica
  Future<void> fetchFiles(int taskId, AuthProvider authProvider) async {
    if (!authProvider.isAuthenticated) return;

    _isLoadingFiles[taskId] = true;
    _errorLoadingFiles[taskId] = null;
    notifyListeners();

    try {
      final files = await _service.listFiles(taskId, authProvider.token!);
      _taskFiles[taskId] = files;
    } catch (e) {
      _errorLoadingFiles[taskId] = e.toString().replaceFirst('Exception: ', '');
      _taskFiles[taskId] = []; // Limpa em caso de erro
    } finally {
      _isLoadingFiles[taskId] = false;
      notifyListeners();
    }
  }

  // Faz upload de um arquivo para UMA tarefa
  Future<bool> uploadFile(
    int taskId,
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
      final newFile = await _service.upload(taskId, file, authProvider.token!);

      // Adiciona o novo arquivo à lista local da tarefa correspondente
      _taskFiles[taskId] ??= []; // Garante que a lista exista
      _taskFiles[taskId]!.insert(0, newFile); // Adiciona no início

      _isUploading = false;
      notifyListeners(); // Notifica sobre o fim do upload e a atualização da lista
      return true;
    } catch (e) {
      _uploadError = e.toString().replaceFirst('Exception: ', '');
      _isUploading = false;
      notifyListeners();
      return false;
    }
  }

  // --- Futuro: Método para deletar um arquivo ---
  // Future<bool> deleteFile(int taskId, int fileId, AuthProvider authProvider) async { ... }
}
