import 'package:flutter/material.dart';
import 'package:tarefas_projetocrescer/models/status.dart';
import 'package:tarefas_projetocrescer/services/status_service.dart';

import 'auth_provider.dart';

class ProjectStatusProvider with ChangeNotifier {
  final StatusService _service = StatusService();

  List<Status> _statuses = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Status> get statuses => _statuses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchStatuses(AuthProvider authProvider) async {
    if (!authProvider.isAuthenticated) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _statuses = await _service.list(authProvider.token!);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Status?> registerStatus(String name, AuthProvider authProvider) async {
    if (!authProvider.isAuthenticated) return null;

    _isLoading = true;
    notifyListeners();

    try {
      final newStatus = await _service.register(name, authProvider.token!);

      _statuses.add(newStatus);

      _statuses.sort((a, b) => a.name.compareTo(b.name));

      _isLoading = false;
      notifyListeners();

      return newStatus;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
}
