import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tarefas_projetocrescer/models/project.dart';
import 'package:tarefas_projetocrescer/models/project_category_model.dart';
import 'package:tarefas_projetocrescer/providers/auth_provider.dart';
import 'package:tarefas_projetocrescer/providers/project_category_provider.dart';
import 'package:tarefas_projetocrescer/providers/project_file_provider.dart';
import 'package:tarefas_projetocrescer/screens/widgets/add_project_modal.dart';
import 'package:tarefas_projetocrescer/screens/widgets/project_card.dart';

class ProjectListScreen extends StatefulWidget {
  final ProjectCategoryModel category;

  const ProjectListScreen({super.key, required this.category});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  late List<Project> _projects;

  @override
  void initState() {
    super.initState();

    _projects = widget.category.projects;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    try {
      final categoryProvider = context.watch<ProjectCategoryProvider>();
      final updatedCategory = categoryProvider.categories.firstWhere(
        (c) => c.id == widget.category.id,
      );
      _projects = updatedCategory.projects;
    } catch (e) {
      _projects = [];
    }
  }

  void _showEditProjectModal(BuildContext context, Project projectToEdit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Container(
          color: const Color(0xFFF8F8FA),

          child: AddProjectModal(projectToEdit: projectToEdit),
        ),
      ),
    );
  }

  Future<void> _confirmAndDeleteProject(Project project) async {
    if (project.id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text(
          'Tem certeza que deseja excluir o projeto "${project.name}"? Esta ação não pode ser desfeita.',
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final categoryProvider = context.read<ProjectCategoryProvider>();
      final authProvider = context.read<AuthProvider>();

      final success = await categoryProvider.deleteProject(
        project,
        authProvider,
      );

      if (mounted && !success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              categoryProvider.errorMessage ?? 'Falha ao excluir projeto.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      } else if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Projeto excluído!'),
            backgroundColor: Colors.green,
          ),
        );

        if (_projects.isEmpty && mounted) {
          Navigator.of(context).pop();
        }
      }
    }
  }

  Future<void> _pickAndUploadFile(Project project) async {
    if (project.id == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ID do Projeto inválido.')));
      return;
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null && result.files.single.path != null && mounted) {
      File file = File(result.files.single.path!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Enviando ${result.files.single.name}...')),
      );

      final fileProvider = context.read<ProjectFileProvider>();
      final authProvider = context.read<AuthProvider>();

      final success = await fileProvider.uploadFile(
        project.id!,
        file,
        authProvider,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Arquivo anexado ao projeto!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(fileProvider.uploadError ?? 'Falha no upload.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Seleção cancelada.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.category.name)),
      body: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: widget.category.projects.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final project = widget.category.projects[index];
          final cardColor = index.isEven
              ? Colors.white
              : const Color(0xFFFFF1F3);

          return ProjectCard(
            project: project,
            backgroundColor: cardColor,
            onEdit: () => _showEditProjectModal(context, project),
            onDelete: () => _confirmAndDeleteProject(project),
            onAttach: () => _pickAndUploadFile(project),
          );
        },
      ),
    );
  }
}
