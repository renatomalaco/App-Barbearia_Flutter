// lib/model/config_model.dart

class BarberSettings {
  final String name;
  final String email;
  final String profileImageUrl;
  bool notificationsEnabled;
  bool darkModeEnabled;

  BarberSettings(
      {required this.name,
      required this.email,
      required this.profileImageUrl,
      this.notificationsEnabled = true,
      this.darkModeEnabled = false});
}