import 'package:flutter/material.dart';
import 'package:tarefas_projetocrescer/utils/formatters.dart';

class GraphDataPoint {
  final String projectName;
  final double approvedValue;
  final Color color;

  GraphDataPoint({
    required this.projectName,
    required this.approvedValue,
    required this.color,
  });

  factory GraphDataPoint.fromJson(Map<String, dynamic> json) {
    double parseValue(dynamic value) {
      if (value is String) return double.tryParse(value) ?? 0.0;
      if (value is num) return value.toDouble();
      return 0.0;
    }

    return GraphDataPoint(
      projectName: json['project_name'] ?? 'Desconhecido',
      approvedValue: parseValue(json['approved_value']),

      color: Formatters.colorFromHex(json['color'], defaultColor: Colors.grey),
    );
  }
}
