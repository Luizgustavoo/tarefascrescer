import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:tarefas_projetocrescer/models/project.dart';
import 'package:tarefas_projetocrescer/models/task.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final Project project;
  const ProjectDetailsScreen({super.key, required this.project});

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  final List<Task> _tasks = [
    Task(
      id: '1',
      description:
          'Reunião de alinhamento com a equipe de design para discutir os mockups iniciais.',
      status: 'Concluída',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Task(
      id: '2',
      description:
          'Desenvolver a tela de login e a lógica de autenticação com Firebase.',
      status: 'Em Andamento',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Task(
      id: '3',
      description: 'Configurar o ambiente de produção no servidor.',
      status: 'Pendente',
      createdAt: DateTime.now(),
    ),
  ];

  void _addTask(String description, String status, DateTime createdAt) {
    final newTask = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      description: description,
      status: status,
      createdAt: createdAt,
    );
    setState(() {
      _tasks.add(newTask);
      _tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });
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

  Future<void> _attachFile(Task task) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        task.attachments.add(File(image.path));
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Anexo adicionado à tarefa: ${task.description}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
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
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'pt_BR');

    // O ExpansionTile fica ótimo dentro de um Card para dar um contorno
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip
          .antiAlias, // Garante que o conteúdo não vaze das bordas arredondadas
      child: ExpansionTile(
        backgroundColor: Colors.white,
        collapsedBackgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        title: Text(
          project.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        subtitle: Text(
          project.status,
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        // Ícone que muda ao expandir/recolher
        trailing: const Icon(Icons.keyboard_arrow_down),
        // Os Filhos são o conteúdo que expande
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(height: 1),
                const SizedBox(height: 16),
                _buildDetailRow(
                  title1: 'Apresentação',
                  value1: project.dataApresentacao,
                  title2: 'Aprovação',
                  value2: project.dataAprovacao,
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  title1: 'Final Captação',
                  value1: project.finalCaptacao,
                  title2: 'Prestação Contas',
                  value2: project.dataPrestacaoContas,
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  title1: 'Responsável Fiscal',
                  value1: project.responsavelFiscal,
                  title2: 'Total Captado',
                  value2: currencyFormat.format(project.totalCaptado),
                ),
                const Divider(height: 24),
                _buildMultiLineDetail(
                  title: 'Período de Execução',
                  value: '${project.inicioExecucao} a ${project.fimExecucao}',
                ),
                const SizedBox(height: 12),
                _buildMultiLineDetail(
                  title: 'Contempla',
                  value: project.contempla,
                ),
                const SizedBox(height: 12),
                _buildMultiLineDetail(
                  title: 'Observações',
                  value: project.observacoes,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget auxiliar para as linhas com 2 colunas
  Widget _buildDetailRow({
    required String title1,
    required String value1,
    required String title2,
    required String value2,
  }) {
    return Row(
      children: [
        Expanded(child: _buildDetailColumn(title1, value1)),
        Expanded(child: _buildDetailColumn(title2, value2)),
      ],
    );
  }

  // Widget auxiliar para a coluna de detalhe (Título + Valor)
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

  // Widget auxiliar para os campos de texto grandes
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
    final statusColors = {
      'Pendente': Colors.orange,
      'Em Andamento': Colors.blue,
      'Concluída': Colors.green,
      'Cancelada': Colors.red,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('dd/MM/yyyy \'às\' HH:mm').format(task.createdAt),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColors[task.status] ?? Colors.grey,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    task.status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(task.description),
            const SizedBox(height: 8),
            if (task.attachments.isNotEmpty)
              Text(
                'Anexos: ${task.attachments.length}',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _actionButton(icon: Icons.edit, onPressed: () {}),
                _actionButton(icon: Icons.delete, onPressed: () {}),
                _actionButton(
                  icon: Icons.attach_file,
                  onPressed: () => _attachFile(task),
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
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.grey[500]),
      splashRadius: 20,
    );
  }
}

class AddTaskModal extends StatefulWidget {
  final Function(String description, String status, DateTime createdAt)
  onAddTask;
  const AddTaskModal({super.key, required this.onAddTask});

  @override
  State<AddTaskModal> createState() => _AddTaskModalState();
}

class _AddTaskModalState extends State<AddTaskModal> {
  final _descriptionController = TextEditingController();
  final _dateTimeController = TextEditingController();

  final List<String> _statuses = [
    'Pendente',
    'Em Andamento',
    'Concluída',
    'Cancelada',
  ];
  String? _selectedStatus;
  DateTime? _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _selectedStatus = _statuses.first;

    _selectedDateTime = DateTime.now();
    _dateTimeController.text = DateFormat(
      'dd/MM/yyyy HH:mm',
    ).format(_selectedDateTime!);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _dateTimeController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate == null) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime ?? DateTime.now()),
    );

    if (pickedTime == null) return;

    setState(() {
      _selectedDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
      _dateTimeController.text = DateFormat(
        'dd/MM/yyyy HH:mm',
      ).format(_selectedDateTime!);
    });
  }

  void _submit() {
    if (_descriptionController.text.isNotEmpty &&
        _selectedStatus != null &&
        _selectedDateTime != null) {
      widget.onAddTask(
        _descriptionController.text,
        _selectedStatus!,
        _selectedDateTime!,
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nova Tarefa',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          TextFormField(
            controller: _dateTimeController,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'Data e Hora',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              suffixIcon: Icon(Icons.calendar_today),
            ),
            onTap: () => _selectDateTime(context),
          ),

          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: _selectedStatus,
            items: _statuses.map((String status) {
              return DropdownMenuItem<String>(
                value: status,
                child: Text(status),
              );
            }).toList(),
            onChanged: (newValue) => setState(() => _selectedStatus = newValue),
            decoration: const InputDecoration(
              labelText: 'Situação',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _descriptionController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Descrição',
              alignLabelWithHint: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0XFFD932CE),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _submit,
              child: const Text('Salvar Tarefa'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
