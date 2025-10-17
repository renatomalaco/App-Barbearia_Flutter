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