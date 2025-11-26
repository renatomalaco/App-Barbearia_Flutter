class Barbershop {
  final String id; // ID é obrigatório
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
    required this.id,
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Barbershop && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}