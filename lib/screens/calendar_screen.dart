import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:tarefas_projetocrescer/models/status.dart';
import 'package:tarefas_projetocrescer/models/task.dart';
import 'package:tarefas_projetocrescer/providers/auth_provider.dart';
import 'package:tarefas_projetocrescer/providers/calendar_provider.dart';
import 'package:tarefas_projetocrescer/providers/project_provider.dart';
import 'package:tarefas_projetocrescer/providers/task_provider.dart';
import 'package:tarefas_projetocrescer/screens/widgets/add_task_from_calendar_modal.dart';
import 'package:tarefas_projetocrescer/utils/formatters.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _isDayView = false;

  @override
  void initState() {
    super.initState();

    initializeDateFormatting('pt_BR', null).then((_) {
      if (mounted) {
        setState(() {});
      }

      Future.microtask(() {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        Provider.of<CalendarProvider>(
          context,
          listen: false,
        ).fetchTasksForMonth(_focusedDay, authProvider);
        Provider.of<ProjectProvider>(
          context,
          listen: false,
        ).fetchProjects(authProvider);
      });
    });
  }

  List<Task> _getEventsForDay(DateTime day) {
    return context.read<CalendarProvider>().getEventsForDay(day);
  }

  void _backToCalendar() {
    setState(() {
      _isDayView = false;
      _selectedDay = null;
    });
  }

  Future<void> _addTaskFromCalendar(
    int projectId, // <<< NOVO
    String description,
    Status status,
    DateTime createdAt,
    String color,
  ) async {
    final authProvider = context.read<AuthProvider>();
    final taskProvider = context.read<TaskProvider>();
    final calendarProvider = context.read<CalendarProvider>();

    if (authProvider.user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário não autenticado.')),
        );
      }
      return;
    }
    final newTask = Task(
      id: 0,
      projectId: projectId, // Usa o projectId vindo do modal
      statusId: status.id,
      description: description,
      scheduledAt: createdAt,
      createdBy: authProvider.user!.id,
      color: color,
      status: status,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final success = await taskProvider.registerTask(newTask, authProvider);

    if (mounted && success) {
      await calendarProvider.fetchTasksForMonth(_focusedDay, authProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tarefa adicionada!'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            taskProvider.errorMessage ?? 'Falha ao adicionar tarefa.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showAddTaskModalFromCalendar(DateTime selectedDate) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      // ALTERADO: Chama o novo modal e passa a data
      builder: (_) => AddTaskFromCalendarModal(
        onAddTask: _addTaskFromCalendar, // Passa a função correta
        preselectedDate: selectedDate, // Passa a data selecionada
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final calendarProvider = context.watch<CalendarProvider>();
    final authProvider = context.read<AuthProvider>();

    final selectedDayForView = _selectedDay ?? _focusedDay;
    final eventsForSelectedDay = calendarProvider.getEventsForDay(
      selectedDayForView,
    );

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(_isDayView ? 'Tarefas do Dia' : 'Calendário'),
          leading: _isDayView
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _backToCalendar,
                )
              : null,
          actions: [
            if (!_isDayView)
              IconButton(
                icon: Icon(
                  _calendarFormat == CalendarFormat.month
                      ? Icons.view_week
                      : Icons.calendar_month,
                ),
                tooltip: _calendarFormat == CalendarFormat.month
                    ? 'Ver por semana'
                    : 'Ver por mês',
                onPressed: () => setState(() {
                  _calendarFormat = _calendarFormat == CalendarFormat.month
                      ? CalendarFormat.week
                      : CalendarFormat.month;
                }),
              ),
          ],
        ),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _isDayView
              ? _buildDayView(selectedDayForView, eventsForSelectedDay)
              : _buildCalendarView(calendarProvider, authProvider),
        ),
      ),
    );
  }

  Widget _buildCalendarView(CalendarProvider provider, AuthProvider auth) {
    return SingleChildScrollView(
      key: const ValueKey('calendarView'),
      child: Column(
        children: [
          TableCalendar<Task>(
            locale: 'pt_BR',
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            rowHeight: MediaQuery.of(context).size.height / 9,
            daysOfWeekHeight: MediaQuery.of(context).size.height / 9,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                  _isDayView = true;
                });
              }
            },
            onDayLongPressed: (selectedDay, focusedDay) {
              _showAddTaskModalFromCalendar(selectedDay);
            },
            onPageChanged: (focusedDay) {
              if (focusedDay.month != _focusedDay.month ||
                  focusedDay.year != _focusedDay.year) {
                setState(() {
                  _focusedDay = focusedDay;
                });
                provider.fetchTasksForMonth(focusedDay, auth);
              } else {
                setState(() {
                  _focusedDay = focusedDay;
                });
              }
            },
            eventLoader: _getEventsForDay,
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              leftChevronIcon: Icon(
                Icons.chevron_left,
                color: Color(0XFFD932CE),
              ),
              rightChevronIcon: Icon(
                Icons.chevron_right,
                color: Color(0XFFD932CE),
              ),
            ),
            calendarStyle: const CalendarStyle(
              outsideDaysVisible: false,
              todayDecoration: BoxDecoration(
                color: Color(0XFFD932CE),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Color(0xFFB01FAC),
                shape: BoxShape.circle,
              ),
              todayTextStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              selectedTextStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              weekendTextStyle: TextStyle(color: Colors.redAccent),
              markerMargin: EdgeInsets.only(top: 5),
              markersMaxCount: 4,
            ),
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle: TextStyle(fontWeight: FontWeight.w500),
              weekendStyle: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.w500,
              ),
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) {
                if (events.isNotEmpty) {
                  return Positioned(
                    right: 1,
                    bottom: 5,
                    child: _buildEventsMarker(day, events),
                  );
                }
                return null;
              },
            ),
          ),

          if (provider.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: CircularProgressIndicator(),
            ),
          if (provider.errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Erro: ${provider.errorMessage}',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildEventsMarker(DateTime day, List<Task> events) {
    final colors = events.map((e) => e.color).toSet().take(4).toList();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: colors.map((hexColor) {
        return Container(
          width: 7,
          height: 7,
          margin: const EdgeInsets.symmetric(horizontal: 0.5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Formatters.colorFromHex(hexColor),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDayView(DateTime selectedDay, List<Task> events) {
    return Container(
      key: const ValueKey('dayView'),
      width: double.infinity,
      color: Colors.grey[100],
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat(
              "EEEE, dd 'de' MMMM 'de' yyyy",
              "pt_BR",
            ).format(selectedDay),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          Expanded(child: _EventTaskList(events: events)),
        ],
      ),
    );
  }
}

class _EventTaskList extends StatelessWidget {
  final List<Task> events;
  const _EventTaskList({required this.events});

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const Center(
        child: Text(
          'Nenhuma tarefa agendada para este dia.',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    events.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

    final statusColors = {
      'Pendente': Colors.orange.shade700,
      'Em Andamento': Colors.blue.shade700,
      'Concluída': Colors.green.shade700,
      'Cancelada': Colors.red.shade700,
    };

    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        final task = events[index];
        final taskColor = Formatters.colorFromHex(task.color);
        final textColor = taskColor.computeLuminance() > 0.5
            ? Colors.black87
            : Colors.white;
        final statusColor =
            statusColors[task.status?.name] ?? Colors.grey.shade600;

        return Card(
          color: taskColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(vertical: 6),
          elevation: 3,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            title: Text(
              task.description,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: textColor,
                fontSize: 15,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Text(
                task.project?.name ?? 'Projeto não associado',
                style: TextStyle(
                  color: textColor.withOpacity(0.8),
                  fontSize: 13,
                ),
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  DateFormat('HH:mm').format(task.scheduledAt),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    task.status?.name ?? 'N/A',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            onTap: () {
              print('Tarefa clicada: ${task.description}');
            },
          ),
        );
      },
    );
  }
}
