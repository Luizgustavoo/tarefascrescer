import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

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

  final Map<DateTime, List<String>> _events = {
    DateTime.utc(2025, 10, 19): ['Reunião com equipe', 'Treino 18h'],
    DateTime.utc(2025, 10, 20): ['Entrega do relatório', 'Chamada com cliente'],
    DateTime.utc(2025, 10, 21): ['Aniversário do João'],
  };

  List<String> _getEventsForDay(DateTime day) =>
      _events[DateTime.utc(day.year, day.month, day.day)] ?? [];

  @override
  Widget build(BuildContext context) {
    final selectedDay = _selectedDay ?? _focusedDay;
    final events = _getEventsForDay(selectedDay);

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            _isDayView
                ? 'Eventos do Dia'
                : 'Calendário (${_calendarFormat == CalendarFormat.month ? 'Mês' : 'Semana'})',
          ),
          actions: [
            IconButton(
              icon: Icon(
                _isDayView
                    ? Icons.calendar_month
                    : _calendarFormat == CalendarFormat.month
                    ? Icons.view_week
                    : Icons.calendar_month,
              ),
              tooltip: _isDayView
                  ? 'Voltar ao calendário'
                  : _calendarFormat == CalendarFormat.month
                  ? 'Visualizar por semana'
                  : 'Visualizar por mês',
              onPressed: () => setState(() {
                if (_isDayView) {
                  _isDayView = false;
                } else {
                  _calendarFormat = _calendarFormat == CalendarFormat.month
                      ? CalendarFormat.week
                      : CalendarFormat.month;
                }
              }),
            ),
          ],
        ),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _isDayView
              ? _buildDayView(selectedDay, events)
              : _buildCalendarView(),
        ),
      ),
    );
  }

  Widget _buildCalendarView() {
    return TableCalendar<String>(
      rowHeight: 100,
      daysOfWeekHeight: 50,
      locale: 'pt_BR',
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
          _isDayView = true;
        });
      },
      onPageChanged: (focusedDay) => _focusedDay = focusedDay,
      eventLoader: _getEventsForDay,
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      ),
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        todayDecoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        selectedDecoration: BoxDecoration(
          color: const Color(0xFF2E7D32),
          borderRadius: BorderRadius.circular(10),
        ),
        todayTextStyle: const TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.bold,
        ),
        selectedTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        defaultTextStyle: const TextStyle(color: Colors.black87),
        weekendTextStyle: const TextStyle(color: Colors.redAccent),
      ),
      daysOfWeekStyle: const DaysOfWeekStyle(
        weekdayStyle: TextStyle(fontWeight: FontWeight.w500),
        weekendStyle: TextStyle(color: Colors.redAccent),
      ),
    );
  }

  Widget _buildDayView(DateTime selectedDay, List<String> events) {
    return Container(
      width: double.infinity,
      color: Colors.grey[100],
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
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
            _EventList(events: events),
          ],
        ),
      ),
    );
  }
}

class _EventList extends StatelessWidget {
  final List<String> events;
  const _EventList({required this.events});

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const Text(
        'Nenhum evento para este dia.',
        style: TextStyle(fontSize: 16),
      );
    }

    return Column(
      children: events
          .map(
            (e) => Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.symmetric(vertical: 6),
              elevation: 1,
              child: ListTile(
                leading: const Icon(Icons.event, color: Colors.blueAccent),
                title: Text(
                  e,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: const Text('Detalhes do evento'),
              ),
            ),
          )
          .toList(),
    );
  }
}
