import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../model/schedule_model.dart';

class ScheduleController {
  final ValueNotifier<List<Event>> selectedEvents = ValueNotifier([]);
  
  // Usando um LinkedHashMap para manter a ordem dos eventos
  final LinkedHashMap<DateTime, List<Event>> events = LinkedHashMap(
    equals: isSameDay,
    hashCode: getHashCode,
  )..addAll({
    DateTime.now(): [
      Event(title: 'Corte de Cabelo - João'),
      Event(title: 'Barba - Carlos'),
    ],
    DateTime.now().add(const Duration(days: 2)): [
      Event(title: 'Manutenção de Barba - Pedro'),
    ],
  });

  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;

  List<Event> getEventsForDay(DateTime day) {
    return events[day] ?? [];
  }
}

// Função utilitária para o hashCode do LinkedHashMap
int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}