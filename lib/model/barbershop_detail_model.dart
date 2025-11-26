
class BarbershopDetail {
  final String name;
  final String imageUrl;
  final String description;
  final String openingHours;
  final String address;
  final String cityState;
  final String zipCode;
  final String barberName;
  final String barberSpecialty;
  final String barberImageUrl;
  final List<String> specialties;
  // final String rating;
  // final String reviewCount;

  BarbershopDetail({
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.openingHours,
    required this.address,
    required this.cityState,
    required this.zipCode,
    this.barberName = '',
    this.barberSpecialty = '',
    this.barberImageUrl = '',
    this.specialties = const [],
    // required this.rating,
    // required this.reviewCount,
  });
}