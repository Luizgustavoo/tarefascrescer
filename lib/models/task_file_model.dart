// FILE: lib/models/task_file_model.dart

import 'package:flutter/material.dart';

class TaskFile {
  final int id;
  final int taskId;
  final String filename;
  final String filepath;
  final String originalName;
  final String extension;
  final String mimeType;
  final int size;
  final String fileType; // 'image', 'pdf', etc.
  final DateTime createdAt;
  final DateTime updatedAt;

  // ALTERADO: A URL base agora inclui o /storage/
  static const String baseUrl =
      "http://api.tasks.projetocrescerarapongas.org.br/storage";

  // ALTERADO: O getter agora monta a URL corretamente
  // Ex: baseUrl + "/" + filepath  =>  http://.../storage/ + task_files/arquivo.png
  String get fileUrl => "$baseUrl/$filepath";

  TaskFile({
    required this.id,
    required this.taskId,
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

  factory TaskFile.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(String? dateStr) =>
        dateStr == null ? null : DateTime.tryParse(dateStr);
    int parseTaskId(dynamic value) {
      // Pode vir como String ou int
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return TaskFile(
      id: json['id'] ?? 0,
      taskId: parseTaskId(json['task_id']),
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'task_id': taskId,
    'filename': filename,
    'filepath': filepath,
    'original_name': originalName,
    'extension': extension,
    'mime_type': mimeType,
    'size': size,
    'file_type': fileType,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  // Helpers para UI
  IconData get icon {
    if (fileType == 'image') return Icons.image_outlined;
    if (fileType == 'pdf') return Icons.picture_as_pdf_outlined;
    return Icons.insert_drive_file_outlined;
  }
}
