import 'package:tarefas_projetocrescer/models/project_category_model.dart';
import 'package:tarefas_projetocrescer/models/project_file_model.dart';
import 'package:tarefas_projetocrescer/models/status.dart';
import 'package:tarefas_projetocrescer/models/user.dart';

class Project {
  final int? id;
  final String name;
  final String fiscalResponsible;
  final Status? status;
  final ProjectCategoryModel? category;
  final int statusId;
  final int categoryId;
  final int createdBy;
  final User? createdByUser;
  final String presentationDate;
  final double presentedValue;
  final String approvalDate;
  final double? approvedValue;
  final String accountabilityDate;
  final String collectionStartDate;
  final String collectionEndDate;
  final double? totalCollected;
  final String executionStartDate;
  final String executionEndDate;
  final String observations;
  final String? color;
  final List<ProjectFile> files;

  Project({
    this.id,
    required this.name,
    required this.fiscalResponsible,
    this.status,
    required this.statusId,
    required this.categoryId,
    required this.createdBy,
    this.createdByUser,
    required this.presentationDate,
    required this.presentedValue,
    required this.approvalDate,
    this.approvedValue,
    required this.accountabilityDate,
    required this.collectionStartDate,
    required this.collectionEndDate,
    this.totalCollected,
    required this.executionStartDate,
    required this.executionEndDate,
    required this.observations,
    required this.color,
    required this.category,
    this.files = const [],
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    double? parseToDouble(dynamic value) {
      if (value == null) return null;
      if (value is String) return double.tryParse(value);
      if (value is num) return value.toDouble();
      return null;
    }

    List<ProjectFile> parseFiles(dynamic fileList) {
      if (fileList != null && fileList is List) {
        return fileList
            .map((fileJson) => ProjectFile.fromJson(fileJson))
            .toList();
      }
      return [];
    }

    return Project(
      id: json['id'],

      name: json['name'] ?? '',
      fiscalResponsible: json['fiscal_responsible'] ?? '',
      status: json['status'] != null ? Status.fromJson(json['status']) : null,
      category: json['category'] != null
          ? ProjectCategoryModel.fromJson(json['category'])
          : null,
      statusId: json['status_id'] ?? 0,
      categoryId: json['project_category_id'] ?? 0,
      createdBy: json['created_by'] ?? 0,
      createdByUser: json['create_by'] != null
          ? User.fromJson(json['create_by'])
          : null,
      presentationDate: json['presentation_date'] ?? '',
      presentedValue: parseToDouble(json['presented_value']) ?? 0.0,
      approvalDate: json['approval_date'] ?? '',
      approvedValue: parseToDouble(json['approved_value']),
      accountabilityDate: json['accountability_date'] ?? '',
      collectionStartDate: json['collection_start_date'] ?? '',
      collectionEndDate: json['collection_end_date'] ?? '',
      totalCollected: parseToDouble(json['total_collected']),
      executionStartDate: json['execution_start_date'] ?? '',
      executionEndDate: json['execution_end_date'] ?? '',
      observations: json['observations'] ?? '',
      color: json['color'] ?? '#FFFFFF',
      files: parseFiles(json['files']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'fiscal_responsible': fiscalResponsible,
      'status_id': statusId,
      'project_category_id': categoryId,
      'presentation_date': presentationDate,
      'presented_value': presentedValue,
      'approval_date': approvalDate,
      'approved_value': approvedValue,
      'accountability_date': accountabilityDate,
      'collection_start_date': collectionStartDate,
      'collection_end_date': collectionEndDate,
      'total_collected': totalCollected,
      'execution_start_date': executionStartDate,
      'execution_end_date': executionEndDate,
      'observations': observations,
      'created_by': createdBy,
      'color': color,
    };
  }

  Project copyWith({
    int? id,
    String? name,
    String? fiscalResponsible,
    Status? status,
    ProjectCategoryModel? category,
    int? statusId,
    int? categoryId,
    int? createdBy,
    User? createdByUser,
    String? presentationDate,
    double? presentedValue,
    String? approvalDate,
    double? approvedValue,
    String? accountabilityDate,
    String? collectionStartDate,
    String? collectionEndDate,
    double? totalCollected,
    String? executionStartDate,
    String? executionEndDate,
    String? observations,
    String? color,
    List<ProjectFile>? files,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      fiscalResponsible: fiscalResponsible ?? this.fiscalResponsible,
      status: status ?? this.status,
      category: category ?? this.category,
      statusId: statusId ?? this.statusId,
      categoryId: categoryId ?? this.categoryId,
      createdBy: createdBy ?? this.createdBy,
      createdByUser: createdByUser ?? this.createdByUser,
      presentationDate: presentationDate ?? this.presentationDate,
      presentedValue: presentedValue ?? this.presentedValue,
      approvalDate: approvalDate ?? this.approvalDate,
      approvedValue: approvedValue ?? this.approvedValue,
      accountabilityDate: accountabilityDate ?? this.accountabilityDate,
      collectionStartDate: collectionStartDate ?? this.collectionStartDate,
      collectionEndDate: collectionEndDate ?? this.collectionEndDate,
      totalCollected: totalCollected ?? this.totalCollected,
      executionStartDate: executionStartDate ?? this.executionStartDate,
      executionEndDate: executionEndDate ?? this.executionEndDate,
      observations: observations ?? this.observations,
      color: color ?? this.color,
      files: files ?? this.files,
    );
  }
}
