// lib/model/config_model.dart

class BarberSettings {
  final String name;
  final String email;
  bool notificationsEnabled;
  bool darkModeEnabled;

  BarberSettings({required this.name, required this.email, this.notificationsEnabled = true, this.darkModeEnabled = false});
}