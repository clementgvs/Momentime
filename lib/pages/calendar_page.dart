import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          SfCalendar(
            view: CalendarView.month,
            monthViewSettings: MonthViewSettings(showAgenda: true),
            //dataSource: ,
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () => showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Titre'),
                  content: Text('Contenu de la boîte de dialogue'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Fermer'),
                    ),
                  ],
                ),
              ),
              child: Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}