import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tarefas_projetocrescer/models/project.dart';
import 'package:tarefas_projetocrescer/models/status.dart';
import 'package:tarefas_projetocrescer/providers/auth_provider.dart';
import 'package:tarefas_projetocrescer/providers/project_provider.dart';
import 'package:tarefas_projetocrescer/providers/task_status_provider.dart';
import 'color_selector.dart';

class AddTaskFromCalendarModal extends StatefulWidget {
  final Function(
    int projectId,
    String description,
    Status status,
    DateTime createdAt,
    String color,
  )
  onAddTask;

  final DateTime preselectedDate;

  const AddTaskFromCalendarModal({
    super.key,
    required this.onAddTask,
    required this.preselectedDate,
  });

  @override
  State<AddTaskFromCalendarModal> createState() =>
      _AddTaskFromCalendarModalState();
}

class _AddTaskFromCalendarModalState extends State<AddTaskFromCalendarModal> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _dateTimeController = TextEditingController();

  Project? _selectedProject;
  Status? _selectedStatus;
  DateTime? _selectedDateTime;
  bool _isInitialLoad = true;
  static const String _addNewStatusKey = 'ADD_NEW_TASK_STATUS';
  String _selectedColor = '#F8BBD0';

  @override
  void initState() {
    super.initState();

    _selectedDateTime = widget.preselectedDate;

    final now = DateTime.now();
    _selectedDateTime = DateTime(
      _selectedDateTime!.year,
      _selectedDateTime!.month,
      _selectedDateTime!.day,
      now.hour,
      now.minute,
    );
    _dateTimeController.text = DateFormat(
      'dd/MM/yyyy HH:mm',
    ).format(_selectedDateTime!);

    Future.microtask(() {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      Provider.of<TaskStatusProvider>(
        context,
        listen: false,
      ).fetchStatuses(authProvider);

      Provider.of<ProjectProvider>(
        context,
        listen: false,
      ).fetchProjects(authProvider);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInitialLoad) {
      final statusProvider = Provider.of<TaskStatusProvider>(context);
      final projectProvider = Provider.of<ProjectProvider>(context);

      setState(() {
        if (statusProvider.statuses.isNotEmpty) {
          _selectedStatus ??= statusProvider.statuses.first;
        }
        if (projectProvider.projects.isNotEmpty) {
          _selectedProject ??= projectProvider.projects.first;
        }
        _isInitialLoad = false;
      });
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _dateTimeController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime initial = _selectedDateTime ?? DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate == null) return;

    if (!mounted) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
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

  Future<void> _showAddTaskStatusDialog() async {}

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedProject != null &&
          _selectedStatus != null &&
          _selectedDateTime != null) {
        widget.onAddTask(
          _selectedProject!.id!,
          _descriptionController.text,
          _selectedStatus!,
          _selectedDateTime!,
          _selectedColor,
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, selecione projeto e status.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusProvider = context.watch<TaskStatusProvider>();
    final projectProvider = context.watch<ProjectProvider>();

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nova Tarefa (Calendário)',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              if (projectProvider.isLoading && projectProvider.projects.isEmpty)
                const Center(child: CircularProgressIndicator())
              else
                DropdownButtonFormField<Project>(
                  value:
                      (_selectedProject != null &&
                          projectProvider.projects.contains(_selectedProject))
                      ? _selectedProject
                      : null,
                  hint: const Text('Selecione o Projeto'),
                  isExpanded: true,
                  items: projectProvider.projects.map((Project project) {
                    return DropdownMenuItem<Project>(
                      value: project,
                      child: Text(
                        project.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() => _selectedProject = newValue);
                  },
                  decoration: const InputDecoration(
                    labelText: 'Projeto',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                  validator: (value) =>
                      value == null ? 'Selecione um projeto' : null,
                ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _dateTimeController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Data e Hora',
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                onTap: () => _selectDateTime(context),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Selecione uma data' : null,
              ),
              const SizedBox(height: 16),

              if (statusProvider.isLoading && statusProvider.statuses.isEmpty)
                const Center(child: CircularProgressIndicator())
              else
                DropdownButtonFormField<dynamic>(
                  value:
                      (_selectedStatus != null &&
                          statusProvider.statuses.contains(_selectedStatus))
                      ? _selectedStatus
                      : null,
                  hint: const Text('Selecione uma situação'),
                  isExpanded: true,
                  items: [/* ... (itens + 'Cadastrar nova...') ... */],
                  onChanged: (newValue) {
                    if (newValue == _addNewStatusKey) {
                      _showAddTaskStatusDialog();
                    } else if (newValue is Status) {
                      setState(() => _selectedStatus = newValue);
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Situação',
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                  validator: (value) =>
                      value == null ? 'Selecione uma situação' : null,
                ),
              const SizedBox(height: 16),

              ColorSelector(
                initialColor: _selectedColor,
                onColorSelected: (newColor) {
                  setState(() => _selectedColor = newColor);
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Descrição',
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Campo obrigatório' : null,
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
            ],
          ),
        ),
      ),
    );
  }
}
