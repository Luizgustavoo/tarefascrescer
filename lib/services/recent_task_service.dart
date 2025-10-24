// FILE: lib/services/recent_task_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tarefas_projetocrescer/models/task.dart'; // Ajuste o import
import 'api_service.dart';

class RecentTaskService {
  Future<List<Task>> listRecents(String token) async {
    final url = Uri.parse('${ApiService.baseUrl}/tasks/list-recents');
    try {
      final response = await http.get(
        url,
        headers: ApiService.getHeaders(authToken: token),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedBody = jsonDecode(response.body);
        if (decodedBody.containsKey('data') && decodedBody['data'] is List) {
          final List<dynamic> dataList = decodedBody['data'];
          // Mapeia a lista JSON para a lista de objetos Task
          return dataList.map((json) => Task.fromJson(json)).toList();
        } else {
          // Fallback: Tenta decodificar como uma lista direta, caso a API mude
          try {
            final List<dynamic> dataList = jsonDecode(response.body);
            return dataList.map((json) => Task.fromJson(json)).toList();
          } catch (_) {
            throw Exception(
              'Formato de resposta da API de tarefas recentes inesperado.',
            );
          }
        }
      } else {
        throw Exception(
          'Falha ao carregar tarefas recentes. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print("Erro em RecentTaskService.listRecents: $e");
      rethrow;
    }
  }
}
