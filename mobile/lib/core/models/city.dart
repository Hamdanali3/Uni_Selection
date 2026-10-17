class City {
  final String id;
  final String countryId;
  final String name;
  final String? provinceState;

  const City({
    required this.id,
    required this.countryId,
    required this.name,
    this.provinceState,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'] as String,
      countryId: json['country_id'] as String,
      name: json['name'] as String,
      provinceState: json['province_state'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'country_id': countryId,
    'name': name,
    'province_state': provinceState,
  };
}
