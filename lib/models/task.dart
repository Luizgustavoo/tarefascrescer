import 'package:intl/intl.dart';
import 'package:tarefas_projetocrescer/models/project.dart';
import 'package:tarefas_projetocrescer/models/status.dart';

class Task {
  final int? id;
  final int projectId;
  final int statusId;
  final DateTime scheduledAt;
  final String description;
  final String color;
  final int createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Status? status;
  final Project? project;
  final List<dynamic> attachments;

  Task({
    this.id,
    required this.projectId,
    required this.statusId,
    required this.createdBy,
    required this.scheduledAt,
    required this.description,
    required this.color,
    required this.createdAt,
    required this.updatedAt,
    this.status,
    this.project,
    this.attachments = const [],
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(String? dateStr) {
      if (dateStr == null) return null;
      return DateTime.tryParse(dateStr);
    }

    return Task(
      id: json['id'] ?? 0,
      projectId: json['project_id'] ?? 0,
      statusId: json['status_id'] ?? 0,
      scheduledAt: parseDate(json['scheduled_at']) ?? DateTime.now(),
      description: json['description'] ?? '',
      color: json['color'] ?? '#FFFFFF',
      createdAt: parseDate(json['created_at']) ?? DateTime.now(),
      updatedAt: parseDate(json['updated_at']) ?? DateTime.now(),
      status: json['status'] != null ? Status.fromJson(json['status']) : null,
      project: json['project'] != null
          ? Project.fromJson(json['project'])
          : null,
      attachments: json['attachments'] ?? [],
      createdBy: json['created_by'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'project_id': projectId,
      'status_id': statusId,
      'scheduled_at': DateFormat('yyyy-MM-dd HH:mm:ss').format(scheduledAt),
      'description': description,
      'created_by': createdBy,
      'color': color,
    };
  }

  Task copyWith({
    int? id,
    int? projectId,
    int? statusId,
    int? createdBy,
    DateTime? scheduledAt,
    String? description,
    String? color,
    DateTime? createdAt,
    DateTime? updatedAt,
    Status? status,
    List<dynamic>? attachments,
  }) {
    return Task(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      statusId: statusId ?? this.statusId,
      createdBy: createdBy ?? this.createdBy,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      description: description ?? this.description,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      attachments: attachments ?? this.attachments,
    );
  }
}
