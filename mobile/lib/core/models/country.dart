class Country {
  final String id;
  final String name;
  final bool isNational;

  const Country({
    required this.id,
    required this.name,
    required this.isNational,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id'] as String,
      name: json['name'] as String,
      isNational: json['is_national'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'is_national': isNational,
  };
}
