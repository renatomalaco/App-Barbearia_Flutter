// lib/client_flow/model/schedule_model.dart

class ScheduleProfile {
  final String name;
  final String classification;
  final String profileImageUrl;

  ScheduleProfile(
      {required this.name,
      required this.classification,
      required this.profileImageUrl});
}

/// Exemplo de classe para os eventos do calendário.
class Event {
  final String title;

  const Event(this.title);

  @override
  String toString() => title;
}

class FavoriteBarber {
  final String name;
  final String specialty;
  final String avatarUrl;

  const FavoriteBarber({
    required this.name,
    required this.specialty,
    required this.avatarUrl,
  });
}

class FavoriteTimeSlot {
  final String time;
  final String barberName;
  final String service;

  const FavoriteTimeSlot({
    required this.time,
    required this.barberName,
    required this.service,
  });
}