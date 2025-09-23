import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:tarefas_projetocrescer/models/task.dart';
import 'package:tarefas_projetocrescer/screens/widgets/bottom_nav_bar.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final String projectName;
  const ProjectDetailsScreen({super.key, required this.projectName});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.projectName),
        backgroundColor: const Color(0xFFF8F8FA),
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          final task = _tasks[index];
          return _buildTaskCard(task);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskModal(context),
        backgroundColor: const Color(0xFF6A3DE8),
        shape: const CircleBorder(),
        child: const Icon(Icons.add_task, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const BottomNavBar(),
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
                _actionButton(icon: Icons.edit_outlined, onPressed: () {}),
                _actionButton(icon: Icons.delete_outline, onPressed: () {}),
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
      icon: Icon(icon, color: Colors.grey[700]),
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
                backgroundColor: const Color(0xFF6A3DE8),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
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
