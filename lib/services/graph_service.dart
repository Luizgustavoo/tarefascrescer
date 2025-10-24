import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tarefas_projetocrescer/models/graph_data_model.dart';
import 'api_service.dart';

class GraphService {
  Future<List<GraphDataPoint>> getGraphData(String token) async {
    final url = Uri.parse(
      '${ApiService.baseUrl}/projects/graph-approved-values',
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

          return dataList.map((json) => GraphDataPoint.fromJson(json)).toList();
        } else {
          throw Exception('Formato de resposta da API do gráfico inesperado.');
        }
      } else {
        throw Exception(
          'Falha ao carregar dados do gráfico. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print("Erro em GraphService.getGraphData: $e");
      rethrow;
    }
  }
}
