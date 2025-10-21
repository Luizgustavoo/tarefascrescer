import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tarefas_projetocrescer/models/status.dart';
import 'api_service.dart';

class ProjectStatusService {
  Future<List<Status>> list(String token) async {
    final url = Uri.parse('${ApiService.baseUrl}/project-statuses/list');
    try {
      final response = await http.get(
        url,
        headers: ApiService.getHeaders(authToken: token),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedBody = jsonDecode(response.body);

        if (decodedBody.containsKey('data') && decodedBody['data'] is List) {
          final List<dynamic> dataList = decodedBody['data'];

          return dataList.map((json) => Status.fromJson(json)).toList();
        } else {
          throw Exception(
            'Formato de resposta da API inesperado. A lista de status não foi encontrada.',
          );
        }
      } else {
        throw Exception('Falha ao carregar a lista de status.');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Status> register(String name, String token) async {
    final url = Uri.parse('${ApiService.baseUrl}/project-statuses/register');
    try {
      final response = await http.post(
        url,
        headers: ApiService.getHeaders(authToken: token),
        body: jsonEncode({'name': name}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> decodedBody = jsonDecode(response.body);

        if (decodedBody.containsKey('data') &&
            decodedBody['data'] is Map<String, dynamic>) {
          return Status.fromJson(decodedBody['data']);
        } else {
          return Status.fromJson(decodedBody);
        }
      } else {
        if (response.body.isNotEmpty) {
          final errorData = jsonDecode(response.body);
          throw Exception(
            errorData['message'] ?? 'Falha ao cadastrar o novo status.',
          );
        }
        throw Exception('Falha ao cadastrar o novo status.');
      }
    } catch (e) {
      rethrow;
    }
  }
}
