class AddressSearchSuggestion {
  const AddressSearchSuggestion({
    required this.latitude,
    required this.longitude,
    required this.title,
    required this.subtitle,
    this.detail = '',
    this.ward = '',
    this.district = '',
    this.city = '',
    this.isCoordinate = false,
  });

  final double latitude;
  final double longitude;
  final String title;
  final String subtitle;
  final String detail;
  final String ward;
  final String district;
  final String city;
  final bool isCoordinate;
}
