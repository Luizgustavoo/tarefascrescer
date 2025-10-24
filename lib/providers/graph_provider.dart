// FILE: lib/providers/graph_provider.dart

import 'package:flutter/material.dart';
import 'package:tarefas_projetocrescer/models/graph_data_model.dart';
import 'package:tarefas_projetocrescer/services/graph_service.dart';
import 'auth_provider.dart';

class GraphProvider with ChangeNotifier {
  final GraphService _service = GraphService();

  List<GraphDataPoint> _graphData = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<GraphDataPoint> get graphData => _graphData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchGraphData(AuthProvider authProvider) async {
    if (!authProvider.isAuthenticated) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _graphData = await _service.getGraphData(authProvider.token!);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _graphData = []; // Limpa em caso de erro
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
