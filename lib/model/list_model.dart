class Barbershop {
  final String name;
  final String description;
  final String address;
  final String cityState;
  final String zipCode;
  final String imageUrl;
  final String openingHours;
  final String barberName;
  final String barberSpecialty;
  final String barberImageUrl;
  final List<String> specialties;

  Barbershop({
    required this.name,
    required this.description,
    required this.address,
    required this.cityState,
    required this.zipCode,
    required this.imageUrl,
    required this.openingHours,
    this.barberName = '',
    this.barberSpecialty = '',
    this.barberImageUrl = '',
    this.specialties = const [],
  });
}