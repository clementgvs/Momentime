import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:momentime/account_manager.dart';
import 'package:momentime/database_manager.dart';
import 'package:momentime/events_manager.dart';
import 'package:momentime/models/event.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late Event event;
  List<Event> events = [];

  Future<void> addEvent(BuildContext context, Event event) async {
    print("Add event : \n${event.toString()}");

    Navigator.pop(context);

    User? currentUser = FirebaseAuth.instance.currentUser;
    DatabaseManager().addEvent(currentUser!.uid, event);

    setState(() {
      events.add(event);
    });

    event = Event("EventName",
        DateTime.now(),
        DateTime.now().add(Duration(hours: 1)),
        Color.fromRGBO(255, 0, 0, 1),
        false);
  }

  Future<void> pickDateTime(BuildContext context, bool endOrStart) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: event.from,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (date == null) return;

    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    setState(() {
      if(endOrStart){
        event.setFrom(DateTime(date.year, date.month, date.day, time.hour, time.minute));
      }else {
        event.setTo(DateTime(date.year, date.month, date.day, time.hour, time.minute));
      }
    });
  }

  Future<void> _loadEvents() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    List<Event> fetchedEvents = await DatabaseManager().getEventList(uid);

    setState(() {
      events = fetchedEvents;
    });
  }

  @override
  void initState() {
    event = Event("EventName",  
    DateTime.now(), 
    DateTime.now().add(Duration(hours: 1)),
    Color.fromRGBO(255, 0, 0, 1), 
    false);

    _loadEvents();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.sizeOf(context).height;
    TextEditingController eventNameController = TextEditingController();
    bool isAllDay = false;

    return Center(
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsetsGeometry.directional(start: 15, end: 15, bottom: 0, top: 0),
            child: SfCalendar(
              view: CalendarView.month,
              monthViewSettings: MonthViewSettings(
                showAgenda: true,
                agendaViewHeight: height/4,
                agendaItemHeight: height/16,
              ),
              dataSource: EventsManager(events),
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: () => showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  alignment: Alignment.center,
                  title: Text('Ajouter un évènement'),
                  content: SingleChildScrollView(
                    padding: EdgeInsetsGeometry.all(40),  
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: eventNameController,
                          maxLength: 50,
                          expands: false,
                          maxLines: 1,
                          minLines: 1,
                          onSubmitted: (value) => setState(() => event.setName(value)),
                          onChanged: (value) => setState(() => event.setName(value)),
                          decoration: InputDecoration(
                            hintText: 'Enter the event name',
                          ),
                        ),
                        TextButton(
                          onPressed: () => pickDateTime(context, true),
                          child: Text("Select start date"),
                        ),
                        TextButton(
                          onPressed: () => pickDateTime(context, false),
                          child: Text("Select end date"),
                        ),
                        Switch(
                          value: isAllDay, 
                          onChanged: (newValue) => setState(() {
                            isAllDay = newValue; 
                            event.setIsAllDay(newValue); 
                          }),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => addEvent(context, event),
                      child: Text('Ajouter'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Fermer'),
                    ),
                  ],
                ),
              ),
              shape: CircleBorder(),
              child: Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}