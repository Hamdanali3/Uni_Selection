class Discipline {
  final String id;
  final String categoryId;
  final String name;

  const Discipline({
    required this.id,
    required this.categoryId,
    required this.name,
  });

  factory Discipline.fromJson(Map<String, dynamic> json) {
    return Discipline(
      id: json['id'] as String,
      categoryId: json['category_id'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'category_id': categoryId,
    'name': name,
  };
}
