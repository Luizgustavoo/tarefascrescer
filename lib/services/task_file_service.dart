import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:async/async.dart';
import 'package:path/path.dart';
import 'package:tarefas_projetocrescer/models/task_file_model.dart';
import 'api_service.dart';

class TaskFileService {
  Future<List<TaskFile>> listFiles(int taskId, String token) async {
    final url = Uri.parse('${ApiService.baseUrl}/task-files/$taskId');
    try {
      final response = await http.get(
        url,
        headers: ApiService.getHeaders(authToken: token),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedBody = jsonDecode(response.body);

        if (decodedBody.containsKey('data') && decodedBody['data'] is List) {
          final List<dynamic> dataList = decodedBody['data'];

          return dataList.map((json) => TaskFile.fromJson(json)).toList();
        } else {
          try {
            final List<dynamic> dataList = jsonDecode(response.body);
            return dataList.map((json) => TaskFile.fromJson(json)).toList();
          } catch (e) {
            throw Exception(
              'Formato de resposta da API de arquivos inesperado.',
            );
          }
        }
      } else {
        throw Exception('Falha ao carregar arquivos da tarefa.');
      }
    } catch (e) {
      print("Erro em TaskFileService.listFiles: $e");
      rethrow;
    }
  }

  Future<TaskFile> upload(int taskId, File file, String token) async {
    final url = Uri.parse('${ApiService.baseUrl}/task-files/upload');

    try {
      var request = http.MultipartRequest('POST', url);
      request.headers.addAll(ApiService.getHeaders(authToken: token));

      request.fields['task_id'] = taskId.toString();

      var stream = http.ByteStream(DelegatingStream.typed(file.openRead()));
      var length = await file.length();
      var multipartFile = http.MultipartFile(
        'file',
        stream,
        length,
        filename: basename(file.path),
      );
      request.files.add(multipartFile);

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> decodedBody = jsonDecode(response.body);
        if (decodedBody.containsKey('data')) {
          return TaskFile.fromJson(decodedBody['data']);
        } else {
          throw Exception('Resposta da API de upload (task file) inesperada.');
        }
      } else {
        String errorMessage = 'Falha no upload do arquivo.';
        if (response.body.isNotEmpty) {
          try {
            final errorData = jsonDecode(response.body);
            errorMessage = errorData['message'] ?? errorMessage;
            if (errorData['errors'] != null)
              errorMessage += '\n${errorData['errors']}';
          } catch (_) {}
        }
        print(
          "Erro Upload Task File: ${response.statusCode} - ${response.body}",
        );
        throw Exception(errorMessage);
      }
    } catch (e) {
      print("Erro em TaskFileService.upload: $e");
      rethrow;
    }
  }
}
