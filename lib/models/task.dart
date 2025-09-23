import 'dart:io';

class Task {
  final String id;
  final String description;
  String status;
  final DateTime createdAt;
  List<File> attachments;

  Task({
    required this.id,
    required this.description,
    required this.status,
    required this.createdAt,
    this.attachments = const [],
  });
}
