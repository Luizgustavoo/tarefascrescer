import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tarefas_projetocrescer/models/project.dart';
import 'package:tarefas_projetocrescer/models/status.dart';
import 'package:tarefas_projetocrescer/models/task.dart';
import 'package:tarefas_projetocrescer/providers/auth_provider.dart';
import 'package:tarefas_projetocrescer/providers/task_provider.dart';
import 'package:tarefas_projetocrescer/screens/widgets/add_task_modal.dart';
import 'package:tarefas_projetocrescer/utils/formatters.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final Project project;
  const ProjectDetailsScreen({super.key, required this.project});

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (widget.project.id != null) {
        Provider.of<TaskProvider>(
          context,
          listen: false,
        ).fetchTasks(widget.project.id!, authProvider);
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
          _buildProjectSummaryHeader(widget.project),

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

  Widget _buildProjectSummaryHeader(Project project) {
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'pt_BR');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(8, 0, 16, 20),
      decoration: const BoxDecoration(
        color: Color(0xFFE8E2F9),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildDetailItem(
                          icon: Icons.flag_outlined,
                          title: 'Status',
                          value: project.status?.name ?? 'N/A',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDetailItem(
                          icon: Icons.calendar_today,
                          title: 'Data de Criação',
                          value: Formatters.formatApiDate(
                            project.presentationDate,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildDetailItem(
                          icon: Icons.request_quote_outlined,
                          title: 'Valor Apresentado',
                          value: currencyFormat.format(project.presentedValue),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDetailItem(
                          icon: Icons.account_balance_wallet_outlined,
                          title: 'Total Captado',
                          value: Formatters.formatCurrency(
                            project.totalCollected,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDetailItem(
                    icon: Icons.person_outline,
                    title: 'Responsável Fiscal',
                    value: project.fiscalResponsible,
                  ),
                  const SizedBox(height: 16),
                  _buildDetailItem(
                    icon: Icons.timelapse_outlined,
                    title: 'Período de Execução',
                    value:
                        '${Formatters.formatApiDate(project.executionStartDate)} a ${Formatters.formatApiDate(project.executionEndDate)}',
                  ),
                  const SizedBox(height: 16),
                  _buildDetailItem(
                    icon: Icons.comment_outlined,
                    title: 'Observações',
                    value: project.observations,
                    isMultiLine: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String title,
    required String value,
    bool isMultiLine = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey.shade700),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          maxLines: isMultiLine ? 5 : 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Color _colorFromHex(String hexColor) {
    final hexCode = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  Widget _buildTaskCard(Task task) {
    final cardColor = _colorFromHex(task.color);
    final textColor = cardColor.computeLuminance() > 0.5
        ? Colors.black87
        : Colors.white;

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
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
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    task.status?.name ?? 'N/A',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              task.description,
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _actionButton(
                  icon: Icons.edit_outlined,
                  onPressed: () => _showEditTaskModal(context, task),
                ),
                _actionButton(icon: Icons.delete_outline, onPressed: () {}),
                _actionButton(icon: Icons.attach_file, onPressed: () => {}),
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
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.grey[500]),
      splashRadius: 20,
    );
  }
}
