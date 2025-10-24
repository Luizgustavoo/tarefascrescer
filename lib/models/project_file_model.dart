// FILE: lib/models/project_file_model.dart

import 'package:flutter/material.dart';

class ProjectFile {
  final int id;
  final int projectId;
  final String filename;
  final String filepath;
  final String originalName;
  final String extension;
  final String mimeType;
  final int size;
  final String fileType;
  final DateTime createdAt;
  final DateTime updatedAt;

  // URL base para visualização
  static const String baseUrl =
      "http://api.tasks.projetocrescerarapongas.org.br/storage";
  String get fileUrl => "$baseUrl/$filepath";

  ProjectFile({
    required this.id,
    required this.projectId,
    required this.filename,
    required this.filepath,
    required this.originalName,
    required this.extension,
    required this.mimeType,
    required this.size,
    required this.fileType,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProjectFile.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(String? dateStr) =>
        dateStr == null ? null : DateTime.tryParse(dateStr);
    int parseProjectId(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return ProjectFile(
      id: json['id'] ?? 0,
      projectId: parseProjectId(json['project_id']),
      filename: json['filename'] ?? '',
      filepath: json['filepath'] ?? '',
      originalName: json['original_name'] ?? '',
      extension: json['extension'] ?? '',
      mimeType: json['mime_type'] ?? '',
      size: json['size'] ?? 0,
      fileType: json['file_type'] ?? 'unknown',
      createdAt: parseDate(json['created_at']) ?? DateTime.now(),
      updatedAt: parseDate(json['updated_at']) ?? DateTime.now(),
    );
  }

  IconData get icon {
    if (fileType == 'image') return Icons.image_outlined;
    if (extension == 'pdf') return Icons.picture_as_pdf_outlined;
    return Icons.insert_drive_file_outlined;
  }
}
