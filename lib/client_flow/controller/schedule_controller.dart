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

  // --- Mock Data for Tabs ---
  final List<FavoriteBarber> favoriteBarbers = [
    const FavoriteBarber(
      name: 'Jhon Cortes Clássicos',
      specialty: 'Cortes tradicionais',
      avatarUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=1000&auto=format&fit=crop',
    ),
    const FavoriteBarber(
      name: 'Marcos da Navalha',
      specialty: 'Barbas e design',
      avatarUrl: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=687&q=80',
    ),
  ];

  final List<FavoriteTimeSlot> favoriteTimeSlots = [
    const FavoriteTimeSlot(time: '09:00', barberName: 'Jhon Cortes Clássicos', service: 'Corte e Barba'),
    const FavoriteTimeSlot(time: '11:00', barberName: 'Marcos da Navalha', service: 'Corte Degradê'),
    const FavoriteTimeSlot(time: '15:00', barberName: 'Jhon Cortes Clássicos', service: 'Barba Terapia'),
    const FavoriteTimeSlot(time: '16:30', barberName: 'Jhon Cortes Clássicos', service: 'Corte Simples'),
  ];

  void dispose() {
    profile.dispose();
    selectedEvents.dispose();
  }
}