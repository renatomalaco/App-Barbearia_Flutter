// lib/client_flow/controller/schedule_controller.dart

import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../model/schedule_model.dart';


class ScheduleController {
  final ValueNotifier<ScheduleProfile> profile;

  ScheduleController()
      : profile = ValueNotifier<ScheduleProfile>(
          ScheduleProfile(
            name: 'barbeiro exemplo',
            classification: '(cliente)',
            profileImageUrl:
                'https://media.discordapp.net/attachments/1249450843002896516/1428545035283992586/jsus_cristo.png?ex=68f2e3bd&is=68f1923d&hm=060b3bddd2cf74cfcdeffa521b00f4c6492013281478d3e2976bcc613d1f822c&=&format=webp&quality=lossless&width=786&height=810',
          ),
        );

  // --- Lógica do Calendário ---

  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;
  final ValueNotifier<List<Event>> selectedEvents = ValueNotifier([]);

  // Usando um LinkedHashMap para manter a ordem dos eventos
  final LinkedHashMap<DateTime, List<Event>> events = LinkedHashMap(
    equals: isSameDay,
    hashCode: (key) => key.day * 1000000 + key.month * 10000 + key.year,
  )..addAll({
      DateTime.now().subtract(const Duration(days: 2)): [
        const Event('Corte com Jhon'),
      ],
      DateTime.now(): [
        const Event('Barba com Marcos às 10:00'),
        const Event('Corte Infantil às 14:00'),
      ],
      DateTime.now().add(const Duration(days: 5)): [
        const Event('Manutenção de Barba'),
        const Event('Corte e Hidratação'),
      ],
    });

  List<Event> getEventsForDay(DateTime day) {
    return events[day] ?? [];
  }

  void onDaySelected(DateTime newSelectedDay, DateTime newFocusedDay) {
    selectedDay = newSelectedDay;
    focusedDay = newFocusedDay;
    selectedEvents.value = getEventsForDay(newSelectedDay);
  }

  void dispose() {
    profile.dispose();
    selectedEvents.dispose();
  }
}