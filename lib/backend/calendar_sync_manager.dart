import 'package:device_calendar/device_calendar.dart' hide Event;
import 'package:momentime/models/event.dart';
import 'package:flutter/material.dart';

class CalendarSyncManager {
  final DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();

  Future<List<Event>> fetchSystemEvents() async {
    List<Event> syncedEvents = [];

    // 1. Demander la permission
    var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
    if (permissionsGranted.isSuccess && !permissionsGranted.data!) {
      permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
      if (!permissionsGranted.isSuccess || !permissionsGranted.data!) {
        return [];
      }
    }

    // 2. Récupérer les calendriers (Google, iCloud, etc.)
    final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
    if (calendarsResult.isSuccess && calendarsResult.data != null) {

      // On boucle sur chaque calendrier présent sur le téléphone
      for (var calendar in calendarsResult.data!) {

        // 3. Récupérer les événements (ex: sur les 30 prochains jours)
        final eventsResult = await _deviceCalendarPlugin.retrieveEvents(
          calendar.id,
          RetrieveEventsParams(
            startDate: DateTime.now(),
            endDate: DateTime.now().add(const Duration(days: 30)),
          ),
        );

        if (eventsResult.isSuccess && eventsResult.data != null) {
          for (var deviceEvent in eventsResult.data!) {
            // 4. Conversion vers ton modèle "Event"
            syncedEvents.add(Event(
              deviceEvent.eventId ?? "system_${deviceEvent.title}",
              deviceEvent.title ?? "Sans titre",
              deviceEvent.start!,
              deviceEvent.end!,
              Colors.blueGrey, // Couleur par défaut pour les events système
              deviceEvent.allDay ?? false,
            ));
          }
        }
      }
    }
    return syncedEvents;
  }
}