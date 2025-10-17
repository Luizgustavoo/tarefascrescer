import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tarefas_projetocrescer/models/task.dart';
import 'api_service.dart';

class TaskService {
  Future<List<Task>> list(int projectId, String token) async {
    final url = Uri.parse('${ApiService.baseUrl}/tasks/list/$projectId');
    try {
      final response = await http.get(
        url,
        headers: ApiService.getHeaders(authToken: token),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedBody = jsonDecode(response.body);
        if (decodedBody.containsKey('data') && decodedBody['data'] is List) {
          final List<dynamic> dataList = decodedBody['data'];
          return dataList.map((json) => Task.fromJson(json)).toList();
        } else {
          final List<dynamic> dataList = jsonDecode(response.body);
          return dataList.map((json) => Task.fromJson(json)).toList();
        }
      } else {
        throw Exception('Falha ao carregar a lista de tarefas.');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Task> register(Task task, String token) async {
    final url = Uri.parse('${ApiService.baseUrl}/tasks/register');
    try {
      final response = await http.post(
        url,
        headers: ApiService.getHeaders(authToken: token),
        body: jsonEncode(task.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> decodedBody = jsonDecode(response.body);
        if (decodedBody.containsKey('data')) {
          return Task.fromJson(decodedBody['data']);
        } else {
          throw Exception('Resposta da API de cadastro de tarefa inesperada.');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Falha ao cadastrar a tarefa.');
      }
    } catch (e) {
      rethrow;
    }
  }
}
