import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tarefas_projetocrescer/models/project.dart';
import 'package:tarefas_projetocrescer/models/status.dart';
import 'package:tarefas_projetocrescer/models/task.dart';
import 'package:tarefas_projetocrescer/models/task_file_model.dart';
import 'package:tarefas_projetocrescer/providers/auth_provider.dart';
import 'package:tarefas_projetocrescer/providers/task_file_provider.dart';
import 'package:tarefas_projetocrescer/providers/task_provider.dart';
import 'package:tarefas_projetocrescer/screens/widgets/add_task_modal.dart';
import 'package:tarefas_projetocrescer/screens/widgets/pdf_viewer_screen.dart';
import 'package:tarefas_projetocrescer/utils/formatters.dart';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final Project project;
  const ProjectDetailsScreen({super.key, required this.project});

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  bool _isSummaryExpanded = false;
  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final authProvider = context.read<AuthProvider>();
      final taskProvider = context.read<TaskProvider>();
      final fileProvider = context.read<TaskFileProvider>();

      if (widget.project.id != null) {
        await taskProvider.fetchTasks(widget.project.id!, authProvider);

        if (mounted) {
          for (final task in taskProvider.tasks) {
            fileProvider.fetchFiles(task.id!, authProvider);
          }
        }
      }
    });
  }

  Future<void> _addTask(
    String description,
    Status status,
    DateTime createdAt,
    String color,
  ) async {
    final authProvider = context.read<AuthProvider>();
    final taskProvider = context.read<TaskProvider>();

    if (widget.project.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro: ID do projeto não encontrado.')),
      );
      return;
    }

    if (authProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro: Usuário não autenticado.')),
      );
      return;
    }

    final newTask = Task(
      projectId: widget.project.id!,
      statusId: status.id,
      description: description,
      scheduledAt: createdAt,
      status: status,
      color: color,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      createdBy: authProvider.user!.id,
    );

    final success = await taskProvider.registerTask(newTask, authProvider);

    if (mounted && !success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            taskProvider.errorMessage ?? 'Falha ao cadastrar tarefa.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updateTask(Task updatedTask) async {
    final authProvider = context.read<AuthProvider>();
    final taskProvider = context.read<TaskProvider>();

    final success = await taskProvider.updateTask(updatedTask, authProvider);

    if (mounted && !success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            taskProvider.errorMessage ?? 'Falha ao atualizar tarefa.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } else if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tarefa atualizada!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _confirmAndDeleteTask(Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Tem certeza que deseja excluir esta tarefa?'),
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
      final taskProvider = context.read<TaskProvider>();
      final authProvider = context.read<AuthProvider>();

      final success = await taskProvider.deleteTask(task.id!, authProvider);

      if (mounted && !success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              taskProvider.errorMessage ?? 'Falha ao excluir tarefa.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      } else if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tarefa excluída com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _showAddTaskModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AddTaskModal(onAddTask: _addTask),
    );
  }

  void _showEditTaskModal(BuildContext context, Task taskToEdit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,

      builder: (_) =>
          AddTaskModal(taskToEdit: taskToEdit, onUpdateTask: _updateTask),
    );
  }

  Future<void> _pickAndUploadFile(Task task) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null && result.files.single.path != null && mounted) {
      File file = File(result.files.single.path!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Enviando ${result.files.single.name}...')),
      );

      final fileProvider = context.read<TaskFileProvider>();
      final authProvider = context.read<AuthProvider>();

      final success = await fileProvider.uploadFile(
        task.id!,
        file,
        authProvider,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Arquivo anexado com sucesso!'),
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

  Future<void> _openFile(TaskFile file) async {
    final String heroTag = 'fileHero-${file.id}';

    if (file.fileType == 'image') {
      _showImageDialog(file, heroTag);
    } else if (file.extension == 'pdf') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PdfViewerScreen(
            fileUrl: file.fileUrl,
            heroTag: heroTag,
            fileName: file.originalName,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tipo de arquivo não suportado para visualização.'),
        ),
      );
    }
  }

  void _showImageDialog(dynamic file, String heroTag) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          file.originalName,
          style: const TextStyle(fontSize: 16),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        contentPadding: const EdgeInsets.all(8.0),
        insetPadding: const EdgeInsets.all(16.0),
        content: Hero(
          tag: heroTag,
          child: InteractiveViewer(
            child: CachedNetworkImage(
              imageUrl: file.fileUrl,
              placeholder: (context, url) =>
                  const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) =>
                  const Icon(Icons.error, color: Colors.red),
              fit: BoxFit.contain,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),

          ElevatedButton.icon(
            icon: const Icon(CupertinoIcons.share_solid, size: 18),
            label: const Text('Compartilhar'),
            onPressed: () {
              Navigator.of(context).pop();
              _shareFile(file);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _shareProjectDetails(Project project) async {
    String fDate(String? apiDate) => Formatters.formatApiDate(apiDate);
    String fCurrency(double? value) => Formatters.formatCurrency(value);

    final String content =
        """
*DETALHES DO PROJETO*
---------------------------------
*Projeto:* ${project.name}
*Status:* ${project.status?.name ?? 'N/A'}
*Responsável Fiscal:* ${project.fiscalResponsible}

*--- Datas ---*
*Apresentação:* ${fDate(project.presentationDate)}
*Aprovação:* ${fDate(project.approvalDate)}
*Prestação de Contas:* ${fDate(project.accountabilityDate)}
*Início Captação:* ${fDate(project.collectionStartDate)}
*Final Captação:* ${fDate(project.collectionEndDate)}
*Período de Execução:* ${fDate(project.executionStartDate)} a ${fDate(project.executionEndDate)}

*--- Valores ---*
*Valor Apresentado:* ${fCurrency(project.presentedValue)}
*Valor Aprovado:* ${fCurrency(project.approvedValue)}
*Total Captado:* ${fCurrency(project.totalCollected)}
*Conta bancária:* ${project.bankAccount}

*--- Descrição ---*
${project.observations}
""";

    final box = context.findRenderObject() as RenderBox?;

    await Share.share(
      content,
      subject: 'Detalhes do Projeto: ${project.name}',
      sharePositionOrigin: box != null
          ? box.localToGlobal(Offset.zero) & box.size
          : null,
    );
  }

  Future<void> _shareTaskDetails(Task task) async {
    // Acessa o nome do projeto através do 'widget.project'
    final String projectName = widget.project.name;

    final String content =
        """
*Projeto:* $projectName
*Tarefa:* ${task.description}
*Status:* ${task.status?.name ?? 'N/A'}
*Data:* ${DateFormat('dd/MM/yyyy HH:mm').format(task.scheduledAt)}
""";

    await Share.share(
      content,
      subject: 'Tarefa: ${task.description} (Projeto: $projectName)',
    );
  }

  Future<void> _shareFile(dynamic file) async {
    if (file.fileUrl == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Preparando ${file.originalName}...')),
    );

    try {
      final fileData = await DefaultCacheManager().getSingleFile(
        file.fileUrl as String,
      );

      final xFile = XFile(fileData.path);

      if (mounted) ScaffoldMessenger.of(context).removeCurrentSnackBar();

      await Share.shareXFiles([
        xFile,
      ], text: 'Confira este arquivo: ${file.originalName}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao compartilhar arquivo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F8FA),
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          _buildExpandableProjectSummary(widget.project),

          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: Row(
              children: [
                Icon(Icons.list_alt, color: Colors.grey.shade700),
                const SizedBox(width: 8),
                const Text(
                  'Ações do Projeto',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: taskProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : taskProvider.errorMessage != null
                ? Center(child: Text(taskProvider.errorMessage!))
                : taskProvider.tasks.isEmpty
                ? const Center(
                    child: Text('Nenhuma tarefa cadastrada para este projeto.'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 80.0),
                    itemCount: taskProvider.tasks.length,
                    itemBuilder: (context, index) {
                      final task = taskProvider.tasks[index];
                      return _buildTaskCard(task);
                    },
                  ),
          ),
          SizedBox(height: 30),
        ],
      ),

      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: FloatingActionButton(
          onPressed: () => _showAddTaskModal(context),
          backgroundColor: const Color(0XFFD932CE),
          shape: const CircleBorder(),
          child: const Icon(Icons.add_task, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildExpandableProjectSummary(Project project) {
    Widget buildHeader() {
      return InkWell(
        onTap: () => setState(() => _isSummaryExpanded = !_isSummaryExpanded),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NOME DO PROJETO: ${project.status?.name ?? 'N/A'}',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Criação: ${Formatters.formatApiDate(project.presentationDate)}',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      CupertinoIcons.share_solid,
                      color: Colors.grey.shade600,
                      size: 22,
                    ),
                    onPressed: () {
                      _shareProjectDetails(project);
                    },
                    tooltip: 'Compartilhar Detalhes',
                    splashRadius: 20,
                  ),

                  IconButton(
                    icon: AnimatedRotation(
                      turns: _isSummaryExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    onPressed: () => setState(
                      () => _isSummaryExpanded = !_isSummaryExpanded,
                    ),
                    tooltip: _isSummaryExpanded ? 'Recolher' : 'Expandir',
                    splashRadius: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    Widget buildDetails() {
      return Container(
        color: Colors.grey.shade50,
        constraints: const BoxConstraints(
          // define uma altura máxima opcional, pra evitar travar o layout
          maxHeight: 400, // ajuste conforme necessário
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              bottom: 16.0,
              top: 8.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(height: 1, thickness: 1),
                const SizedBox(height: 16),
                _buildDetailRow(
                  title1: 'Valor Apresentado',
                  value1: Formatters.formatCurrency(project.presentedValue),
                  title2: 'Valor Aprovado',
                  value2: Formatters.formatCurrency(project.approvedValue),
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  title1: 'Total Captado',
                  value1: Formatters.formatCurrency(project.totalCollected),
                  title2: 'Responsável Fiscal',
                  value2: project.fiscalResponsible,
                ),
                const Divider(height: 24),
                _buildDetailRow(
                  title1: 'Apresentação',
                  value1: Formatters.formatApiDate(project.presentationDate),
                  title2: 'Aprovação',
                  value2: Formatters.formatApiDate(project.approvalDate),
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  title1: 'Início Captação',
                  value1: Formatters.formatApiDate(project.collectionStartDate),
                  title2: 'Final Captação',
                  value2: Formatters.formatApiDate(project.collectionEndDate),
                ),
                const SizedBox(height: 12),
                _buildMultiLineDetail(
                  title: 'Período de Execução',
                  value:
                      '${Formatters.formatApiDate(project.executionStartDate)} a ${Formatters.formatApiDate(project.executionEndDate)}',
                ),
                const SizedBox(height: 12),
                _buildMultiLineDetail(
                  title: 'Data Prestação Contas',
                  value: Formatters.formatApiDate(project.accountabilityDate),
                ),
                const Divider(height: 24),
                _buildMultiLineDetail(
                  title: 'Conta bancária',
                  value: project.bankAccount ?? "Sem conta bancária",
                ),
                const Divider(height: 24),
                _buildMultiLineDetail(
                  title: 'Objetivo',
                  value: project.observations,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      clipBehavior: Clip.antiAlias,
      color: Colors.white,
      elevation: 1,
      child: Column(
        children: [
          buildHeader(),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: AnimatedCrossFade(
              firstChild: Container(height: 0),
              secondChild: buildDetails(),
              crossFadeState: _isSummaryExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
              firstCurve: Curves.easeOut,
              secondCurve: Curves.easeIn,
              sizeCurve: Curves.easeInOut,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required String title1,
    required String value1,
    required String title2,
    required String value2,
  }) {
    return Row(
      children: [
        Expanded(child: _buildDetailColumn(title1, value1)),
        const SizedBox(width: 16),
        Expanded(child: _buildDetailColumn(title2, value2)),
      ],
    );
  }

  Widget _buildDetailColumn(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildMultiLineDetail({required String title, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildTaskCard(Task task) {
    final cardColor = Formatters.colorFromHex(task.color);
    final textColor = cardColor.computeLuminance() > 0.5
        ? Colors.black87
        : Colors.white;
    final fileProvider = context.watch<TaskFileProvider>();
    final taskFiles = fileProvider.getFilesForTask(task.id!);
    final isLoadingFiles = fileProvider.isLoadingFiles(task.id!);
    final fileError = fileProvider.getFileLoadingError(task.id!);
    return Card(
      color: cardColor,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.15),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat(
                    'dd/MM/yyyy \'às\' HH:mm',
                  ).format(task.scheduledAt),
                  style: TextStyle(
                    color: textColor.withOpacity(0.8),
                    fontSize: 13,
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: textColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    task.status?.name ?? 'N/A',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (isLoadingFiles)
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: LinearProgressIndicator(),
              )
            else if (fileError != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  'Erro ao carregar anexos: $fileError',
                  style: TextStyle(color: Colors.red.shade900, fontSize: 11),
                ),
              )
            else if (taskFiles.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(color: textColor.withOpacity(0.3)),
                    const SizedBox(height: 6),
                    Text(
                      "Anexos (${taskFiles.length}):",
                      style: TextStyle(
                        fontSize: 12,
                        color: textColor.withOpacity(0.8),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      height: 32,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: taskFiles.length,
                        itemBuilder: (ctx, index) {
                          final file = taskFiles[index];
                          final heroTag = 'taskFileCardHero-${file.id}';
                          return Padding(
                            padding: EdgeInsetsGeometry.only(right: 6.0),
                            child: InkWell(
                              onTap: () => _openFile(file),
                              child: Hero(
                                tag: heroTag,
                                child: Chip(
                                  avatar: Icon(
                                    file.icon,
                                    size: 14,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  label: Text(
                                    file.originalName,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                  backgroundColor: Colors.grey.shade200,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 0,
                                  ),
                                  labelPadding: const EdgeInsets.only(
                                    left: 4,
                                    right: 6,
                                  ),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            Text(
              task.description,
              style: TextStyle(
                fontSize: 15,
                height: 1.4,
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),

            const Divider(height: 24, color: Colors.white30),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _actionButton(
                  icon: Icons.edit_outlined,
                  onPressed: () => _showEditTaskModal(context, task),
                  buttonColor: textColor,
                ),
                _actionButton(
                  icon: Icons.delete_outline,
                  onPressed: () => _confirmAndDeleteTask(task),
                  buttonColor: textColor,
                ),
                _actionButton(
                  icon: Icons.attach_file,
                  onPressed: () => _pickAndUploadFile(task),
                  buttonColor: textColor,
                ),
                _actionButton(
                  icon: CupertinoIcons.share_solid,
                  onPressed: () => _shareTaskDetails(task),
                  buttonColor: textColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color? buttonColor,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, color: buttonColor ?? Colors.grey.shade600),
      splashRadius: 24,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      constraints: const BoxConstraints(),
    );
  }
}
