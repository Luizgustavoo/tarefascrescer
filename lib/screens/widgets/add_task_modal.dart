import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tarefas_projetocrescer/models/status.dart';
import 'package:tarefas_projetocrescer/models/task.dart';
import 'package:tarefas_projetocrescer/providers/auth_provider.dart';
import 'package:tarefas_projetocrescer/providers/task_status_provider.dart';
import 'package:tarefas_projetocrescer/screens/widgets/color_selector.dart';

class AddTaskModal extends StatefulWidget {
  final Function(
    String description,
    Status status,
    DateTime createdAt,
    String color,
  )?
  onAddTask;

  final Function(Task updatedTask)? onUpdateTask;
  final Task? taskToEdit;
  const AddTaskModal({
    super.key,
    this.onAddTask,
    this.onUpdateTask,
    this.taskToEdit,
  });

  @override
  State<AddTaskModal> createState() => _AddTaskModalState();
}

class _AddTaskModalState extends State<AddTaskModal> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _dateTimeController = TextEditingController();

  Status? _selectedStatus;
  DateTime? _selectedDateTime;
  bool _isInitialLoad = true;
  static const String _addNewStatusKey = 'ADD_NEW_TASK_STATUS';
  String _selectedColor = '#F8BBD0';

  bool get _isEditing => widget.taskToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final task = widget.taskToEdit!;
      _descriptionController.text = task.description;
      _selectedDateTime = task.scheduledAt;
      _dateTimeController.text = DateFormat(
        'dd/MM/yyyy HH:mm',
      ).format(_selectedDateTime!);
      _selectedColor = task.color;
    } else {
      _selectedDateTime = DateTime.now();
      _dateTimeController.text = DateFormat(
        'dd/MM/yyyy HH:mm',
      ).format(_selectedDateTime!);
    }
    Future.microtask(() {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      Provider.of<TaskStatusProvider>(
        context,
        listen: false,
      ).fetchStatuses(authProvider);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInitialLoad) {
      final statusProvider = Provider.of<TaskStatusProvider>(context);
      if (statusProvider.statuses.isNotEmpty) {
        setState(() {
          if (_isEditing) {
            _selectedStatus = statusProvider.statuses.firstWhere(
              (s) => s.id == widget.taskToEdit!.statusId,
              orElse: () => statusProvider.statuses.first,
            );
          } else {
            _selectedStatus ??= statusProvider.statuses.first;
          }
          _isInitialLoad = false;
        });
      }
    }
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

  Future<void> _showAddTaskStatusDialog() async {
    final newStatusController = TextEditingController();
    final dialogFormKey = GlobalKey<FormState>();

    final String? newStatusName = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Novo Status de Tarefa'),
        content: Form(
          key: dialogFormKey,
          child: TextFormField(
            controller: newStatusController,
            decoration: const InputDecoration(hintText: 'Nome do status'),
            autofocus: true,
            validator: (value) =>
                value == null || value.isEmpty ? 'Campo obrigatório' : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (dialogFormKey.currentState!.validate()) {
                Navigator.of(
                  dialogContext,
                ).pop(newStatusController.text.toUpperCase());
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    if (newStatusName != null && newStatusName.isNotEmpty && mounted) {
      final statusProvider = Provider.of<TaskStatusProvider>(
        context,
        listen: false,
      );
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final Status? newStatus = await statusProvider.registerStatus(
        newStatusName,
        authProvider,
      );

      if (newStatus != null && mounted) {
        setState(() => _selectedStatus = newStatus);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao cadastrar status da tarefa.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedStatus != null && _selectedDateTime != null) {
        if (_isEditing) {
          final updatedTask = widget.taskToEdit!.copyWith(
            description: _descriptionController.text,
            statusId: _selectedStatus!.id,
            status: _selectedStatus,
            scheduledAt: _selectedDateTime!,
            color: _selectedColor,
          );
          widget.onUpdateTask!(updatedTask);
        } else {
          widget.onAddTask!(
            _descriptionController.text,
            _selectedStatus!,
            _selectedDateTime!,
            _selectedColor,
          );
        }
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusProvider = context.watch<TaskStatusProvider>();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isEditing ? 'Editar Tarefa' : 'Nova Tarefa',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
                items: [
                  ...statusProvider.statuses.map((Status status) {
                    return DropdownMenuItem<dynamic>(
                      value: status,
                      child: Text(status.name, overflow: TextOverflow.ellipsis),
                    );
                  }),
                  const DropdownMenuItem<dynamic>(
                    enabled: false,
                    child: Divider(),
                  ),
                  DropdownMenuItem<dynamic>(
                    value: _addNewStatusKey,
                    child: Row(
                      children: [
                        Icon(Icons.add, color: Theme.of(context).primaryColor),
                        const SizedBox(width: 8),
                        const Text('Cadastrar nova...'),
                      ],
                    ),
                  ),
                ],
                onChanged: (newValue) {
                  if (newValue == _addNewStatusKey) {
                    _showAddTaskStatusDialog();
                  } else if (newValue is Status) {
                    setState(() => _selectedStatus = newValue);
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Situação',
                  border: OutlineInputBorder(
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
                setState(() {
                  _selectedColor = newColor;
                });
              },
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
                child: Text(_isEditing ? 'Salvar Alterações' : 'Salvar Tarefa'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
