// lib/client_flow/model/edit_profile_model.dart

class ClientProfile {
  String name;
  String email;
  String phone;
  String profileImageUrl;

  ClientProfile(
      {required this.name, required this.email, required this.phone, required this.profileImageUrl});
}