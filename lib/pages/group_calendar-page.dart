import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:momentime/models/group.dart';
import 'package:momentime/backend/database_manager.dart';

class GroupCalendarPage extends StatefulWidget {
  final Group group;
  const GroupCalendarPage({super.key, required this.group});

  @override
  State<GroupCalendarPage> createState() => _GroupCalendarPageState();
}

class _GroupCalendarPageState extends State<GroupCalendarPage> {
  List<Appointment> _groupAppointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGroupData();
  }

  Future<void> _loadGroupData() async {
    final appointments = await DatabaseManager().getGroupAppointments(widget.group.members);
    setState(() {
      _groupAppointments = appointments;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Agenda : ${widget.group.name}"),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadGroupData),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SfCalendar(
        view: CalendarView.month,
        dataSource: _GroupDataSource(_groupAppointments),
        monthViewSettings: const MonthViewSettings(
          showAgenda: true, // Affiche la liste des gens occupés sous le calendrier
          agendaViewHeight: 200,
        ),
        monthCellBuilder: (context, details) {
          final bool isBusy = _groupAppointments.any((app) {
            final date = DateTime(details.date.year, details.date.month, details.date.day);
            final start = DateTime(app.startTime.year, app.startTime.month, app.startTime.day);
            final end = DateTime(app.endTime.year, app.endTime.month, app.endTime.day);

            return (date.isAtSameMomentAs(start) || date.isAtSameMomentAs(end)) ||
                (date.isAfter(start) && date.isBefore(end));
          });

          return Container(
            decoration: BoxDecoration(
              color: isBusy ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
              border: Border.all(color: Colors.grey.withOpacity(0.2), width: 0.5),
            ),
            child: Center(
              child: Text(
                details.date.day.toString(),
                style: TextStyle(color: isBusy ? Colors.red : Colors.green),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GroupDataSource extends CalendarDataSource {
  _GroupDataSource(List<Appointment> source) {
    appointments = source;
  }
}