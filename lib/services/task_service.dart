import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tarefas_projetocrescer/models/task.dart';
import 'api_service.dart';

class TaskService {
  Future<List<Task>> listByMonth(int month, int year, String token) async {
    final url = Uri.parse(
      '${ApiService.baseUrl}/tasks/by-month?month=$month&year=$year',
    );
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
          throw Exception(
            'Formato de resposta da API de tarefas por mês inesperado.',
          );
        }
      } else {
        throw Exception('Falha ao carregar a lista de tarefas por mês.');
      }
    } catch (e) {
      print("Erro ao buscar tarefas por mês: $e");
      rethrow;
    }
  }

  Future<Task> update(Task task, String token) async {
    if (task.id == 0) {
      throw Exception("ID da tarefa inválido para atualização.");
    }
    final url = Uri.parse('${ApiService.baseUrl}/tasks/update/${task.id}');
    try {
      final response = await http.put(
        url,
        headers: ApiService.getHeaders(authToken: token),

        body: jsonEncode(task.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedBody = jsonDecode(response.body);

        if (decodedBody.containsKey('data')) {
          return Task.fromJson(decodedBody['data']);
        } else {
          return Task.fromJson(decodedBody);
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Falha ao atualizar a tarefa.');
      }
    } catch (e) {
      rethrow;
    }
  }

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
